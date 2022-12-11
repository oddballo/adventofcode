#!/usr/local/bin/bash

set -eou pipefail

getDutiesWhichEntirelyOverlap(){
    FILENAME=$1
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        IFS="," read DUTY1 DUTY2 <<< "$ENTRY"
        IFS="-" read DUTY1START DUTY1END <<< "$DUTY1"
        IFS="-" read DUTY2START DUTY2END <<< "$DUTY2"
        
        if [ $((DUTY2END - DUTY2START)) -gt $((DUTY1END-DUTY1START)) ]; then
            if [ "$DUTY2END" -ge "$DUTY1END" ] &&
               [ "$DUTY2START" -le "$DUTY1START" ]; then
                echo "yes"
            fi
        else 
            if [ "$DUTY1END" -ge "$DUTY2END" ] &&
               [ "$DUTY1START" -le "$DUTY2START" ]; then
                echo "yes"
            fi
        fi
        echo "no"
    done < "$FILENAME"
}
getDutiesWhichPartiallyOverlap(){
    FILENAME=$1
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        IFS="," read DUTY1 DUTY2 <<< "$ENTRY"
        IFS="-" read DUTY1START DUTY1END <<< "$DUTY1"
        IFS="-" read DUTY2START DUTY2END <<< "$DUTY2"
        
        if ([ "$DUTY1END" -ge "$DUTY2START" ] &&
            [ "$DUTY1START" -le "$DUTY2START" ]) ||
           ([ "$DUTY1END" -ge "$DUTY2END" ] &&
            [ "$DUTY1START" -le "$DUTY2END" ]) ||
           ([ "$DUTY2END" -ge "$DUTY1START" ] &&
            [ "$DUTY2START" -le "$DUTY1START" ]) ||
           ([ "$DUTY2END" -ge "$DUTY1END" ] &&
            [ "$DUTY2START" -le "$DUTY1END" ]); then
            echo "yes"
        fi
        echo "no"
    done < "$FILENAME"
}

echo "## Part 1"
getDutiesWhichEntirelyOverlap "data.txt" | grep "yes" | wc -l
echo "## Part 2"
getDutiesWhichPartiallyOverlap "data.txt" | grep "yes" | wc -l

