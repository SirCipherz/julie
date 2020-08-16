#!/bin/bash

# Root Check

if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user for launching this script" 2>&1
    exit 1
else
    echo "Welcome to the Julie's installation wizard"
    echo ""
    echo "Which editor would you like to use ?"
    echo "(N)ano | (V)im | (Z)enity | (R)ead"
    read -p "$ " editor

    if [[ $editor == 'N' ]] || [[  $editor == 'n' ]]; then
        editor='nano'
        echo "nano will be used as your editor for julie"
    elif [[ $editor == 'V' ]] || [[ $editor == 'v' ]]; then
        editor='vim'
        echo "vim will be used as your editor for julie"
    elif [[ $editor == 'Z' ]] || [[ $editor == 'z' ]]; then
        editor='zenity'
        echo "zenity will be used as your editor for julie"
    elif [[ $editor == 'R' ]] || [[ $editor == 'r' ]]; then
        editor='read'
        echo "read will be used as your editor for julie"
    else
        echo "You haven't choose a valid editor, the read will be used"
        editor='read'
    fi

    python3 replacer.py $editor # Changing the editor into the send.sh file

    # Copy the send and the receive script into /usr/bin/
    echo "Copying the files ..."

    cp /tmp/tmp-julie-send.sh /usr/bin/julie-s
    cp ./receive.sh /usr/bin/julie-r

    rm /tmp/tmp-julie-send.sh # Cleaning

    echo "Giving the rights to all users ..."
    chmod a+rx /usr/bin/julie-* # Giving the rights

    echo "Installation is complete !"
fi
