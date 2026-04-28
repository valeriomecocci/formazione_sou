grep "banana" file_esempio.csv | sed 's/^[^,]*,[^,]*,\([^,]*\).*/\1/'

#output
strawberry
watermelon

