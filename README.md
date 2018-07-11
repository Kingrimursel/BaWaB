# BaWaB
This is a shell script written in bash 4.4.19 which automatically updates as many directories as often as you want. 
Every execution will be logged in `BaWaB.log` and and thus easily comprehensible.
Out of the box the script sets up a new cron job so the backup runs every hour, but the frequency easily be changed by manipulating the cron job.

## Installation
In order to install BaWaB, you first need to install the following packages:

```bash
sudo apt-get install notify-send
sudo apt-get install realpath
```

Once those packages are installed, you can go on installing the actual script.

Therefore execute `isntall.sh` right **right where it is**:

```bash
bash path/to/download/install.sh
```

If everything went right, you should see a green message telling you to now set at least one variable.
The one variable you'll have to set is `backup_folders`, which tells the script the folder(s) that should actually be backed up.
To do that, navigate into `BaWaB.sh`, search for `backup_folders` and fill the array (and remove the examples).

### Personalize the script.

**__But that doesn't mean you must be finished.__**

* By default, the backups get safed in the `Backups` folder, but you can change that as well by manipulating the `destination_folder` variable in `BaWab.sh`.
* Also the script ensures that only n backups are kept as the same time. By default n is set to seven, so one week, but you can change the `saving_limit` variable in `BaWaB.sh`.
* As already mentioned, when the program gets installed it automatically sets up a `cron job` to run once an hour. That can be changed.

#### Potentially occuring problems.
There could occur some problems in ** combination with cronjob and notify-send**.
You get a norification every time something gets backed up, and in order to do so notify-send needs two enviroment variables: `DISPLAY` and `DBUS_SESSION_BUS_ADDRESS`. 
When cron runs the script, it doesn't know the variables by default so they get passed to cron by the script (`BaWaB.sh`).
I set them matching for **Ubuntu 18.04**, if you dont get a notification you might want to set those matching yours. 

Also the script automatically sets the `SHELL` variable and the `PATH` variable for cron. Since the shell needs to be bash i guess that one will stay, but in case something is not working with cron you might try to change `PATH`.


