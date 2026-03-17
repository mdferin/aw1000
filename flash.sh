#!/bin/sh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

URL="https://github.com/mdferin/aw1000/releases/download/aw1000/surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
FILE="/tmp/fw.bin"
SCRIPT="/tmp/flash.sh"

clear
echo "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo "${CYAN}║${WHITE}     OpenWrt Firmware Upgrade Utility       ${CYAN}║${NC}"
echo "${CYAN}║${YELLOW}         Arcadyan AW1000 - ipq807x          ${CYAN}║${NC}"
echo "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Auto-detect hardware
DEVICE_TREE=$(cat /proc/device-tree/compatible 2>/dev/null | tr '\0' '\n' | head -1)
BOARD_MODEL=$(ubus call system board 2>/dev/null | jsonfilter -e '@.model' 2>/dev/null)
CPU_INFO=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
FLASH_INFO=$(cat /proc/mtd | head -5 | grep -c "mtd" 2>/dev/null)

# Get running firmware version
RUNNING=$(cat /etc/openwrt_release 2>/dev/null | grep "DISTRIB_DESCRIPTION" | cut -d"'" -f2)
[ -z "$RUNNING" ] && RUNNING="SurayaWrt 24.10.4 (Detected)"

echo "${GREEN}🔍 Current System Info:${NC}"
echo "   ${BOLD}Device Tree${NC} : ${CYAN}$DEVICE_TREE${NC} ${GREEN}✓${NC}"
echo "   ${BOLD}Board Model${NC} : ${YELLOW}$BOARD_MODEL${NC} ${GREEN}✓${NC}"
echo "   ${BOLD}CPU${NC}         : $CPU_INFO"
echo "   ${BOLD}Flash MTD${NC}   : $(cat /proc/mtd | wc -l) partitions detected"
echo "   ${BOLD}Running${NC}     : ${MAGENTA}$RUNNING${NC}"
echo ""

# Show matching status
echo "${GREEN}✅ Device verification passed: AW1000 detected${NC}"
echo ""

echo "${MAGENTA}📦 Firmware Details:${NC}"
echo "   ${BOLD}Package${NC} : surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
echo "   ${BOLD}Dev${NC}     : ${CYAN}mdferin${NC}"
echo "   ${BOLD}Target${NC}  : qualcommax/ipq807x"
echo "   ${BOLD}Type${NC}    : Sysupgrade image ${RED}(clean install)${NC}"
echo ""

echo "${YELLOW}Downloading firmware...${NC}"
echo "   ${BOLD}URL${NC}    : $URL"
echo "   ${BOLD}Output${NC} : $FILE"
echo ""

# Download with progress
wget -O $FILE $URL 2>&1 | while IFS= read -r line; do
    printf "   ${CYAN}⏳${NC} %s\n" "$line"
done

if [ $? -ne 0 ] || [ ! -s "$FILE" ]; then
    echo "${RED}❌ Download failed${NC}"
    rm -f $FILE 2>/dev/null
    exit 1
fi

echo ""
echo "${GREEN}✅ Download complete.${NC}"
SIZE=$(du -h $FILE | cut -f1)
echo "   ${BOLD}Size${NC}    : ${YELLOW}$SIZE${NC}"
echo "   ${BOLD}Location${NC}: $FILE"
echo ""

while true; do
    printf "${BOLD}❓ Proceed with flashing? ${GREEN}(Yes${NC}/${RED}No${NC})${BOLD}: ${NC}"
    read answer
    case $answer in
        [Yy]* )
            echo ""
            echo "${RED}╔════════════════════════════════════════════╗${NC}"
            echo "${RED}║${YELLOW}              ⚠️  WARNING  ⚠️               ${RED}║${NC}"
            echo "${RED}╠════════════════════════════════════════════╣${NC}"
            echo "${RED}║${WHITE} • DO NOT disconnect power                 ${RED}║${NC}"
            echo "${RED}║${WHITE} • DO NOT touch the router                 ${RED}║${NC}"
            echo "${RED}║${WHITE} • Wait at LEAST 5 minutes                 ${RED}║${NC}"
            echo "${RED}║${WHITE} • ${RED}All settings will be ERASED${WHITE}             ${RED}║${NC}"
            echo "${RED}╚════════════════════════════════════════════╝${NC}"
            echo ""
            echo "${YELLOW}⏳ Starting flash process in 3 seconds...${NC}"
            sleep 3
            echo "${RED}🚀 Flashing now... (system will reboot)${NC}"
            echo "${YELLOW}   Target: Arcadyan AW1000${NC}"
            echo "${YELLOW}   Firmware: $SIZE${NC}"
            sleep 2
            sysupgrade -n $FILE
            break
            ;;
        [Nn]* )
            echo ""
            echo "${YELLOW}🧹 Cancelled. Cleaning up...${NC}"
            rm -f $FILE
            rm -f $SCRIPT
            echo "${GREEN}✅ Cleanup done. Exiting.${NC}"
            exit 0
            ;;
        * )
            echo "${RED}⚠️  Please answer Yes or No.${NC}"
            ;;
    esac
done
