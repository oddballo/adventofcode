#!/bin/bash

docker run \
    -v "$(pwd):/opt/challenge" \
    -w "/opt/challenge" \
    --rm \
    -it bash:5.2.12 \
    time -v ./challenge.sh
