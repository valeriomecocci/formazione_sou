# Architettura e teoria di Cluster API con kind e CAPD

## Descrizione dell'esercizio 

L'obiettivo dell'esercizio è utilizzare  **Cluster API** per creare e gestire automaticamente 
cluster Kubernetes utilizzando un altro cluster Kubernetes come piattaforma di gestione ed eseguire
poi il deploy di un'applicazione.


## Architettura

L'intera infrastruttura è eseguita su Mac utilizzando Colima come runtime Docker: 
Colima (proprio come Docker Desktop) risolve il problema di dare al Mac un demone Docker,
dato che macOS non supporta nativamente i container Linux.

L'architettura finale è la seguente:

```text


   |                      MAC (host)                          |                                     
   │                                                          |          
   │   kubectl / clusterctl / docker (CLI lanciate dal Mac)   |
                             |
                             |
                             v
                  +----------------------+
                  |   Colima (VM Linux)  |
                  |    Docker Engine     |
                  +----------+-----------+
                             |
                             |
                  +----------v-----------+
                  |     kind Cluster     |
                  |  (Management Cluster)|
                  +----------+-----------+
                             |
                   Cluster API Controllers
                             |
                  Reconciliation Loop + CAPD
                             |
                  +----------v-----------+
                  |    Workload Cluster  |
                  | (Cluster Kubernetes) |
                  +----------+-----------+
                             |
                      Deployment Flask
                             |
                          Service
                             |
                        Port Forward
                             |
                        Browser/Curl
```

## Struttura del progetto

```
esercizio_cluster_api
├── README.md
├── .gitignore
├── kind-config.yaml
├── capi-quickstart.yaml
└── app/
    ├── Dockerfile
    ├── app.py
    ├── requirements.txt
    ├── deployment.yaml
    └── service.yaml
```


| File | Ruolo |
|---|---|
| `kind-config.yaml` | configurazione del management cluster kind |
| `capi-quickstart.yaml` | manifest ClusterClass + Cluster, generato da `clusterctl generate cluster` |
| `app/Dockerfile` | build dell'immagine dell'app Flask |
| `app/app.py` | applicazione Flask di test (`/` → `hello world`) |
| `app/requirements.txt` | dipendenze Python |
| `app/deployment.yaml` | Deployment Kubernetes dell'app sul workload cluster |
| `app/service.yaml` | Service `ClusterIP` per esporre l'app internamente |
| `.gitignore` | esclude `*.kubeconfig` dal versionamento (credenziali sensibili) |

Non versionato: `capi-quickstart.kubeconfig`, generato localmente e diverso ogni volta
che si ricrea il cluster.


In questo esercizio vengono utilizzati **due cluster Kubernetes distinti**:

1. **Management Cluster** è un cluster Kubernetes utilizzato esclusivamente per amministrare altri cluster. 
Non ospita applicazioni utente, ma contiene solamente i controller di Cluster API.

2. **Workload Cluster** è invece il cluster Kubernetes effettivo: 
quello nel quale vengono eseguite le applicazioni.  
Nel nostro caso sarà il cluster sul quale verrà distribuita l'applicazione Flask.

---

## Perché servono due cluster?

Quando si vuole creare un cluster Kubernetes è necessario:

* creare i nodi;
* inizializzare il Control Plane;
* aggiungere i Worker;
* monitorarne continuamente lo stato.

Questo ruolo viene svolto da **Cluster API**.

## Cluster API

Cluster API è un progetto ufficiale Kubernetes che applica alla gestione dei cluster l
a stessa logica dichiarativa che Kubernetes usa per Pod e Deployment: si descrive lo stato desiderato tramite 
**custom resource**, e dei **controller** (reconciler) riconciliano continuamente la realtà con
quella descrizione. Cambia solo il livello di astrazione: l'oggetto gestito non è un
container ma un intero nodo, o un intero cluster.

Il Management Cluster rappresenta quindi il "regista" dell'intera infrastruttura.

Il flusso diventa:

```text
Mac

↓

kind

↓

Management Cluster

↓

Cluster API

↓

Workload Cluster
```



---

## Il ruolo di kind


**kind** (**Kubernetes IN Docker**) crea rapidamente un piccolo cluster Kubernetes locale
 nel quale installare Cluster API.

Per questo motivo il primo comando eseguito è:

```bash
kind create cluster --config kind-config.yaml
```

Questo comando crea il **Management Cluster** utilizzando Docker.

I nodi del cluster non sono macchine virtuali o fisiche ma semplici _container Docker_: 
ogni "nodo" del cluster è un container che esegue
un'immagine (`kindest/node`) contenente già kubelet, containerd e i binari necessari.

Successivamente verifichiamo il corretto funzionamento del cluster con:

```bash
kubectl cluster-info --context kind-kind
```

Questo comando interroga l'API Server del Management Cluster e conferma che il Control Plane è operativo.

---

## Comunicazione tra i componenti

Uno degli aspetti più importanti del laboratorio riguarda il modo in cui comunicano i diversi componenti.

```text
                    Docker Engine
                          ^
                          |
                     docker.sock
                          |
                          v
                Management Cluster
                          |
               CAPD Controller
                          |
                  docker run ...
                          |
                          v
             Container Docker (Machine)
                          |
                          v
                 Nodo Kubernetes
```

Il componente fondamentale è il **Docker Socket**.

Il controller **CAPD** gira all'interno del Management Cluster, quindi vive in un container Kubernetes.

Il Docker Engine invece gira nella macchina Linux creata da Colima.

Per consentire al controller di creare nuovi container è necessario montare il socket Docker all'interno del cluster kind.

Per questo motivo nel file `kind-config.yaml` viene montato:

```yaml
extraMounts:
  - hostPath: /var/run/docker.sock
    containerPath: /var/run/docker.sock
```

Il socket rappresenta il canale di comunicazione tra CAPD e Docker.

---

## Installazione di nuove risorse nel Management Cluster

Cluster API permette di gestire 
cluster Kubernetes utilizzando lo stesso modello dichiarativo impiegato per Pod, Deployment e Service.

L'idea fondamentale è che anche un intero cluster possa essere rappresentato come una risorsa Kubernetes.

`clusterctl` è il CLI ufficiale di Cluster API: è lo strumento a riga di comando che usiamo dal Mac per gestire 
l'intero ciclo di vita di Cluster API stessa e dei cluster che si provisionano con essa. 

Non è un tool generico Kubernetes come kubectl (che parla con qualunque cluster Kubernetes), ma è _specifico_ per Cluster API.



Quando eseguiamo:

```bash
export CLUSTER_TOPOLOGY=true
clusterctl init --infrastructure docker
```

installiamo nel Management Cluster:

* CRD (Custom Resource Definitions)
* Controller
* Admission Webhook
* Reconcilers
* Provider Docker (CAPD)

Da questo momento il cluster è in grado di comprendere nuove risorse come:

```yaml
kind: Cluster
kind: Machine
kind: MachineDeployment
kind: ClusterClass
kind: KubeadmControlPlane
```

Queste risorse non esistono in Kubernetes standard ma sono introdotte da Cluster API tramite le CRD.



Verifica:

```bash
kubectl get pods -A
```

Va controllato che tutti i pod siano `Running` e stabili (senza `RESTARTS` in crescita)
prima di proseguire. Nella pratica, su hardware con risorse limitate, questo è il punto
in cui possono comparire i primi sintomi di sovraccarico .

---

## Il Reconciliation Loop

Il cuore di Cluster API è il **reconciliation loop**: una parte di codice, 
in un controller, che implementa il ciclo che cerca di allineare continuamente
lo stato osservato con quello desiderato.



Lo stesso principio è già utilizzato dai Deployment: un Deployment controlla continuamente 
che esista il numero corretto di Pod e Cluster API applica la stessa filosofia ad un livello superiore,
infatti non mantiene in vita Pod ma interi cluster Kubernetes.

---

## ClusterClass

Una ClusterClass rappresenta un modello riutilizzabile (template) per la creazione di cluster.


Nel laboratorio, il file viene generato automaticamente con:

```bash
clusterctl generate cluster capi-quickstart \
  --flavor development \
  --kubernetes-version v1.31.0 \
  --control-plane-machine-count=1 \
  --worker-machine-count=1 \
  > capi-quickstart.yaml
```

Questo comando **non crea il cluster**, ma genera solamente il manifesto YAML 
contenente tutte le risorse necessarie.

---


## CAPD (Cluster API Provider Docker)

CAPD è l'**infrastructure provider**: traduce le richieste astratte di Cluster API 
in azioni concrete Docker ("crea un container `kindest/node`"). 

È ilmotivo per cui, guardando `docker ps`, si vedono container con nomi tipo
`capi-quickstart-md-0-...`: sono le Machine "materializzate" da CAPD.

Nel cloud, invece, i provider Cluster API creano macchine virtuali.


## Machine, MachineDeployment e KubeadmControlPlane

Cluster API introduce nuovi oggetti.

### Machine

Una Machine rappresenta un nodo Kubernetes. 

Le Machine sono **immutabili** e non vengono mai aggiornate in place, solo sostituite 
(prorpio come  i Pod in un Deployment)


Con CAPD una Machine corrisponde ad un container Docker:

```text
Machine

↓

Container Docker

↓

Nodo Kubernetes
```

---

### MachineDeployment

Svolge lo stesso ruolo che Deployment svolge per i Pod.

Gestisce automaticamente il numero di Worker desiderati.

---

### KubeadmControlPlane

Fa lo stesso lavoro del MachineDeployment ma per le Machine del control plane, usando
lo strumento `kubeadm` per:


* inizializzare Kubernetes;
* generare i certificati;
* configurare l'API Server;
* configurare Scheduler;
* configurare Controller Manager.

---


##  Dal manifest alla creazione del cluster

Quando eseguiamo:

```bash
kubectl apply -f capi-quickstart.yaml
```

non viene creato direttamente il cluster ma il flusso è il seguente:

```text
kubectl

↓

API Server

↓

Admission Webhook

↓

etcd

↓

Cluster API Controllers

↓

CAPD

↓

Docker

↓

Nuovi nodi Kubernetes
```

I controller osservano continuamente lo stato desiderato e iniziano automaticamente il provisioning del Workload Cluster
(cioè, il processo di creazione effettiva dell'infrastruttura del Workload Cluster).

Lo stato di avanzamento può essere monitorato tramite:

```bash
clusterctl describe cluster capi-quickstart
```

---

## kubeconfig del Workload Cluster

Una volta completato il provisioning è necessario ottenere il `kubeconfig` del nuovo cluster.

`kubeconfig` è il file di configurazione che serve a `kubectl`
(o a qualunque client Kubernetes) per autenticarsi e connettersi al workload cluster (capi-quickstart) 
invece che al management cluster.

Contiene tre cose essenziali:
- l'indirizzo dell'apiserver del workload cluster (server: https://...)

- il certificato della CA del cluster, per verificare che stai parlando col server giusto

- certificato e chiave client, per autenticarti come amministratore di quel cluster


Con

```bash
clusterctl get kubeconfig capi-quickstart > capi-quickstart.kubeconfig
```

il kubeconfig viene salvato come Secret all'interno del Management Cluster.

Cluster API lo estrae e lo rende disponibile per l'amministrazione del Workload Cluster.

Il `server:` in quel file punta di default a un IP Docker interno
(`https://172.18.0.3:6443`), che con Colima **non è raggiungibile dal Mac**. 

Va quindi trovata la porta reale mappata sull'host dal container `capi-quickstart-lb`
 (l'haproxy che fa da load balancer davanti all'apiserver) e sostituita nel file con `sed`, così il kubeconfig punta 
 a `127.0.0.1:<porta>`, che è effettivamente raggiungibile dal Mac.

```bash
docker ps | grep capi-quickstart-lb
```

trova la porta mappata (es. `0.0.0.0:32768->6443/tcp`), poi:

```bash
grep server ./capi-quickstart.kubeconfig
sed -i '' 's#https://172.18.0.3:6443#https://127.0.0.1:32768#' capi-quickstart.kubeconfig
```

(sostituendo l'IP effettivo trovato col `grep` e la porta effettiva trovata col `docker ps`).

Verifica:

```bash
kubectl --kubeconfig=./capi-quickstart.kubeconfig get nodes


```

---

## kubeadm e lo stato NotReady

Quando kubeadm crea un cluster Kubernetes installa:

* API Server
* Scheduler
* Controller Manager
* etcd
* kubelet

Non installa però alcun plugin di rete.

Per questo motivo, appena creato il cluster, i nodi risultano:

```text
NotReady
```

L'errore osservato è:

```text
NetworkPluginNotReady

CNI plugin not initialized
```

Questo comportamento è completamente normale.

Il nodo non può essere dichiarato Ready finché non dispone di una rete funzionante.

---

## CNI (Container Network Interface)

La CNI è lo standard utilizzato da Kubernetes per gestire la rete dei Pod.

Il plugin CNI ha il compito di:

* assegnare un indirizzo IP ai Pod;
* permettere la comunicazione Pod-to-Pod;
* permettere la comunicazione tra nodi differenti;
* configurare routing e forwarding.

Senza una CNI i Pod possono essere creati ma non possono comunicare.

Di conseguenza il nodo rimane nello stato NotReady.

---

## Calico

In questo esercizio è stato scelto **Calico** come **implementazione CNI**.

L'installazione è stata eseguita con:

```bash
kubectl --kubeconfig=./capi-quickstart.kubeconfig \
apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml
```

Calico installa automaticamente i componenti necessari nel namespace `kube-system`.

Una volta che tutti i Pod di Calico risultano Running:

```bash
kubectl --kubeconfig=./capi-quickstart.kubeconfig get pods -n kube-system
```

i nodi cambiano stato da: `NotReady` a `Ready`

Il motivo è che kubelet rileva finalmente la presenza di un plugin CNI funzionante.

---

## Pod Network

Ogni Pod possiede un proprio indirizzo IP.

Una delle caratteristiche fondamentali di Kubernetes è che ogni Pod deve poter comunicare con qualsiasi altro Pod 
del cluster senza utilizzare NAT.

Il plugin CNI realizza questa rete virtuale.

```text
Pod A ----\
            \
             > Pod Network
            /
Pod B ----/
```

Il nodo ospita i Pod, mentre la CNI configura automaticamente tutte le regole di rete necessarie affinché i Pod possano comunicare indipendentemente dal nodo sul quale sono in esecuzione.

Solo dopo la configurazione della Pod Network il cluster è realmente operativo e pronto ad ospitare applicazioni.

Nel laboratorio, una volta completata l'installazione di Calico e verificato che i nodi fossero `Ready`, 
è stato possibile creare il namespace `formazione-sou`, distribuire l'applicazione Flask tramite `Deployment` e `Service`, 
ed esporla localmente con il comando `kubectl port-forward`.

---
<br>

## Deploy dell'applicazione sul workload cluster

Una volta `Ready`, il workload cluster si comporta come un cluster Kubernetes
qualunque: Cluster API non interviene più nel ciclo di vita di ciò che ci gira sopra.

### L'app

`app/app.py`:

```python
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "hello world"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

`app/Dockerfile`:

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

L'immagine, buildata e pubblicata su Docker Hub, viene referenziata direttamente nel
Deployment (non serve rifare build/push se un'immagine compatibile esiste già).

### `app/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-hello
  namespace: formazione-sou
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-hello
  template:
    metadata:
      labels:
        app: flask-hello
    spec:
      containers:
        - name: flask-hello
          image: valeriomecocci/flask-app:latest
          ports:
            - containerPort: 5000
```

### `app/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-hello
  namespace: formazione-sou
spec:
  selector:
    app: flask-hello
  ports:
    - port: 80
      targetPort: 5000
  type: ClusterIP
```

Il Service espone il Pod all'interno del cluster sulla porta 80, instradando il
traffico verso la porta 5000 del container (dove Flask ascolta davvero).

### Comandi di deploy

```bash
export KUBECONFIG=./capi-quickstart.kubeconfig
kubectl create namespace formazione-sou
kubectl apply -f app/deployment.yaml -f app/service.yaml
kubectl get pods -n formazione-sou
kubectl get svc -n formazione-sou
```

### Accesso all'applicazione

Il Service è `ClusterIP`, non raggiungibile direttamente dal Mac: serve il
port-forward.

```bash
kubectl port-forward svc/flask-hello 8080:80 -n formazione-sou
```

Questo comando resta bloccato in primo piano (comportamento atteso, non un errore):
mappa la porta 8080 del Mac verso la porta 80 del Service, che a sua volta instrada
verso la porta 5000 del Pod. In un altro terminale:

```bash
curl http://localhost:8080
```

Output atteso: `hello world`.
