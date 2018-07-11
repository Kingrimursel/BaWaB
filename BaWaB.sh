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

# Setting up the log file

# Logging
start_session
called_from $1

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
    already_exists "n"
    
    # Checking of the existing number of Backups is equal to the maximum you want. If you want another limit, change the '7' to your preferenced number.
    if (($num_elements == $saving_limit)); then
        # Remove the oldest Backup
	oldest="$(ls -1t "${destination_folder}"/| tail -1)"
	rm -r "${destination_folder}"/${oldest}
	#Logging
	dir_removed $oldest
    fi

    # Create a new Backup folder
    mkdir "${destination_folder}"/BACKUP-"${date}"
    
    # tar and gzip the directories that should be backed up and safe them.
    for folder in "${backup_folders[@]}"; do
        if [ -d $folder ]; then
	    tar -C ${folder%/*} -czf "${destination_folder}"/BACKUP-"${date}"/${folder##*/}.tar.gz ${folder##*/}
	else
	    # Sending a notification
	    sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 8 "Backup error" "BaWaB: Folder \"${folder}\" doesn't exist"
	    # Logging
	    backup_folder_exception $folder
	    # Removing bad folder from array
	    to_delete=($folder)
	    backup_folders=( "${backup_folders[@]/$delete}" )
	fi
    done
    
    # Logging
    dir_safed "${backup_folders[@]}"
    
    # Send a notification via cron and user.
    sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 8 "Backup" "BaWaB complete."

    # Logging
    notify_send

else 
    # Logging
    already_exists "e"

fi

# Logging
end_session
