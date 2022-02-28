#!/bin/bash
shopt -s globstar nullglob dotglob
for filename in **/*/drawable*/*; do
    file=$(basename ${filename%.*})
    echo $file
    res=$(ack -hc ${file%.*})
    if [ "$res" == "0" ]; then
        rm $filename
    fi
done

