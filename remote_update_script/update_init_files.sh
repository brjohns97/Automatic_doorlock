#!/bin/bash

# This script mostly exists during development of constantly re-buiilding the buildroot
# and figuring out which init things are needed

LOCAL_DIR="/c/Users/alexc/Documents/rpi-0-w/custom_init.d_files/"
FILE1="S99doorlock"
FILE2="S45ntpd"
REMOTE_IP_ADDRESS='192.168.1.69'
REMOTE_DIR="/etc/init.d/"
USER="root"
PASSWORD=`cat "C:\Users\alexc\Documents\rpi-0-w\remote_update_script\password.txt"`
PUTTY_COMMAND="C:\Users\alexc\Documents\rpi-0-w\remote_update_script\putty_cmd.txt"

pscp -pw $PASSWORD scp "$LOCAL_DIR$FILE1" "$LOCAL_DIR$FILE2" "$USER@$REMOTE_IP_ADDRESS:$REMOTE_DIR"
