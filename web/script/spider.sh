#!/bin/bash

. ./script/config.sh
. ./script/utils.sh

function retrieve_for_all_endpoints() {
    PRE_IFS=$IFS
    IFS=$'\n'
    for line in `cat $CSV_FILE_PATH | awk 'NR > 1 {print}'`
    do
        download_url=`echo ${line} | cut -d ',' -f 4`
        if [ $(echo $download_url | grep -e 'http://' -e 'https://' -e 'ftp://') ]; then
            name=`echo ${line} | cut -d ',' -f 2`
            retrieve_for_endpoint "$name" "$download_url"
        fi
    done
    IFS=$PRE_IFS
}

function retrieve_for_endpoint() {
    echo "<<<$1"
    downloads_dir="$DATA_DIR/download_file_info"
    mkdir -p "$downloads_dir"

    logfile="$downloads_dir/$1_$(date "+%y%m%d%H%M").log"
    wget --spider -r -nd -e robots=off -np -N "$2" 2> "$logfile"
    sum_content_length "$1" "$logfile"
    echo ">>>$1"
}

function sum_content_length() {
    sum=`cat "$2" |grep -e "Length:" |sed -e "s/^Length:\ \([0-9]\{1,\}\).*$/\1/g" | awk '{sum+=$1}END{print sum}'`
    if [ -n "${sum}" ]; then
        echo "$1,`expr $sum / 1000 / 1000 / 1000`GB" >> "$DATA_DIR/download_size.csv"
    else
        echo "$1,N/A" >> "$DATA_DIR/download_size.csv"
    fi
}

if [ $# = 0 ]; then
    retrieve_for_all_endpoints
elif [ $# = 1 ]; then
    name=$1
    echo "$name"
    download_url=`search_download_url "$name"`
    if [ $(echo $download_url | grep -e 'http://' -e 'https://') ]; then
        retrieve_for_endpoint "$name" "$download_url"
    fi
else
    echo "1 argument is required"
fi
