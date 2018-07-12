#!/bin/bash

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# This program makes Backups of as much and any directories you want and safes them into a choosable destination directory. It also limits the number of Backups safed, so it deletes the oldest one if it tries to create a new one and notices that the limit is already reached.

# If you want to run this script from crontab, you have to set the enviroment variables "DISPLAY" and "DBUS_SESSION_BUS_ADDRESS" in order to be notified when the Backup was made. They are already set(Ubuntu 18.04), but in case it doesn't work for you you'll have to change them. 

# OPTIONAL CHANGES
# If you want to change the limit of kept backups at once, change "$saving_limit" to whatever you want.
# To manipulate the destination folder for the backups, change "$destination_folder".

# REQUIRED CHANGES
# To manipulate the folders that should be backed up, change "$backup_folders".

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# EXTERNAL VARIABLES
#---------------------------------------------------------------------------------------------------------------#
# SHELL variable for cron
SHELL=/bin/bash

# PATH variable for cron
PATH=/usr/local/bin:/usr/local/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/bin/X11

#---------------------------------------------------------------------------------------------------------------#
# Confirm installation
if [ -z "$installed" ]; then
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "${RED}Failed to run BaWaB, reason: The program is not installed yet.${NC}"
    sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup error" "Didn't properly install BaWaB yet."
    exit 1
fi

# Setting up the log file

# Logging
log_start_session
log_called_from $1

# Declaring the array containing the Directories that should be backed up.
declare -a backup_folders=("path/to/directory/one" "path/to/directory/two")

# Declaring the folder where the Backups should be stored.

# Setting the maximun number of backups beeing safed at once.
saving_limit=7

date=$(date '+%Y-%m-%d')

# Getting the number of existing backups.
num_elements=$(ls -lR "${destination_folder}"/| grep ^d | wc -l)

# If the queued Backup doesn't exist, keep going
if [ ! -d "${destination_folder}"/BACKUP-"${date}" ]; then
    
    # Logging
    log_already_exists "n"
    
    # Checking of the existing number of Backups is equal to the maximum you want. If you want another limit, change the '7' to your preferenced number.
    if (($num_elements == $saving_limit)); then
        # Remove the oldest Backup
	oldest="$(ls -1t "${destination_folder}"/| tail -1)"
	rm -r "${destination_folder}"/${oldest}
	#Logging
	log_dir_removed $oldest
    fi

    # Create a new Backup folder
    mkdir "${destination_folder}"/BACKUP-"${date}"
    
    # tar and gzip the directories that should be backed up and safe them.
    for folder in "${backup_folders[@]}"; do
        if [ -d $folder ]; then
	    tar -C ${folder%/*} -czf "${destination_folder}"/BACKUP-"${date}"/${folder##*/}.tar.gz ${folder##*/}
	else
	    # Sending a notification
	    sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup error" "BaWaB: Folder \"${folder}\" doesn't exist."
	    # Logging
	    log_backup_folder_exception $folder
	    # Removing bad folder from array
            for i in "${!backup_folders[@]}"; do
                if [[ "${backup_folders[$i]}" = "${folder}" ]]; then
                    unset 'backup_folders[$i]'
                fi
            done
	fi
    done
    
    # Logging
    log_dir_safed "${backup_folders[@]}"
    
    # Send a notification via cron and user.
    if (( "${#backup_folders[@]}" > 0 )); then
        sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup" "BaWaB complete."
    else
        sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup" "No backup directories added."
    fi

else 
    # Logging
    log_already_exists "e"

fi

# Logging
log_end_session
