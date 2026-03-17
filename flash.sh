#!/bin/sh

URL="https://github.com/mdferin/aw1000/releases/download/aw1000/surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
FILE="/tmp/fw.bin"

echo "Downloading firmware..."
wget -O $FILE $URL || { echo "Download failed"; exit 1; }

echo "Download complete. Size: $(du -h $FILE | cut -f1)"
echo ""

while true; do
    read -p "Proceed with flashing? (Yes/No): " answer
    case $answer in
        [Yy]* )
            echo ""
            echo "⚠️ WARNING ⚠️"
            echo "You have UNTICKED 'Keep settings' (clean install)."
            echo "Flashing will start now!"
            echo "DO NOT disconnect power or touch the router."
            echo "Wait at LEAST 5 minutes until router reboots."
            echo "ALL CURRENT CONFIGURATIONS WILL BE LOST."
            echo ""
            echo "Starting flash process..."
            sleep 3
            sysupgrade -n $FILE
            break
            ;;
        [Nn]* )
            echo "Cancelled. Removing downloaded file..."
            rm $FILE
            exit 0
            ;;
        * )
            echo "Please answer Yes or No."
            ;;
    esac
done
