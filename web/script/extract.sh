#!/bin/bash

. ./script/config.sh
. ./script/utils.sh

function extract_for_endpoint() {
    endpoint_dir="$BULKDOWNLOADS_DIR/$1"
    mkdir -p "$endpoint_dir/extractions"

    PRE_IFS=$IFS
    IFS=$'\n'
    array=($(find $endpoint_dir \( -name \*.gz -o -name \*.bz2 -o -name \*.Z -o -name \*.tgz -o -name \*.zip -o -name \*.tbz -o -name \*.tbz2 -o -name \*.gz2 -o -name \*.tar -o -name \*.xz \)))

    echo "archive file: ${#array[*]}"
    for file_path in "${array[@]}"; do
        echo "$file_path"
        filename_and_extention="${file_path##*/}"
        file_dir="${file_path%/*}"
        filename="${filename_and_extention%.*}"
        extention="${filename_and_extention##*.}"
        change_dir=`echo $file_dir | sed "s/$1\\/downloads/$1\\/extractions/g"`
        mkdir -p "$change_dir"

        if [ "${filename##*.}" = "tar" ]; then
            case "$extention" in
                "gz" )  tar zxvf "$file_path" -C "$change_dir" ;;
                "bz2" ) tar jxf "$file_path" -C "$change_dir" ;;
                "Z" )   tar Zxf "$file_path" -C "$change_dir" ;;
            esac
        else
            case "$extention" in
                "tgz" )  tar zxvf "$file_path" -C "$change_dir" ;;
                "tbz2" ) tar jxf "$file_path" -C "$change_dir" ;;
                "tbz" )  tar Zxf "$file_path" -C "$change_dir" ;;
                "tar" )  tar xvf "$file_path" -C "$change_dir" ;;
                "zip" )  unzip -o "$file_path" -d "$change_dir" ;;
                "bz2" )
                    bunzip2 -f -k "$file_path"
                    mv "$file_dir/$filename" "$change_dir"
                    ;;
                "gz" )
                    gunzip -f -k "$file_path"
                    mv "$file_dir/$filename" "$change_dir"
                    ;;
                "Z" )
                    uncompress -f "$file_path"
                    mv "$file_dir/$filename" "$change_dir"
                    ;;
                "xz" )
                    unxz -f -k "$file_path"
                    mv "$file_dir/$filename" "$change_dir"
                    ;;
                # "lzh" ) lha e "$file_path" ;;
                # "arj" ) unarj "$file_path" ;;
            esac
        fi
    done
    IFS=$PRE_IFS
}

if [ $# = 1 ]; then
    name=$1
    echo "$name"
    download_url=`search_download_url "$name"`
    if [ -n "${download_url}" ]; then
        extract_for_endpoint "$name"
    fi
else
    echo "1 argument is required"
fi
