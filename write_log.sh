#!/bin/bash

function log_start_session(){
    echo -e "[INFO] BaWaB{ [\"Backup\", ["$(date '+%Y-%m-%d %H:%M:%S')"]],"
}

function log_dir_safed(){
    elements=("$@")
    echo -n "Elements safed={"
    for element in "${elements[@]}"; do
        echo -n $element ", "
    done
    echo "},"
}

function log_end_session(){
    echo -n "}"
    echo -e '\t '
}

function log_element_removed(){
    echo Element removed: "{{ $1 }, reason=7th element},"
}

function log_already_exists(){
    if [ "$1" = "e" ]; then
        echo "Backup: already exists"
    else
        echo "Backup: doesnt exist,"
    fi
}

function log_called_from(){
    if [ -z "$1" ]; then
        echo "Called by: $USER,"
    else
        echo "Called by: Crontab,"
    fi
}

function log_backup_element_exception(){
    echo "Failed to backup element \"${1}\". Reason:Folder doesn't exist."
}

