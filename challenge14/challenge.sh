#!/usr/local/bin/bash

set -eou pipefail

declare -a GRID=()
WIDTH=0
HEIGHT=0
STARTX=0
STARTY=0

process(){
    local FILENAME=$1 TYPE=$2 MINX="" MINY="0" MAXX="" MAXY="" LASTX LASTY AX BX AY BY COORDINATES LINE i j
    
    # Determine bounds
    while read LINE; do
        IFS="-" read -a COORDINATES <<< "$LINE"
        for COORDINATE in "${COORDINATES[@]}"; do
            IFS="," read X Y <<< "$COORDINATE"
            if [ -z "$MINX" ] || [ "$X" -lt "$MINX" ]; then
                MINX="$X"
            fi
            if [ -z "$MINY" ] || [ "$Y" -lt "$MINY" ]; then
                MINY="$Y"
            fi
            if [ -z "$MAXX" ] || [ "$X" -gt "$MAXX" ]; then
                MAXX="$X"
            fi
            if [ -z "$MAXY" ] || [ "$Y" -gt "$MAXY" ]; then
                MAXY="$Y"
            fi
        done
    done <<< "$(sed 's/ -> /-/g' < "$FILENAME")"
    
    # Augment to allow for "infinite floor"
    MAXY=$((MAXY+2))

    HEIGHT=$((MAXY-MINY+1))
   
    # Augment to allow for pyramid 
    MAXX=$((MAXX+HEIGHT))
    MINX=$((MINX-HEIGHT))

    WIDTH=$((MAXX-MINX+1))
    STARTX=$((500-MINX))
    STARTY=0

    # Set grid to empty
    initalizeGrid
    setCell "$STARTX" "$STARTY" "+"    
    
    # Populate Walls
    while read LINE; do
        IFS="-" read -a COORDINATES <<< "$LINE"

        LASTX=""
        LASTY=""
        for COORDINATE in "${COORDINATES[@]}"; do
            IFS="," read X Y <<< "$COORDINATE"
            X=$((X-MINX))
            Y=$((Y-MINY))
            if [ -z "$LASTX" ]; then
                LASTX=$X
                LASTY=$Y
                continue
            fi
            AX=""
            AY=""
            BX=""
            BY=""
            if [[ $LASTX -eq $X ]]; then
                AX=$X
                BX=$X
                if [[ $LASTY -lt $Y ]]; then
                    AY=$LASTY
                    BY=$Y    
                else
                    BY=$LASTY
                    AY=$Y    
                fi
            else
                AY=$Y
                BY=$Y
                if [[ $LASTX -lt $X ]]; then
                    AX=$LASTX
                    BX=$X
                else
                    BX=$LASTX
                    AX=$X
                fi
            fi
    
            for (( i=$AX; i<=$BX; i++ )); do
                for (( j=$AY; j<=$BY; j++ )); do
                    setCell $i $j "#"
                done
            done

            LASTX=$X
            LASTY=$Y
        done
    done <<< "$(sed 's/ -> /-/g' < "$FILENAME")"
    
    if [ "$TYPE" -eq "1" ]; then
        j=$((HEIGHT-1))
        for (( i=0; i<=$WIDTH; i++ )); do
            setCell $i $j "#"
        done
    fi
}
printGrid(){
    for (( i=0; i<$HEIGHT; i++ )); do
        for (( j=0; j<$WIDTH; j++ )); do
            getCell "$j" "$i" "."
            echo -n "$RETVAL"
        done
        echo
    done
}

initalizeGrid(){
    for (( i=0; i<$HEIGHT; i++ )); do
        for (( j=0; j<$WIDTH; j++ )); do
            setCell "$j" "$i" "."
        done
    done
}
setCell(){
    local X=$1
    local Y=$2
    local VALUE=$3
    GRID[$(((Y*WIDTH)+X))]=$VALUE
}
getCell(){
    local X=$1
    local Y=$2
    RETVAL=${GRID[$(((Y*WIDTH)+X))]}
}

checkBounds(){
    local X=$1
    local Y=$2
    if [ $X -lt 0 ] ||
        [ $X -ge $WIDTH ] ||
        [ $Y -lt 0 ] ||
        [ $Y -ge $HEIGHT ]; then
        return 1
    fi
    return 0
}

drop(){
    local TYPE=$1
    local X=$STARTX
    local Y=$STARTY
    local DOWNX DOWNY LEFYX LEFTY RIGHTX RIGHTY YI
   
    while true; do

        YI=$((Y+1))
        DOWNX=$X
        DOWNY=$YI
        [ "$TYPE" -ne 1 ] && { checkBounds $DOWNX $DOWNY || return 1; }
        getCell $DOWNX $DOWNY
        CELL="$RETVAL"
        if [[ $RETVAL == "." ]]; then
            X=$DOWNX
            Y=$DOWNY
            continue
        fi
        
        LEFTX=$((X-1))
        LEFTY=$YI
        #checkBounds $LEFTX $LEFTY || return 1
        [ "$TYPE" -ne 1 ] && { checkBounds $LEFTX $LEFTY || return 1; }
        getCell $LEFTX $LEFTY
        if [[ $RETVAL == "." ]]; then
            X=$LEFTX
            Y=$LEFTY
            continue
        fi
        
        RIGHTX=$((X+1))
        RIGHTY=$YI
        [ "$TYPE" -ne 1 ] && { checkBounds $RIGHTX $RIGHTY || return 1; }
        getCell $RIGHTX $RIGHTY
        if [[ $RETVAL == "." ]]; then
            X=$RIGHTX
            Y=$RIGHTY
            continue
        fi

        break
    done
    if [ $X -eq $STARTX ] && [ $Y -eq $STARTY ]; then
        return 1
    fi
    setCell $X $Y "O"
}

echo "## Part 1"
process "data.txt" 0
COUNT=0
while true; do
    drop 0 || break
    COUNT=$((COUNT+1))
done
echo $COUNT

echo "## Part 2"
process "data.txt" 1
COUNT=0
while true; do
    drop 1 || break
    COUNT=$((COUNT+1))
done
echo $((COUNT+1))
