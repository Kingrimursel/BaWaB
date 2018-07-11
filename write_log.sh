#!/bin/bash

function start_session(){
    echo -e "[INFO] BaWaB{ [\"Backup\", ["$(date '+%Y-%m-%d %H:%M:%S')"]], "
}

function dir_safed(){
    folders=("$@")
		echo -n "Directories safed={"
    for element in "${folders[@]}"; do
		    echo -n $element ", "
		done
		echo "}, "
}

function end_session(){
    echo -n "}"
		echo -e '\t '
}

function dir_removed(){
    echo Directory removed: "{{ $1 }, reason=7th element}, "
}

function notify_send(){
    echo "Notification: send."
}

function already_exists(){
    if [ "$1" = "e" ]; then
        echo "Backup: already exists "
    else 
		    echo "Backup: doesnt exist, "
		fi
}

function called_from(){
    if [ -z "$1" ]; then
		    echo "Called by: $USER,  "
		else
		    echo "Called by: Crontab,  "
		fi
}

function backup_folder_exception(){
    echo "Failed to backup folder \"${1}\". Reason:Folder doesn't exist."
}
