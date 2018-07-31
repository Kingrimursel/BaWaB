#!/bin/bash

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# This program makes Backups of as much and any directories you want and safes them into a choosable destination directory. It also limits the number of Backups safed, so it deletes the oldest one if it tries to create a new one and notices that the limit is already reached.

# If you want to run this script from crontab, you have to set the enviroment variables "DISPLAY" and "DBUS_SESSION_BUS_ADDRESS" in order to be notified when the Backup was made. They are already set(Ubuntu 18.04), but in case it doesn't work for you you'll have to change them.

# OPTIONAL CHANGES
# If you want to change the limit of kept backups at once, change "$saving_limit" to whatever you want.
# To manipulate the destination folder for the backups, change "$destination_folder".

# REQUIRED CHANGES
# To manipulate the elements that should be backed up, change "$backup_elements".

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
declare -a backup_elements=("path/to/directory/one" "path/to/directory/two")

# Declaring the folder where the Backups should be stored.

# Setting the maximun number of backups beeing safed at once.
saving_limit=7

date=$(date '+%Y-%m-%d')

# Getting the number of existing backups.
num_elements=$(ls "${destination_folder}"  -afq | wc -l)

# If the queued Backup doesn't exist, keep going
if [ ! -d "${destination_folder}"/BACKUP-"${date}" ] && [ ! -f "${destination_folder}"/BACKUP-"${date}"  ]; then

    # Is element a directory
    if [ -d "${destination_folder}"/BACKUP-"${date}" ]; then
        is_dir = true
    fi

    # Logging
    log_already_exists "n"

    # Checking of the existing number of Backups is equal to the maximum you want. If you want another limit, change the '7' to your preffered number.
    if (($num_elements == $saving_limit)); then
    # Remove the oldest Backup
        oldest="$(ls -1t "${destination_folder}"/| tail -1)"
        if [ $is_dir = true ]; then
            rm -r "${destination_folder}"/${oldest}
        else
            rm "${destination_folder}"/${oldest}
        fi

        #Logging
        log_element_removed $oldest
    fi

    # Create a new Backup folder
    mkdir "${destination_folder}"/BACKUP-"${date}"

    # tar and gzip the directories that should be backed up and safe them, of copy file.
    for element in "${backup_elements[@]}"; do
        if [ -d $element ]; then
        tar -C ${element%/*} -czf "${destination_folder}"/BACKUP-"${date}"/${element##*/}.tar.gz ${element##*/}
        elif [ -f $element ]; then
            cp $element "$destination_folder"/BACKUP-"${date}"/"${element##*/}"
    else
        # Sending a notification
        sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup error" "BaWaB: Element \"${element}\" doesn't exist."
        # Logging
        log_backup_element_exception $element
        # Removing bad element from array
            for i in "${!backup_elements[@]}"; do
                if [[ "${backup_elements[$i]}" = "${element}" ]]; then
                    unset 'backup_elements[$i]'
                fi
            done
    fi
    done

    # Logging
    log_dir_safed "${backup_elements[@]}"

    # Send a notification via cron and user.
    if (( "${#backup_elements[@]}" > 0 )); then
        sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup" "BaWaB complete."
    else
        sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u "normal" -t 6000 "Backup" "No backup directories added."
        rm -r $destination_folder/BACKUP-"${date}"
    fi

else
    # Logging
    log_already_exists "e"

fi

# Logging
log_end_session
