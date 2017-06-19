#!/bin/bash

if [ -z "$UMAKA_WEB_DIR" ]; then
    echo "Please set UMAKA_WEB_DIR"
    echo "export UMAKA_WEB_DIR=path/to/umakadata/web"
    exit 1
fi

readonly DATA_DIR="$UMAKA_WEB_DIR/data"
readonly CSV_FILE_PATH="$DATA_DIR/endpoints.csv"
readonly ALL_PREFIX_CSV_PATH="$DATA_DIR/all_prefixes.csv"
readonly BULKDOWNLOADS_DIR="$DATA_DIR/bulkdownloads"