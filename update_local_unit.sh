#!/bin/bash

LOCAL_DIR="/c/Users/alexc/Documents/rpi-0-w/program/"
FILE1="doorlock.py"
FILE2="watchdog.sh"
FILE3="gmailer.py"
FILE4="gmailpw.txt"
REMOTE_IP_ADDRESS='192.168.1.69'
REMOTE_DIR="/program/"
USER="root"
#SSH_COMMAND_1="killall python"
PASSWORD=`cat "C:\Users\alexc\Documents\rpi-0-w\remote_update_script\password.txt"`
PUTTY_COMMAND="C:\Users\alexc\Documents\rpi-0-w\remote_update_script\putty_cmd.txt"

pscp -scp -pw $PASSWORD "$LOCAL_DIR$FILE1" "$LOCAL_DIR$FILE2" "$LOCAL_DIR$FILE3" "$LOCAL_DIR$FILE4" "$USER@$REMOTE_IP_ADDRESS:$REMOTE_DIR"
putty -ssh "$USER@$REMOTE_IP_ADDRESS" -pw $PASSWORD -m $PUTTY_COMMAND