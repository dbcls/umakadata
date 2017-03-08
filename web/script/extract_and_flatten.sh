#!/bin/bash

readonly DIR="${1:? dir name}"
cd ${DIR}

function extract_for_endpoint() {
    endpoint_dir=$(basename `pwd`)

    PRE_IFS=$IFS
    IFS=$'\n'
    archive=($(find ./ \( -name \*.gz -o -name \*.bz2 -o -name \*.Z -o -name \*.tgz -o -name \*.zip -o -name \*.tbz -o -name \*.tbz2 -o -name \*.gz2 -o -name \*.tar -o -name \*.xz \)))

    echo "archive file: ${#archive[*]}"
    for file_path in "${archive[@]}"; do
        echo "$file_path"
        filename_and_extention="${file_path##*/}"
        file_dir="${file_path%/*}"
        filename="${filename_and_extention%.*}"
        extention="${filename_and_extention##*.}"

        if [ "${filename##*.}" = "tar" ]; then
            case "$extention" in
                "gz" )  tar zxvf "$file_path" -C "$file_dir";;
                "bz2" ) tar jxf "$file_path" -C "$file_dir";;
                "Z" )   tar Zxf "$file_path" -C "$file_dir" ;;
            esac
        else
            case "$extention" in
                "tgz" )  tar zxvf "$file_path" -C "$file_dir" ;;
                "tbz2" ) tar jxf "$file_path" -C "$file_dir" ;;
                "tbz" )  tar Zxf "$file_path" -C "$file_dir" ;;
                "tar" )  tar xvf "$file_path" -C "$file_dir" ;;
                "zip" )  unzip -o "$file_path" -d "$file_dir" ;;
                "bz2" )
                    bunzip2 -f -k "$file_path"
                    ;;
                "gz" )
                    gunzip -f -k "$file_path"
                    ;;
                "Z" )
                    uncompress -f "$file_path"
                    ;;
                "xz" )
                    unxz -f -k "$file_path"
                    ;;
                # "lzh" ) lha e "$file_path" ;;
                # "arj" ) unarj "$file_path" ;;
            esac
        fi
    done

    extracted=($(find ./ \( -name \*.rdf -o -name \*.rdfs -o -name \*.owl -o -name \*.xml -o -name \*.nt -o -name \*.ttl -o -name \*.n3 -o -name \*.xml -o -name \*.trix -o -name \*.trig -o -name \*.brf -o -name \*.nq -o -name \*.jsonld -o -name \*.rj -o -name \*.xhtml -o -name \*.html \)))

    echo "exteracted file: ${#extracted[*]}"
    i=1
    for file in "${extracted[@]}"; do
        filename_and_extention="${file##*/}"
        file_dir="${file%/*}"
        filename="${filename_and_extention%.*}"
        extention="${filename_and_extention##*.}"
        num=$(printf '%06d' $i)
        from=$file
        to=${endpoint_dir}_${num}.${extention}
        echo -e "${from}\t${to}" >> ./.rename
        mv ${from} ./${to}
        i=$(($i+1))
    done

    IFS=$PRE_IFS
}

if [ $# = 1 ]; then
    name=$1
    echo "$name"
    extract_for_endpoint "$name"
else
    echo "1 argument is required"
fi

