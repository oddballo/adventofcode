#!/usr/local/bin/bash

files(){
    FILENAME=$1
    CURRENT=""
    while read -r ENTRY; do

        PART=$(echo "$ENTRY" | cut -f 1 -d" ")
        if [[ "$PART" == "$" ]]; then
            PART2=$(echo "$ENTRY" | cut -f 2 -d" ")
            if [ "$PART2" == "cd" ]; then
                PART3=$(echo "$ENTRY" | cut -f 3 -d" ")
                if [[ "$PART3" == ".." ]]; then
                    CURRENT="$(echo "$CURRENT" | rev | cut -f2- -d"/" | rev)"
                elif [ -z "$CURRENT" ]; then
                    if [[ "$PART3" != "/" ]]; then
                        CURRENT="/$PART3"
                    fi
                elif [[ "$CURRENT" == "/" ]]; then
                    CURRENT="$CURRENT$PART3"
                else
                    CURRENT="$CURRENT/$PART3"
                fi
            fi
        elif [[ "$PART" != "dir" ]]; then
            FILENAME="$(echo "$ENTRY" | cut -f 2 -d" ")"
            echo "$CURRENT/$FILENAME,$PART"
        fi
    done < "$FILENAME"
}

totalFolders(){
    local FILES=("$@")
    declare -A FOLDER
    for FILE in "${FILES[@]}"; do
        FILEPATH="$(echo "$FILE" | cut -f1 -d",")"
        SIZE="$(echo "$FILE" | cut -f2 -d",")"
        CURRENT=""

        IFS='/' read -a PARTS <<< "$FILEPATH"
        LENGTH=${#PARTS[@]}
        # Stop one short on the folder; we don't care for files
        for (( j=0; j < LENGTH - 1; j++ )); do
            PART=${PARTS[$j]}
            if [ -z "$PART" ]; then
                CURRENT="/"
            else
                CURRENT="$CURRENT$PART/"
            fi
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



