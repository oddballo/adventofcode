#!/usr/local/bin/bash

set -eou pipefail

isList(){
    local INPUT=$1
    if [[ "${INPUT:0:1}" != "[" ]]; then
        return 1
    fi
    nextValue "$INPUT"
    if [[ "$RETVAL" != "$INPUT" ]]; then
        return 1
    fi
    return 0
}

getContents(){
    local INPUT=$1
    RETVAL=${INPUT:1:$((${#INPUT}-2))}
}

isNumber(){
    local INPUT=$1
    local EXPRESSION='^[0-9]+$'
    if ! [[ $INPUT =~ $EXPRESSION ]] ; then
        return 1
    fi
    return 0
}

nextValue(){
    local INPUT=$1
    local COUNT_POSITION=0
    local COUNT_TOKEN=0
    local CHAR
    while read -n1 CHAR; do
        if [[ "$CHAR" == "[" ]]; then
            COUNT_TOKEN=$((COUNT_TOKEN+1))
        elif [[ "$CHAR" == "]" ]]; then
            COUNT_TOKEN=$((COUNT_TOKEN-1))
        elif [[ "$CHAR" == "," ]] && [ $COUNT_TOKEN -eq 0 ]; then
            break    
        fi
        COUNT_POSITION=$((COUNT_POSITION+1))
    done <<< "$INPUT"
    RETVAL="${INPUT:0:$COUNT_POSITION}"
    RETVAL2="${INPUT:$((COUNT_POSITION+1))}"
}

compare(){
    local A=$1
    local B=$2
    local IS_LIST_A IS_LIST_B VALUES_A VALUES_B A_SIZE B_SIZE REMAINING MIN

    # Check for empty
    if [ -z "$A" ] && [ -z "$B" ]; then
        return 3
    elif [ -z "$A" ]; then
        return 2
    elif [ -z "$B" ]; then
        return 1
    fi
    
    # Check for lists
    isList "$A" && IS_LIST_A=0 || IS_LIST_A=1
    isList "$B" && IS_LIST_B=0 || IS_LIST_B=1   
    if [[ $IS_LIST_A -eq 0 ]] && 
       [[ $IS_LIST_B -eq 0 ]]; then 
        getContents "$A"
        A=$RETVAL
        getContents "$B"
        B=$RETVAL

        compare "$A" "$B" || VAL=$?
        if [ $VAL -le 2 ]; then
            return $VAL
        fi  
    else
        # Split string into Array (A) 
        declare -a VALUES_A=()
        REMAINING="$A"
        while [ ${#REMAINING} -gt 0 ]; do
            nextValue "$REMAINING"
            if [ ! -z "$RETVAL" ]; then
                VALUES_A+=("$RETVAL")
            fi
            REMAINING="$RETVAL2"
        done
        
        # Split string into Array (B) 
        declare -a VALUES_B=()
        REMAINING="$B"
        while [ ${#REMAINING} -gt 0 ]; do
            nextValue "$REMAINING"
            if [ ! -z "$RETVAL" ]; then
                VALUES_B+=("$RETVAL")
            fi
            REMAINING="$RETVAL2"
        done

        A_SIZE=${#VALUES_A[@]}
        B_SIZE=${#VALUES_B[@]}
        if [ $A_SIZE -gt $B_SIZE ]; then
            MIN=$B_SIZE
        else
            MIN=$A_SIZE
        fi
        local i

        for (( i=0; i<$MIN; i++ )); do
            isNumber "${VALUES_A[$i]}" && IS_NUMBER_A=0 || IS_NUMBER_A=1
            isNumber "${VALUES_B[$i]}" && IS_NUMBER_B=0 || IS_NUMBER_B=1
            # If both lists, treat as such
            if [ $IS_NUMBER_A -ne 0 ] && [ $IS_NUMBER_B -ne 0 ]; then
                compare "${VALUES_A[$i]}" "${VALUES_B[$i]}" || VAL=$?
                if [ $VAL -le 2 ]; then
                    return $VAL
                fi  
            # Else if one is a number, convert to a single member list (A)
            elif [ $IS_NUMBER_A -ne 0 ]; then
                compare "${VALUES_A[$i]}" "[${VALUES_B[$i]}]" || VAL=$?
                if [ $VAL -le 2 ]; then
                    return $VAL
                fi  
            # Else if one is a number, convert to a single member list (B)
            elif [ $IS_NUMBER_B -ne 0 ]; then
                compare "[${VALUES_A[$i]}]" "${VALUES_B[$i]}" || VAL=$?
                if [ $VAL -le 2 ]; then
                    return $VAL
                fi  
            elif [ ${VALUES_A[$i]} -gt ${VALUES_B[$i]} ]; then
                return 1
            elif [ ${VALUES_A[$i]} -lt ${VALUES_B[$i]} ]; then
                return 2
            fi
            # If equal, we continue to the next item in the loop
        done
        # Having reviewed all items where there are pairs, now check
        # if the left list is bigger than the right list
        if [ $A_SIZE -gt $B_SIZE ]; then
            return 1
        elif [ $A_SIZE -lt $B_SIZE ]; then
            return 2
        fi
    fi
    # Return 3 indicates to continue searching; all matching up to now
    return 3
}

processFile(){
    local FILENAME=$1
    local COUNT=1
    local LINE1 LINE2 EMPTY
    while read LINE1 && read LINE2 && read EMPTY; do
        if [ -z "$LINE1" ] || [ -z "$LINE2" ]; then
            echo "Something wrong reading file. Aborting."
            exit 1
        fi
        compare "$LINE1" "$LINE2" || VAL=$?
        if [ $VAL -eq "2" ]; then
             echo "$COUNT"
        fi
        COUNT=$((COUNT+1))
    done < "$FILENAME"
}

echo "## Part 1"
processFile "data.txt" | paste -s -d+ - | bc 
