#!/usr/local/bin/bash

set -eou pipefail

countBeforeMarker(){
    FILENAME=$1
    LENGTH=$2
    COUNT=0
    STRING=""
    while read -n1 CHAR; do
        COUNT=$((COUNT+1))
        if [ ${#STRING} -lt $LENGTH ]; then
            STRING="$STRING$CHAR"
            continue
        fi
        STRING="${STRING:1}$CHAR"
        if [ $(echo "$STRING" | fold -w1 | sort | uniq | wc -l) -eq $LENGTH ]; then
            echo "$COUNT"
            return
        fi
    done < "$FILENAME"
}

echo "## Part 1"
countBeforeMarker "data.txt" 4
echo "## Part 2"
countBeforeMarker "data.txt" 14
