#!/bin/bash

# Root Check

if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user" 2>&1
    exit 1
else
    echo "Welcome to the Julie's installation wizard"
    echo ""

    # Copy the send and the receive script into /usr/bin/
    echo "Copying the files ..."

    cp ./send.sh /usr/bin/julie-s
    cp ./receive.sh /usr/bin/julie-r

    echo "Giving the rights to all users ..."
    chmod a+rx /usr/bin/julie-* # Giving the rights

    echo "Installation is complete !"
fi
