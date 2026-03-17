#!/bin/sh

# =====================================================
# OpenWrt Firmware Flasher - AW1000
# =====================================================
# Device    : Arcadyan AW1000
# Arch      : qualcommax-ipq807x
# Firmware  : surayawrt (Custom build)
# Maintainer: mdferin
# Source    : GitHub Releases
# =====================================================

URL="https://github.com/mdferin/aw1000/releases/download/aw1000/surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
FILE="/tmp/fw.bin"
SCRIPT="/tmp/flash.sh"

clear
echo "╔════════════════════════════════════════════╗"
echo "║     OpenWrt Firmware Upgrade Utility       ║"
echo "║         Arcadyan AW1000 - ipq807x          ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Device detection
MODEL=$(grep -o "model name.*" /proc/cpuinfo 2>/dev/null | head -1 || echo "Unknown")
echo "🔍 Current System Info:"
echo "   Device  : Arcadyan AW1000 (Detected)"
echo "   Model   : $MODEL"
echo "   Running : $(cat /etc/openwrt_release | grep 'DISTRIB_DESCRIPTION' | cut -d"'" -f2 2>/dev/null || echo 'Unknown')"
echo ""

echo "📦 Firmware Details:"
echo "   Package : surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
echo "   Dev     : mdferin"
echo "   Type    : Sysupgrade image (clean install)"
echo ""

echo "Downloading firmware..."
wget -O $FILE $URL 2>&1 | sed -u 's/^/   /' || { echo "❌ Download failed"; exit 1; }

echo "✅ Download complete."
SIZE=$(du -h $FILE | cut -f1)
echo "   Size    : $SIZE"
echo "   Location: $FILE"
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
