#!/usr/local/bin/bash

set -eou pipefail

loadColumns(){
    FILENAME=$1
    COUNT=0
    read -r EXAMPLELINE < "$FILENAME"
    for (( i=0; i<${#EXAMPLELINE}; i++ )); do
        while read -r ENTRY; do
            if [ -z "$ENTRY" ]; then
                continue
            fi
            echo -n "${ENTRY:$i:1}"
        done < "$FILENAME"
        echo
    done
}

loadRows(){
    FILENAME=$1
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        echo "${ENTRY//[!0-9]/}"
    done < "$FILENAME"
}

check(){
    FILENAME=$1
    COLS=($(loadColumns "$FILENAME"))
    for (( i=0; i<${#COLS[@]}; i++ )){
        checkLeftToRight "${COLS[$i]}" "%d,$i,TB\n" "normal"
        checkLeftToRight "${COLS[$i]}" "%d,$i,BT\n" "inversion"
    }
    ROWS=($(loadRows "$FILENAME"))
    for (( i=0; i<${#ROWS[@]}; i++ )){
        checkLeftToRight "${ROWS[$i]}" "$i,%d,LR\n" "normal"
        checkLeftToRight "${ROWS[$i]}" "$i,%d,RL\n" "inversion"
    }
}


checkLeftToRight(){
    STRING=$1
    FORMAT=$2
    INVERSION="$3"
    MAX=-1
    if [[ "$INVERSION" == "inversion" ]]; then
        COUNT=$((${#STRING}-1))
        INCREMENT=-1
        STRING=$(echo $STRING | rev)
    else 
        COUNT=0
        INCREMENT=1
    fi
    while read -r -n1 CHAR; do
        if [ -z "$CHAR" ]; then
            continue
        fi
        if [ $CHAR -gt $MAX ]; then
            printf "$FORMAT" "$COUNT"
            # Optimization
            if [ $CHAR -eq 9 ]; then
                return
            fi
            MAX=$CHAR
        fi
        COUNT=$((COUNT+INCREMENT))
    done <<< "$STRING"
}

calculateView(){
    ENTRIES=($@)
    declare -a SCORES
    for ENTRY in "${ENTRIES[@]}"; do
        read ROW COL DIRECTION $ENTRY"
    done
}

PROCESSED=$(check "data.txt" | sort -k1,1n -k2,2n -t,)

#echo "## Part 1"
#printf '%s\n' "${PROCESSED[@]}" | awk -F, '{ print $1 "," $2 }' | uniq | wc -l

calculateView "${PROCESSED[@]}"
