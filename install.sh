#!/bin/bash

ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create default Backups directory
mkdir $PWD/Backups
# Create log file
touch $PWD/BaWaB.log

# Set Log files
sed -i "37i\source $PWD/write_log.sh" "$PWD/BaWaB.sh"
sed -i "38i\exec 1>>$PWD/BaWaB.log 2>&1" "$PWD/BaWaB.sh"

# Set default destination directory
sed -i "48i\destination_folder=$PWD/Backups" "$PWD/BaWaB.sh"

# Set up new cron job
(crontab -l 2>/dev/null; echo "0 * * * * env USER=$LOGNAME $PWD/BaWaB.sh cron") | crontab -

# Inform the user
echo -e "${GREEN}Installation completed, a cron job was set to be triggered every hour. Now you need to define the folders that should be backed up and some other variables of you want. Either read the README or the first lines of BaWab.sh to get more informations.${NC}"

# Confirm installation
sed -i "28i\installed=true" "$PWD/BaWaB.sh"

# Remove this file
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
rm $DIR/install.sh
