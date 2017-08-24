#!/bin/bash

function search_download_url() {
    PRE_IFS=$IFS
    IFS=$'\n'
    for line in `cat $CSV_FILE_PATH | awk 'NR > 1 {print}' | grep -v ^#`
    do
        name=`echo ${line} | cut -d ',' -f 2`
        if [ "$1" = "$name" ]; then
            download_url=`echo ${line} | cut -d ',' -f 4`
            echo $download_url
        fi
    done
    IFS=$PRE_IFS
}
