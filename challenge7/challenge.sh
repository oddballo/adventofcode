#!/usr/local/bin/bash

files(){
    FILENAME=$1
    CURRENT=""
    while read -r ENTRY; do
        IFS=" " read PART1 PART2 PART3 <<< "$ENTRY" 
        if [[ "$PART1" == "$" ]] && [[ "$PART2" == "cd" ]]; then
            if [[ "$PART3" == ".." ]]; then
                CURRENT="$(echo "$CURRENT" | rev | cut -f2- -d"/" | rev)"
            elif [[ "$PART3" == "/" ]]; then
                CURRENT="/"
            elif [[ "$CURRENT" == "/" ]]; then
                CURRENT="$CURRENT$PART3"
            else
                CURRENT="$CURRENT/$PART3"
            fi
        elif [ "$PART1" ] && [ -z "${PART1//[0-9]}" ]; then
            echo "$CURRENT/$PART2,$PART1"
        fi
    done < "$FILENAME"
}

totalFolders(){
    local FILES=("$@")
    declare -A FOLDER
    for FILE in "${FILES[@]}"; do
        IFS="," read FILEPATH SIZE <<< "$FILE" 
        IFS='/' read -a PARTS <<< "$FILEPATH"
        CURRENT=""
        LENGTH=${#PARTS[@]}
        # Stop one short on the folder; we don't care for files
        for (( j=0; j < LENGTH - 1; j++ )); do
            PART=${PARTS[$j]}
            CURRENT="$CURRENT$PART/"
            if [ ! "${FOLDER["$CURRENT"]+a}" ]; then
                FOLDER["$CURRENT"]=0
            fi
            FOLDER["$CURRENT"]=$((FOLDER["$CURRENT"]+SIZE))
        done
    done
    for KEY in "${!FOLDER[@]}"
    do
        echo "$KEY,${FOLDER[$KEY]}"
    done
}

FILES=($(files "data.txt" | sort))
TOTALS=($(totalFolders "${FILES[@]}")) 

echo "## PART 1"
printf '%s\n' "${TOTALS[@]}" | awk -F\, '$2 < 100000' | cut -f2 -d"," | paste -s -d+ - | bc 

echo "## PART 2"
TOTAL=70000000
TARGET=30000000
USED=$(printf '%s\n' "${TOTALS[@]}" | grep '^/,' | cut -f2 -d",")
FREE=$((TOTAL - USED))
DIFF=$((TARGET - FREE))
printf '%s\n' "${TOTALS[@]}" | awk -F\, -v diff="$DIFF" '$2 > diff { print $2 }' | sort -n | head -n 1



