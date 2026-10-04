#!/bin/bash

SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}

if [ -z $SOURCE_DIR ] || [ -z $DEST_DIR ]; then
    echo "Either source direcotry or Destination directory is empty"
    echo "[USAGE:] $0 [source directory] [Destination directory] [Days: default 14]"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory $SOURCE_DIR does not exists"
fi

if [ ! -d "$DEST_DIR" ]; then
    echo "Destination directory $DEST_DIR does not exists"
fi

FILES=$(find "$SOURCE_DIR" -name "*.log" -type f -mtime +"$DAYS")

if [ -z "$FILES" ]; then
    echo "Files older than 14 days are not found... Nothing to do"
    exit 0
fi

while IFS= read -r FILE
do
    echo "$FILE"
done <<< "$FILES"


