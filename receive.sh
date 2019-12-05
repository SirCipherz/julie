#!/bin/bash

tmpdir="/tmp"
if [ -n "$TMPDIR" ]
then
    tmpdir=$TMPDIR
fi

editor="read"

while [ $# -gt 0 ]
do
    case "$1" in
        -h|--help)
            echo "USAGE:
    $0 [options] [key]

OPTIONS:
    -h --help   Displays this help message and exit
    -t --tmpdir Sets the directory where the messages are stored temporarly (default value: if \$TMPDIR is set, \$TMPDIR, else, /tmp)
    -e --editor Sets the editor"
            exit
            ;;
        -t|--tmpdir)
            shift
            if [ $# -gt 0 ]
            then
                tmpdir="$1"
            else
                >&2 echo "ERROR: Please specify a temp dir"
                exit 1
            fi
            shift
            ;;
        -e|--editor)
            shift
            if [ $# -gt 0 ]
            then
                editor="$1"
            else
                >&2 echo "ERROR: Please specify an editor"
                exit 1
            fi
            shift
            ;;
        *)
            key="$1"
            shift
        ;;
    esac
done

if [ ! -n "$key" ]
then
    if [ "$editor" == "zenity" ]
    then
        key=$(zenity --entry)
    elif [ "$editor" == "read" ]
    then
        read -p "> " key
    else
        $editor "$tmpdir/key"
        key=$(cat "$tmpdir/key")
    fi
fi

# Download the message
curl --silent "https://file.io/$key" --output "$tmpdir/message.gpg.b64"

# Decrypt the message from base64
cat "$tmpdir/message.gpg.b64" | base64 -d > "$tmpdir/message.gpg"
if [ $? -eq 127 ]
then
    >&2 echo "ERROR: base64 not in your PATH, please install it"
    exit 1
fi

# Decrypt and show the message from GPG
gpg --decrypt "$tmpdir/message.gpg" 2> /dev/null
if [ $? -eq 127 ]
then
    >&2 echo "ERROR: gpg not in your PATH, please install it"
    exit 1
fi

# Shred the files
result=$?
if [ $result -eq 0 ]
then
    shred --remove "$tmpdir/message.gpg"
    shred --remove "$tmpdir/message.gpg.b64"
elif [ $result -eq 127 ]
then
    >&2 echo "WARNING: shred not in your PATH, message files not deleted"
fi
