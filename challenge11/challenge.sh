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
MOD=1

loadRules(){
    local FILENAME=$1
    local COUNT=0
    local ENTRY
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
            MOD=$((MOD * TESTS[$COUNT]))
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

process(){
    local FILENAME=$1
    local LOOP=$2
    local REDUCE=${3:-}
    local i j ITEM VALUE1 VALUE2 OPERATOR WORRY
    loadRules "$FILENAME"
    for (( i=0; i<$LOOP; i++ )); do
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
                case "$OPERATOR" in
                    "*")
                        WORRY=$((VALUE1 * VALUE2))
                        ;;
                    "+")
                        WORRY=$((VALUE1 + VALUE2))
                        ;;
                esac
                if [ ! -z "$REDUCE" ]; then
                    WORRY=$((WORRY / 3))
                fi
                WORRY=$((WORRY % MOD))
                MONKEY_TRUE=${ACTION_CONDITION_TRUE[$j]}
                MONKEY_FALSE=${ACTION_CONDITION_FALSE[$j]}
                if [ $((WORRY % TESTS[$j])) -eq 0 ]; then
                    ITEMS[$MONKEY_TRUE]="${ITEMS[$MONKEY_TRUE]},$WORRY"
                else
                    ITEMS[$MONKEY_FALSE]="${ITEMS[$MONKEY_FALSE]},$WORRY"
                fi
                ((EVALUATIONS[$j]+=1))
            done
            ITEMS[$j]=""
        done
    done

    for (( i=0; i<${#EVALUATIONS[@]}; i++ )); do
        echo "${EVALUATIONS[$i]}"
    done
}

echo "## Part 1"
process "data.txt" "20" "reduce" | sort -n -k1 -r | head -n 2 | paste -s -d* - | bc 
echo "## Part 2"
process "data.txt" "10000" | sort -n -k1 -r | head -n 2 | paste -s -d* - | bc 
