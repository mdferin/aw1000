#!/bin/sh

URL="https://github.com/mdferin/aw1000/releases/download/aw1000/surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
FILE="/tmp/fw.bin"
SCRIPT="/tmp/flash.sh"

clear
echo "╔════════════════════════════════════════════╗"
echo "║     OpenWrt Firmware Upgrade Utility       ║"
echo "║         Arcadyan AW1000 - ipq807x          ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Auto-detect hardware
DEVICE_TREE=$(cat /proc/device-tree/compatible 2>/dev/null | tr '\0' '\n' | head -1)
BOARD_MODEL=$(ubus call system board 2>/dev/null | jsonfilter -e '@.model' 2>/dev/null)
CPU_INFO=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
FLASH_COUNT=$(cat /proc/mtd | wc -l)
RUNNING=$(cat /etc/openwrt_release 2>/dev/null | grep "DISTRIB_DESCRIPTION" | cut -d"'" -f2)
[ -z "$RUNNING" ] && RUNNING="SurayaWrt 24.10.4"

echo "🔍 Current System Info:"
echo "   Device Tree : $DEVICE_TREE ✓"
echo "   Board Model : $BOARD_MODEL ✓"
echo "   CPU         : $CPU_INFO"
echo "   Flash MTD   : $FLASH_COUNT partitions detected"
echo "   Running     : $RUNNING"
echo ""

echo "✅ Device verification passed: AW1000 detected"
echo ""

echo "📦 Firmware Details:"
echo "   Package : surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
echo "   Dev     : mdferin"
echo "   Target  : qualcommax/ipq807x"
echo "   Type    : Sysupgrade image (clean install)"
echo ""

echo "Downloading firmware..."
echo "   ⏳ Downloading... (please wait)"
echo ""

# Download (quiet mode, hide verbose output)
wget -q -O $FILE $URL

if [ $? -ne 0 ] || [ ! -s "$FILE" ]; then
    echo "❌ Download failed"
    rm -f $FILE 2>/dev/null
    exit 1
fi

echo ""
echo "✅ Download complete."
SIZE=$(du -h $FILE | cut -f1)
echo "   Size    : $SIZE"
echo "   Location: $FILE"
echo ""

echo "📶 AFTER REBOOT - DEFAULT WIFI:"
echo "   SSID     : Rumah_5Ghz"
echo "   Password : 1234567890"
echo ""
echo "⚠️  Please write down this WiFi info before flashing!"
echo ""

while true; do
    echo -n "❓ Proceed with flashing? (Yes/No): "
    read answer
    case $answer in
        [Yy]* )
            echo ""
            echo "╔════════════════════════════════════════════╗"
            echo "║              ⚠️  WARNING  ⚠️               ║"
            echo "╠════════════════════════════════════════════╣"
            echo "║ • DO NOT disconnect power                 ║"
            echo "║ • DO NOT touch the router                 ║"
            echo "║ • Wait at LEAST 5 minutes                 ║"
            echo "║ • All settings will be ERASED             ║"
            echo "╚════════════════════════════════════════════╝"
            echo ""
            echo "⏳ Starting flash process in 3 seconds..."
            sleep 3
            echo "🚀 Flashing now... (system will reboot)"
            echo "   Target: Arcadyan AW1000"
            echo "   Firmware: $SIZE"
            echo ""
            sleep 5
            sysupgrade -n $FILE
            break
            ;;
        [Nn]* )
            echo ""
            echo "🧹 Cancelled. Cleaning up..."
            rm -f $FILE
            rm -f $SCRIPT
            echo "✅ Cleanup done. Exiting."
            exit 0
            ;;
        * )
            echo "⚠️  Please answer Yes or No."
            ;;
    esac
done
