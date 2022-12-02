#!/usr/local/bin/bash

set -eou pipefail

mapo(){
    INPUT=$1
    CHAR=$2
    case $CHAR in
        X)
            echo $(((INPUT+2) % 3))
            ;;
        Y)
            echo $INPUT
            ;;
        Z)
            echo $(((INPUT+1) % 3))
            ;;
    esac
}

mapc(){
    CHAR=$1
    case $CHAR in
        A | X) 
            echo -n "0"
            ;;
        B | Y) 
            echo -n "1"
            ;;
        C | Z) 
            echo -n "2"
            ;;
     esac
}
export -f mapc

subtotals(){
    FILENAME=$1
    TOTAL=0
    STRATEGY=$2
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        IFS=' ' read -r INPUT_CHAR OUTPUT_CHAR <<< "$ENTRY"

        INPUT=$( mapc $INPUT_CHAR )
        if [ $STRATEGY -eq 0 ]; then
            OUTPUT=$( mapc $OUTPUT_CHAR )
        else
            OUTPUT=$( mapo $INPUT $OUTPUT_CHAR )
        fi

        RESULT="0"
        if [ "$INPUT" -eq "$OUTPUT" ]; then
            RESULT="3"
        elif [ $(((INPUT + 1) % 3)) -eq $OUTPUT ]; then
            RESULT="6"
        fi
        # +1 offsets 0 index of OUTPUT
        echo $((RESULT + OUTPUT + 1))
    done < "$FILENAME"
}

echo "## Part 1"
subtotals "challenge.txt" 0 | paste -s -d+ - | bc

echo "## Part 2"
subtotals "challenge.txt" 1 | paste -s -d+ - | bc
