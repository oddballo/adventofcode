#!/usr/local/bin/bash

set -eou pipefail

getPriority() {
    CHAR=$1
    ASCII=$(printf '%d\n' "'${WORD1[$i]}")
    if [ $ASCII -gt 96 ]; then
        # Re-index to 1
        echo "$((ASCII - 97 + 1))"
    else            
        # Re-index to 27
        echo $((ASCII - 65 + 27))
    fi
}

getUniqueCharacters(){
    STRING=$1
    START=${2:-0}
    END=${3:-${#STRING}}
    echo -n "${STRING:$START:$END}" |
             fold -w1 |
             sort |
             uniq
}

findMatch(){
    WORD1=$1
    WORD2=$2
    WORD3=${3:-}
    for (( i=0; i<${#WORD1[@]}; i++)); do        
        for (( j=0; j<${#WORD2[@]}; j++)); do
            if [[ "${WORD1[$i]}" == "${WORD2[$j]}" ]]; then
                if [ -z "$WORD3" ]; then
                    getPriority "${WORD1[$i]}"
                    return
                else
                    for (( k=0; k<${#WORD3[@]}; k++)); do
                        if [[ "${WORD1[$i]}" == "${WORD3[$k]}" ]]; then
                            getPriority "${WORD1[$i]}"
                            return
                        fi
                    done
                fi
            fi
        done
    done
    echo "Didn't find a match. Aborting."
    exit 1
}

getPairsFromCompartments() {
    FILENAME=$1
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        LENGTH=$((${#ENTRY}/2))
        WORD1=($(getUniqueCharacters "$ENTRY" 0 $LENGTH))
        WORD2=($(getUniqueCharacters "$ENTRY" $LENGTH $LENGTH))
        findMatch "$WORD1" "$WORD2"
    done < "$FILENAME"
}

getBadges() {
    FILENAME=$1
    while read -r LINE1; do
        read -r LINE2
        read -r LINE3
        if [ -z "$LINE1" ] || [ -z "$LINE2" ] || [ -z "$LINE3" ]; then
            continue
        fi

        WORD1=($(getUniqueCharacters "$LINE1"))
        WORD2=($(getUniqueCharacters "$LINE2"))
        WORD3=($(getUniqueCharacters "$LINE3"))
        findMatch "$WORD1" "$WORD2" "$WORD3"
    done < "$FILENAME"
}

echo "## Part 1"
getPairsFromCompartments "challenge.txt" | paste -s -d+ - | bc
echo "## Part 2"
getBadges "challenge.txt" | paste -s -d+ - | bc
