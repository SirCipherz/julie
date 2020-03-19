#!/bin/bash
# Set the temp directory
tmpdir="/tmp"
if [ -n "$TMPDIR" ]
then
    tmpdir=$TMPDIR
fi

# Set the editor
editor='vim'

# Set the recipients
recipients=()

# Get the flags
while [ $# -gt 0 ]
do
    case "$1" in
        -h|--help)
            echo "USAGE:
    $0 [options] [message]

OPTIONS:
    -h --help           Displays this help menu and exit
    -e --editor         Set the editor (available values: zenity, read, vim, or anything else. 
                                        default value: if \$DISPLAY exists, zenity, else if \$EDITOR is set, \$EDITOR, else read)
    -r --recipient      encrypt for USER-ID (GPG)\n
    -i --image <path>   To send an image"
            exit
            ;;
        -e|--editor)
            shift
            if test $# -gt 0
            then
                editor="$1"
            else
                >&2 echo "ERROR: Please specify an editor"
                exit 1
            fi
            shift
            ;;
        -r|--recipient)
            shift
            if [ $# -gt 0 ]
            then
                recipients+=("-r $1")
            else
                >&2 echo "ERROR: Please specify a recipient"
            fi
            shift
            ;;
        -i|--image)
            shift
            mode="img"
            img_path="$1"
            image=`basename $1`
            shift
            ;;
        *)
            message="$1"
            shift
            ;;
    esac
done

# Check if there's one or more recipient(s)
if [ ${#recipients[@]} -eq 0 ]
then
    >&2 echo "ERROR: Please specify at least 1 recipient (see --help)"
    exit 1
fi

# Image mode
if [ "$mode" == 'img' ]
then
    # Encrypt
    cat "$img_path" | gpg -se "${recipients[*]}" > "$tmpdir/$image.gpg"
    base64 "$tmpdir/$image.gpg" > "$tmpdir/$image.gpg.b64"
    if [ $? -eq 127 ]
    then
        >&2 echo "ERROR: base64 not in your PATH. Please install it"
        exit 1
    fi
    # Upload
    link=$(curl --silent -F "file=@$tmpdir/$image.gpg.b64" https://file.io/?expires=2d | jq -r ".key")
    if [ $? -eq 127 ]
    then
        >&2 echo "ERROR: jq not in your PATH. Please install it"
        exit 1
    fi

    # Shred the files
    shred --remove "$tmpdir/$image.gpg"
    result=$?
    if [ $result -eq 0 ]
    then
        shred --remove "$tmpdir/$image.gpg.b64"
    elif [ $result -eq 127 ]
    then
        >&2 echo "WARNING: shred not in your PATH, message files not deleted"
    fi   

    # Wraping into another file
    content='img'$link
    key=$(curl --silent --data-urlencode "text=$content" https://file.io/?expires=2d | jq -r ".key")   

    echo "Key: $key"

    # Copy the key into the clipboard
    if [ -n "$DISPLAY" ]
    then
        echo -n "$key" | xclip -sel clip
        echo -n ""
        result=$?
        if [ $result -eq 0 ]
        then
            notify-send "$0" "Key copied in your clipboard!" || true
        elif [ $result -eq 127 ]
        then
            >&2 echo "WARNING: xclip not in your PATH, key not copied into clipboard"
            notify-send "Key not copied into clipboard" || true
        fi
    fi
    exit
fi

# Write the message
if [ ! -n "$message" ]
then
    if [ "$editor" == "zenity" ]
    then
        zenity --entry > "$tmpdir/message"
        if [ $? -eq 127 ]
        then
            >&2 echo "ERROR: zenity not in your PATH. Please install it or change the editor (see --help)"
            exit 1
        fi
    elif [ "$editor" == "read" ]
    then
        read -p "> " message && echo message > "$tmpdir/message"
    else
        $editor /tmp/message
    fi
fi

# Exit if the message is empty
if [ ! -s "$tmpdir/message" ]
then
    exit
fi

# Encrypt it
cat "$tmpdir/message" | gpg -se "${recipients[*]}" > "$tmpdir/message.gpg"

# Base64
base64 "$tmpdir/message.gpg" > "$tmpdir/message.gpg.b64"
if [ $? -eq 127 ]
then
    >&2 echo "ERROR: base64 not in your PATH. Please install it"
    exit 1
fi

# Upload
link=$(curl --silent --data-urlencode "text=$(cat $tmpdir/message.gpg.b64)" https://file.io/?expires=2d | jq -r ".key")
if [ $? -eq 127 ]
then
    >&2 echo "ERROR: jq not in your PATH. Please install it"
    exit 1
fi

# Shred the files
shred --remove "$tmpdir/message"
result=$?
if [ $result -eq 0 ]
then
    shred --remove "$tmpdir/message.gpg"
    shred --remove "$tmpdir/message.gpg.b64"
elif [ $result -eq 127 ]
then
    >&2 echo "WARNING: shred not in your PATH, message files not deleted"
fi
# Wraping into another file
content='txt'$link
key=$(curl --silent --data-urlencode "text=$content" https://file.io/?expires=2d | jq -r ".key")   

echo "Key: $key"

# Copy the key into the clipboard
if [ -n "$DISPLAY" ]
then
    echo -n "$key" | xclip -sel clip
    echo -n ""
    result=$?
    if [ $result -eq 0 ]
    then
        notify-send "$0" "Key copied in your clipboard!" || true
    elif [ $result -eq 127 ]
    then
        >&2 echo "WARNING: xclip not in your PATH, key not copied into clipboard"
        notify-send "Key not copied into clipboard" || true
    fi
fi
