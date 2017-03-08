#!/bin/bash

if [ -z "$PROJECT_DIR" ]; then
    echo "Please set PROJECT_DIR"
    exit 1
fi

readonly PROJECT_DIR="$PROJECT_DIR"
readonly DATA_DIR="$PROJECT_DIR/data"
readonly CSV_FILE_PATH="$DATA_DIR/endpoints.csv"
readonly ALL_PREFIX_CSV_PATH="$DATA_DIR/all_prefixes.csv"
readonly BULKDOWNLOADS_DIR="$DATA_DIR/bulkdownloads"