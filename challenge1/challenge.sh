#!/usr/local/bin/bash

set -eou pipefail

subtotals(){
    FILENAME=$1
    TOTAL=0
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            echo "$TOTAL"
            TOTAL=0
        else
            TOTAL=$((TOTAL + ENTRY))
        fi
    done < "$FILENAME"
}

echo "## Part 1"
subtotals "challenge.txt" | sort -t"," -k1n,1 | tail -n 1

echo "## Part 2"
SUBTOTALS=$(subtotals "challenge.txt" | sort -t"," -k1n,1 | tail -n 3)
SUBTOTAL=0
while read CURRENT; do 
    SUBTOTAL=$((SUBTOTAL+CURRENT)); 
done <<< "$SUBTOTALS"
echo $SUBTOTAL
