#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if pgrogam already is installed here
if [ -d $PWD/BaWaB ]; then
    while true; do
        echo -e "${ORANGE}It seems like the program is already installed in this directory. Do you want to overwrite? y/n${NC}"
        read -rsn1 input
        if [ "$input" = "y" ] || [ "$input" = "Y"  ]; then
            rm -r $PWD/BaWaB
	    break
        elif [ "$input" = "n" ] || [ "$input" = "N"  ]; then
	    exit 1
        fi
    done	
fi

# Create program directory
mkdir $PWD/BaWaB/
# Create default Backups directory
mkdir $PWD/BaWaB/Backups
# Create log file
touch $PWD/BaWaB/BaWaB.log

# Copy to Project to right location
download_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
rsync -av --exclude="install.sh" $download_dir/ $PWD/BaWaB

# Set the Log files
sed -i "29i\source $PWD/BaWaB/write_log.sh" "$PWD/BaWaB/BaWaB.sh"
sed -i "30i\exec 1>>$PWD/BaWaB/BaWaB.log 2>&1" "$PWD/BaWaB/BaWaB.sh"

# Set default destination directory
sed -i "40i\destination_folder=$PWD/BaWaB/Backups" "$PWD/BaWaB/BaWaB.sh"

# Set up new cron job
(crontab -l 2>/dev/null; echo "0 * * * * env USER=$LOGNAME $PWD/BaWaB/BaWaB.sh cron") | crontab -

# Inform the user
echo -e "\n${GREEN}Installation completed, a cron job was set to be triggered every hour. Now you need to define the folders that should be backed up and some other variables of you want. Either read the README or the first lines of BaWab.sh to get more informations.${NC}"
