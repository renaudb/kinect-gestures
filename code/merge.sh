#!/bin/bash

FILES='files.txt'
FRAMES='frames.txt'

paste <(tr -d ' \t' < $FILES) <(tr -d ' \t' < $FRAMES) | column -s $'\t' -t | grep -v "\[\]"
