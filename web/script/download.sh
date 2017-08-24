#!/bin/bash

. ./script/config.sh
. ./script/utils.sh

function download_for_all_endpoints() {
    PRE_IFS=$IFS
    IFS=$'\n'
    for line in `cat $CSV_FILE_PATH | awk 'NR > 1 {print}'`
    do
        download_url=`echo ${line} | cut -d ',' -f 4`
        if [ $(echo $download_url | grep -e 'http://' -e 'https://' -e 'ftp://') ]; then
            name=`echo ${line} | cut -d ',' -f 2`
            download_for_endpoint "$name" "$download_url"
        fi
    done
    IFS=$PRE_IFS
}

function download_for_endpoint() {
    downloads_dir="$BULKDOWNLOADS_DIR/$1/downloads"
    mkdir -p "$downloads_dir"
    case "$2" in
        *eagle*i*)
            wget -nv -e robots=off -np -O "$downloads_dir/sparql.rdf" "$2";;
        *)
            wget -nv -e robots=off -np -r -N -P "$downloads_dir" "$2";;
    esac
}

if [ $# = 0 ]; then
    download_for_all_endpoints
elif [ $# = 1 ]; then
    name=$1
    echo "$name"
    download_url=`search_download_url "$name"`
    if [ -n "${download_url}" ]; then
        download_for_endpoint "$name" "$download_url"
    fi
else
    echo "1 argument is required"
fi
