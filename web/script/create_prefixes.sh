#!/bin/bash

. ./script/config.sh
. ./script/utils.sh

function create_prefixes_all_endpoints() {
    PRE_IFS=$IFS
    IFS=$'\n'
    for line in `cat $CSV_FILE_PATH | awk 'NR > 1 {print}'`
    do
        download_url=`echo ${line} | cut -d ',' -f 4`
        if [ $(echo $download_url | grep -e 'http://' -e 'https://' -e 'ftp://') ]; then
            name=`echo ${line} | cut -d ',' -f 2`
            create_prefixes_endpoint "$name"
        fi
    done
    IFS=$PRE_IFS
}

function create_prefixes_endpoint() {
    echo "<<<$1"
    /bin/bash "$UMAKA_WEB_DIR/script/extract.sh" "$1"
    sbt "runMain sbmeta.SBMeta \"$BULKDOWNLOADS_DIR/$1\""
    rm -rf "$BULKDOWNLOADS_DIR/$1/extractions"
    echo "<<<$1"
}

if [ $# = 0 ]; then
    create_prefixes_all_endpoints
elif [ $# = 1 ]; then
    name=$1
    download_url=`search_download_url "$name"`
    if [ -n "${download_url}" ]; then
        create_prefixes_endpoint "$name"
    fi
else
    echo "0 or 1 argument is required"
fi
