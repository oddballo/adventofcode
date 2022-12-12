#!/usr/local/bin/bash

set -eou pipefail

declare -a MAP
HEIGHT=-1
WIDTH=-1
STARTX=-1
STARTY=-1
FINISHX=-1
FINISHY=-1
declare -a COORDINATES
declare -a SCORES
A=$(printf '%d\n' "'a")

loadMap(){
    local FILENAME=$1
    read -r LINE < "$FILENAME"
    WIDTH=${#LINE}
    
    local COUNT=0   
    HEIGHT=0 
    while read -r ENTRY; do
        if [ -z "$ENTRY" ]; then
            continue
        fi
        while read -r -n1 CHAR; do
            if [ -z "$CHAR" ]; then
                continue
            fi
            if [[ "$CHAR" == "S" ]]; then
                convertToXCoordinate $COUNT
                STARTX=$RETVAL
                convertToYCoordinate $COUNT
                STARTY=$RETVAL
                MAP[$COUNT]=$(printf '%d\n' "'a")
            elif [[ "$CHAR" == "E" ]]; then
                convertToXCoordinate $COUNT
                FINISHX=$RETVAL
                convertToYCoordinate $COUNT
                FINISHY=$RETVAL
                MAP[$COUNT]=$(printf '%d\n' "'z")
            else
                MAP[$COUNT]=$(printf '%d\n' "'$CHAR")
            fi
            COUNT=$((COUNT+1))
        done <<< "$ENTRY"
        HEIGHT=$((HEIGHT+1))
    done < "$FILENAME"
}

convertToXCoordinate(){
    local FULL=$1
    RETVAL=$((FULL%WIDTH))
}
convertToYCoordinate(){
    local FULL=$1
    RETVAL=$((FULL/WIDTH))
}

loadScore(){
    local i
    for (( i=0; i<$((HEIGHT*WIDTH)); i++)); do
        SCORES[$i]=-1
    done
    setScore $STARTX $STARTY 0
}
getCoordinate(){
    local X=$1
    local Y=$2
    RETVAL="${MAP[$(((Y*WIDTH)+X))]}"
}
getScore(){
    local X=$1
    local Y=$2
    RETVAL="${SCORES[$(((Y*WIDTH)+X))]}"
}
setScore(){
    local X=$1
    local Y=$2
    local SCORE=$3
    SCORES[$(((Y*WIDTH)+X))]=$SCORE
}
checkCell(){
    local NEW_SCORE=$1
    local COMING_FROM=$2
    local X=$3
    local Y=$4
    local RULE=$5
    local VALUE
    getCoordinate $X $Y
    VALUE=$RETVAL
    getScore $X $Y
    SCORE=$RETVAL

    if [[ "$RULE" == "part2" ]] &&
       [[ "$VALUE" == "$A" ]]; then
        NEW_SCORE=0
    fi

    if [ $((VALUE-1)) -le $COMING_FROM ] &&
        { [ $SCORE -eq '-1' ] || [ $NEW_SCORE -lt $SCORE ]; }; then
        setScore $X $Y $NEW_SCORE
        COORDINATES+=("$X,$Y")
    fi
}
printMap(){
    local i
    local j
    for (( i=0; i<$HEIGHT; i++ )); do
        for (( j=0; j<$WIDTH; j++ )); do
            printf "|%3d" "${SCORES[$(((WIDTH*i)+j))]}"
        done
        echo
    done
}
process(){
    local FILENAME="$1"
    local RULE="$2"
    loadScore
    COORDINATES+=("$STARTX,$STARTY")
    while [ "${#COORDINATES[@]}" -gt 0 ]; do
        XY=${COORDINATES[0]}
        IFS="," read X Y <<< $XY
        getCoordinate $X $Y
        VALUE=$RETVAL
        
        getScore $X $Y
        NEW_SCORE="$(($RETVAL+1))"

        if [ $((X+1)) -lt $WIDTH ]; then
            checkCell $NEW_SCORE $VALUE $((X+1)) $((Y)) $RULE
        fi
        if [ $((X-1)) -ge 0 ]; then
            checkCell $NEW_SCORE $VALUE $((X-1)) $((Y)) $RULE
        fi
        if [ $((Y+1)) -lt $HEIGHT ]; then
            checkCell $NEW_SCORE $VALUE $((X)) $((Y+1)) $RULE
        fi
        if [ $((Y-1)) -ge 0 ]; then
            checkCell $NEW_SCORE $VALUE $((X)) $((Y-1)) $RULE
        fi
        COORDINATES=("${COORDINATES[@]:1}")
    done
    getScore $FINISHX $FINISHY
    echo "$RETVAL"
}

loadMap "data.txt"
echo "## Part 1"
process "data.txt" "part1"
echo "## Part 2"
process "data.txt" "part2"

