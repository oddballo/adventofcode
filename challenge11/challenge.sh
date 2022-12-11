#!/usr/local/bin/bash

set -eou pipefail

declare -a ITEMS
declare -a OPERATION_VALUE_1
declare -a OPERATION_OPERATOR
declare -a OPERATION_VALUE_2
declare -a TESTS
declare -a ACTION_CONDITION_TRUE
declare -a ACTION_CONDITION_FALSE
declare -a EVALUATIONS

loadRules(){
    local FILENAME=$1
    local COUNT=0
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi

        # Detected monkey
        if [[ "${ENTRY:0:7}" == "Monkey " ]]; then
            # Load items
            read ENTRY
            ITEMS[$COUNT]=$(sed 's/[^0-9,]*//g' <<< "$ENTRY")
            # Load Opertaion
            read ENTRY
            IFS=" " read OPERATION_VALUE_1[$COUNT] \
                OPERATION_OPERATOR[$COUNT] \
                OPERATION_VALUE_2[$COUNT] \
                <<< "$(cut -f2 -d"=" <<< "$ENTRY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            # Load Test
            read ENTRY
            TESTS[$COUNT]=$(sed 's/[^0-9,]*//g' <<< "$ENTRY")
            # Load Action Condition when True
            read ENTRY
            ACTION_CONDITION_TRUE[$COUNT]=$(sed 's/[^0-9,]*//g' <<< "$ENTRY")
            # Load Action Condition when False
            read ENTRY
            ACTION_CONDITION_FALSE[$COUNT]=$(sed 's/[^0-9,]*//g' <<< "$ENTRY")
            # Initalize evaluations
            EVALUATIONS[$COUNT]=0
            

            COUNT=$((COUNT+1))        
        fi
    done < "$FILENAME"
}

#    printf '%s\n' "${ITEMS[@]}"
#    printf '%s\n' "${OPERATION_VALUE_1[@]}"
#    printf '%s\n' "${OPERATION_VALUE_2[@]}"
#    printf '%s\n' "${OPERATION_OPERATOR[@]}"
#    printf '%s\n' "${TESTS[@]}"
#    printf '%s\n' "${ITEMS[@]}"
#    printf '%s\n' "${ACTION_CONDITION_TRUE[@]}"
#    printf '%s\n' "${ACTION_CONDITION_FALSE[@]}"

process(){
    FILENAME=$1
    loadRules "$FILENAME"
    for (( i=0; i<20; i++ )); do
        for (( j=0; j<${#TESTS[@]}; j++)); do
            for ITEM in ${ITEMS[$j]//,/ }; do
                if [ -z "$ITEM" ]; then
                    continue
                fi

                VALUE1=${OPERATION_VALUE_1[$j]}
                VALUE2=${OPERATION_VALUE_2[$j]}
                OPERATOR=${OPERATION_OPERATOR[$j]}
                if [[ "$VALUE1" == "old" ]]; then
                    VALUE1=$ITEM
                fi
                if [[ "$VALUE2" == "old" ]]; then
                    VALUE2=$ITEM
                fi
                WORRY=$(echo "($VALUE1 $OPERATOR $VALUE2) / 3" | bc)
                MONKEY_TRUE=${ACTION_CONDITION_TRUE[$j]}
                MONKEY_FALSE=${ACTION_CONDITION_FALSE[$j]}
                if [ $((WORRY % TESTS[$j])) -eq 0 ]; then
                    ITEMS[$MONKEY_TRUE]="${ITEMS[$MONKEY_TRUE]},$WORRY"
                else
                    ITEMS[$MONKEY_FALSE]="${ITEMS[$MONKEY_FALSE]},$WORRY"
                fi
                EVALUATIONS[$j]=$((EVALUATIONS[$j]+1))
            done
            ITEMS[$j]=""
        done
    done

    for (( i=0; i<${#EVALUATIONS[@]}; i++ )); do
        echo "${EVALUATIONS[$i]},Monkey $((i+1))"
    done
}

process "data.txt" | sort -t, -k1n,1 | tail -n 2 | cut -f1 -d"," | paste -s -d* - | bc 
