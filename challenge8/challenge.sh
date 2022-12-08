#!/usr/local/bin/bash

set -eou pipefail

loadColumns(){
    FILENAME=$1
    COUNT=0
    read -r EXAMPLELINE < "$FILENAME"
    for (( i=0; i<${#EXAMPLELINE}; i++ )); do
        while read -r ENTRY; do
            echo -n "${ENTRY:$i:1}"
        done < "$FILENAME"
        echo
    done
}

loadRows(){
    FILENAME=$1
    while read -r ENTRY; do
        echo "$ENTRY"
    done < "$FILENAME"
}


check(){
    COLS=($(loadColumns "data.txt"))
    for (( i=0; i<${#COLS[@]}; i++ )){
        checkLeftToRight "${COLS[$i]}" "%d,$i\n" "normal"
        checkLeftToRight "${COLS[$i]}" "%d,$i\n" "inversion"
    }
    ROWS=($(loadRows "data.txt"))
    for (( i=0; i<${#ROWS[@]}; i++ )){
        checkLeftToRight "${ROWS[$i]}" "$i,%d\n" "normal"
        checkLeftToRight "${ROWS[$i]}" "$i,%d\n" "inversion"
    }
}


checkLeftToRight(){
    STRING=$1
    FORMAT=$2
    INVERSION="$3"
    MAX=0
    if [ -z "$STRING" ]; then
        return
    fi

    if [[ "$INVERSION" == "inversion" ]]; then
        LENGTH=${#STRING}
        COUNT=$((LENGTH-1))
        INCREMENT=-1
        STRING=$(echo $STRING | rev)
    else 
        COUNT=0
        INCREMENT=1
    fi
    while read -r -n1 NUM; do
        if [ -z "$NUM" ]; then
            continue
        fi
        if [ $NUM -gt $MAX ]; then
            printf "$FORMAT" "$COUNT"
            # Optimization
            if [ $NUM -eq 9 ]; then
                return
            fi
            MAX=$NUM
        fi
        COUNT=$((COUNT+INCREMENT))
    done <<< "$STRING"
}

check | sort | uniq | wc -l
