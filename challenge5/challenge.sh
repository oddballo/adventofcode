#!/usr/local/bin/bash

set -eou pipefail

loadPuzzle(){
    FILENAME=$1
    declare -a PUZZLE=()
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            break
        fi
        REMAINING="$ENTRY"
        COUNT=0
        while [ ! -z "$REMAINING" ]; do
            PARTF="${REMAINING:0:4}"
            PART="${PARTF//[^[:alpha:]]/}"
            if [ ! "${PUZZLE[$COUNT]+a}" ]; then
                PUZZLE[$COUNT]=""
            fi    
            if [ ! -z "$PART" ]; then
                PUZZLE[$COUNT]="${PUZZLE[$COUNT]}$PART"
            fi
            REMAINING="${REMAINING:4}"
            COUNT=$((COUNT+1))
        done
    done < "$FILENAME"
    echo "${PUZZLE[@]}"
}

runInstructions(){
    local PUZZLE
    FILENAME=$1
    shift
    PUZZLE=($@)
    while read -r ENTRY; do
        IFS=' ' read MOVES FROM TO <<< $(echo "$ENTRY" | sed 's/[^0-9 ]*//g')
        FROM=$((FROM-1))
        TO=$((TO-1))
        for (( i = MOVES ; i > 0; i-- )); do
            FROM_S="${PUZZLE[$FROM]}"
            PART="${FROM_S:0:1}"
            PUZZLE[$FROM]="${FROM_S:1}"
            PUZZLE[$TO]="$PART${PUZZLE[$TO]}"
        done
    done <<< $(tail -n +11 "$FILENAME")
    echo "${PUZZLE[@]}"
}

runInstructions2(){
    local PUZZLE
    FILENAME=$1
    shift
    PUZZLE=($@)
    while read -r ENTRY; do
        IFS=' ' read MOVES FROM TO <<< $(echo "$ENTRY" | sed 's/[^0-9 ]*//g')
        FROM=$((FROM-1))
        TO=$((TO-1))
        FROM_S="${PUZZLE[$FROM]}"
        PART="${FROM_S:0:$MOVES}"
        PUZZLE[$FROM]="${FROM_S:$MOVES}"
        PUZZLE[$TO]="$PART${PUZZLE[$TO]}"
    done <<< $(tail -n +11 "$FILENAME")
    echo "${PUZZLE[@]}"
}

PUZZLE_START=($(loadPuzzle "data.txt"))

echo "## Part 1"
PUZZLE1=($(runInstructions "data.txt" "${PUZZLE_START[@]}"))
for BLOCK in "${PUZZLE1[@]}"; do echo -n "${BLOCK:0:1}"; done
echo

echo "## Part 2"
PUZZLE2=($(runInstructions2 "data.txt" "${PUZZLE_START[@]}"))
for BLOCK in "${PUZZLE2[@]}"; do echo -n "${BLOCK:0:1}"; done
echo

