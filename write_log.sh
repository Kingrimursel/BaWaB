#!/bin/bash

function log_start_session(){
    echo -e "[INFO] BaWaB{ [\"Backup\", ["$(date '+%Y-%m-%d %H:%M:%S')"]], "
}

function log_dir_safed(){
    folders=("$@")
		echo -n "Directories safed={"
    for element in "${folders[@]}"; do
		    echo -n $element ", "
		done
		echo "}, "
}

function log_end_session(){
    echo -n "}"
		echo -e '\t '
}

function log_dir_removed(){
    echo Directory removed: "{{ $1 }, reason=7th element}, "
}

function log_already_exists(){
    if [ "$1" = "e" ]; then
        echo "Backup: already exists "
    else 
		    echo "Backup: doesnt exist, "
		fi
}

function log_called_from(){
    if [ -z "$1" ]; then
		    echo "Called by: $USER,  "
		else
		    echo "Called by: Crontab,  "
		fi
}

function log_backup_folder_exception(){
    echo "Failed to backup folder \"${1}\". Reason:Folder doesn't exist."
}

