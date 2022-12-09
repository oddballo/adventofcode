#!/usr/local/bin/bash

echo "## Part 1"
./executable.sh "data.txt" 2 | sort | uniq | wc -l

echo "## Part 2"
./executable.sh "data.txt" 10 | sort | uniq | wc -l

