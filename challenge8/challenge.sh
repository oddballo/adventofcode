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

numberOfTreesInViewFromOutside(){
    FILENAME=$1
    ROWS=($(loadRows "$FILENAME"))
    COLS=($(loadColumns "$FILENAME"))

    for (( i=0; i<${#COLS[@]}; i++ )){
        checkLeftToRight "${COLS[$i]}" "%d,$i\n" "normal"
        checkLeftToRight "${COLS[$i]}" "%d,$i\n" "inversion"
    } &
    for (( i=0; i<${#ROWS[@]}; i++ )){
        checkLeftToRight "${ROWS[$i]}" "$i,%d\n" "normal"
        checkLeftToRight "${ROWS[$i]}" "$i,%d\n" "inversion"
    } &
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

bestViewFromAnySingleTree(){
    FILENAME=$1
    ROWS=($(loadRows "$FILENAME"))
    COLS=($(loadColumns "$FILENAME"))
    for (( i=0; i<${#ROWS[@]}; i++ )){
        for (( j=0; j<${#COLS[@]}; j++ )){
   
            ROW="${ROWS[$i]}"
            COL="${COLS[$j]}"

            INCI=$((i+1))
            INCJ=$((j+1))

            # Same as ${COL:$i:1}
            CELL="${ROW:$j:1}"

            PATHL=$(checkVision "$CELL" "$(echo "${ROW:0:$j}" | rev)")
            PATHR=$(checkVision "$CELL" "${ROW:$INCJ}")
            PATHU=$(checkVision "$CELL" "$(echo "${COL:0:$i}" | rev)")
            PATHD=$(checkVision "$CELL" "${COL:$INCI}")
            echo $((PATHL * PATHR * PATHU * PATHD))
        } &
    }
}

checkVision(){
    VALUE=$1
    ROUTE=$2
    COUNT=0
    while read -n1 STEP; do
        if [ -z "$STEP" ]; then
            continue
        fi
        COUNT=$((COUNT+1))
        if [ $STEP -ge $VALUE ]; then
            break
        fi
    done <<< "$ROUTE"
    echo $COUNT
}

FILENAME="data.txt"

echo "## Part 1"
numberOfTreesInViewFromOutside "$FILENAME" | sort -k1,1n -k2,2n -t, | uniq | wc -l

echo "## Part 2"
bestViewFromAnySingleTree "$FILENAME" "${COLS[@]}" | sort -r -n | head -n 1

