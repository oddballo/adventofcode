#!/usr/local/bin/bash

set -eou pipefail

duty(){
    local X=$1
    local C=$2

    # Question asks for value "during" cycle 20,
    # so need to act on the value "after" cycle 19
    # whilst treating the cycle number as 20 for the
    # math 
    if [ $(((C - 19) % 40)) -eq 0 ]; then
        echo $((X*$((C+1))))
    fi
}

dutyd(){
    local X=$1
    local C=$2

    if [ $((C % 40)) -ge $((X-1)) ] &&
       [ $((C % 40)) -le $((X+1)) ]; then
        echo -n "#"
    else
        echo -n "."
    fi

    if [ $((C % 40)) -eq 0 ]; then
        echo
    fi
}

cycles(){
    FILENAME=$1
    DUTY=$2
    C=0
    X=1

    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi

        IFS=" " read -r COMMAND VALUE <<< "$ENTRY"

        STEPS=0
        case "$COMMAND" in
            "noop")
                STEPS=1
                ;;
            "addx")
                STEPS=2
        esac

        for (( i=1; i<$STEPS; i++ )); do
            C=$((C+1))
            $DUTY $X $C
        done

        C=$((C+1))
        if [[ "$COMMAND" == "addx" ]];then
             X=$((X+VALUE))
        fi
        $DUTY $X $C
        
    done < "$FILENAME"

}

echo "## Part 1"
cycles "data.txt" "duty" | paste -s -d+ - | bc

echo "## Part 2"
cycles "data.txt" "dutyd"
