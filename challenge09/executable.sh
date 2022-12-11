#!/usr/local/bin/bash

set -eou pipefail

FILENAME="$1"
KNOTS="$2"

declare -a X
declare -a Y
declare -a UBOUNDX
declare -a LBOUNDX
declare -a UBOUNDY
declare -a LBOUNDY

updateBound(){
    local PART=$1
    UBOUNDX[$PART]=$((X[$PART]+1))
    LBOUNDX[$PART]=$((X[$PART]-1))
    UBOUNDY[$PART]=$((Y[$PART]+1))
    LBOUNDY[$PART]=$((Y[$PART]-1))
}

updateNextKnot(){
    local PART=$1
    local NEXT_PART=$((PART+1))
    if [ $NEXT_PART -ge $KNOTS ]; then
        echo "Something went wrong. Aborting"
        exit 1
    fi

    if [ ${X[$PART]} -gt ${UBOUNDX[$NEXT_PART]} ] ||
        [ ${X[$PART]} -lt ${LBOUNDX[$NEXT_PART]} ] || 
        [ ${Y[$PART]} -gt ${UBOUNDY[$NEXT_PART]} ] || 
        [ ${Y[$PART]} -lt ${LBOUNDY[$NEXT_PART]} ]; then

        if [ ${Y[$PART]} -gt ${Y[$NEXT_PART]} ]; then
            Y[$NEXT_PART]=$((Y[$NEXT_PART]+1))
        elif [ ${Y[$PART]} -lt ${Y[$NEXT_PART]} ]; then
            Y[$NEXT_PART]=$((Y[$NEXT_PART]-1))
        fi

        if [ ${X[$PART]} -gt ${X[$NEXT_PART]} ]; then
            X[$NEXT_PART]=$((X[$NEXT_PART]+1))
        elif [ ${X[$PART]} -lt ${X[$NEXT_PART]} ]; then
            X[$NEXT_PART]=$((X[$NEXT_PART]-1))
        fi

        updateBound $NEXT_PART
    fi
}
U(){
    Y[0]=$((Y[0]+1))
}
D(){
    Y[0]=$((Y[0]-1))
}
L(){
    X[0]=$((X[0]-1))
}
R(){
    X[0]=$((X[0]+1))
}

KEY_LAST=$((KNOTS-1))
for (( i=0; i<$KNOTS; i++ )); do
    X[$i]=0
    Y[$i]=0
    updateBound $i
done

while read -r ENTRY; do
    if [ -z "$ENTRY" ]; then
        continue
    fi
    IFS=" " read COMMAND COUNT <<< "$ENTRY"
    for (( i=0; i<$COUNT; i++ )); do
        $COMMAND
        for (( j=0; j < $((KNOTS-1)); j++ )); do
            updateNextKnot $j
        done
        echo "${X[$KEY_LAST]},${Y[$KEY_LAST]}"
    done
done < "$FILENAME"
