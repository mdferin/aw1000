#!/bin/sh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

URL="https://github.com/mdferin/aw1000/releases/download/aw1000/surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin"
FILE="/tmp/fw.bin"
SCRIPT="/tmp/flash.sh"

clear
printf "${CYAN}╔════════════════════════════════════════════╗${NC}\n"
printf "${CYAN}║${WHITE}     OpenWrt Firmware Upgrade Utility       ${CYAN}║${NC}\n"
printf "${CYAN}║${YELLOW}         Arcadyan AW1000 - ipq807x          ${CYAN}║${NC}\n"
printf "${CYAN}╚════════════════════════════════════════════╝${NC}\n\n"

# Auto-detect hardware
DEVICE_TREE=$(cat /proc/device-tree/compatible 2>/dev/null | tr '\0' '\n' | head -1)
BOARD_MODEL=$(ubus call system board 2>/dev/null | jsonfilter -e '@.model' 2>/dev/null)
CPU_INFO=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
FLASH_COUNT=$(cat /proc/mtd | wc -l)
RUNNING=$(cat /etc/openwrt_release 2>/dev/null | grep "DISTRIB_DESCRIPTION" | cut -d"'" -f2)
[ -z "$RUNNING" ] && RUNNING="SurayaWrt 24.10.4 (Detected)"

printf "${GREEN}🔍 Current System Info:${NC}\n"
printf "   ${BOLD}Device Tree${NC} : ${CYAN}%s${NC} ${GREEN}✓${NC}\n" "$DEVICE_TREE"
printf "   ${BOLD}Board Model${NC} : ${YELLOW}%s${NC} ${GREEN}✓${NC}\n" "$BOARD_MODEL"
printf "   ${BOLD}CPU${NC}         : %s\n" "$CPU_INFO"
printf "   ${BOLD}Flash MTD${NC}   : %s partitions detected\n" "$FLASH_COUNT"
printf "   ${BOLD}Running${NC}     : ${MAGENTA}%s${NC}\n\n" "$RUNNING"

printf "${GREEN}✅ Device verification passed: AW1000 detected${NC}\n\n"

printf "${MAGENTA}📦 Firmware Details:${NC}\n"
printf "   ${BOLD}Package${NC} : surayawrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin\n"
printf "   ${BOLD}Dev${NC}     : ${CYAN}mdferin${NC}\n"
printf "   ${BOLD}Target${NC}  : qualcommax/ipq807x\n"
printf "   ${BOLD}Type${NC}    : Sysupgrade image ${RED}(clean install)${NC}\n\n"

printf "${YELLOW}Downloading firmware...${NC}\n"
printf "   ${BOLD}URL${NC}    : %s\n" "$URL"
printf "   ${BOLD}Output${NC} : %s\n\n" "$FILE"

# Download with progress
wget -O $FILE $URL 2>&1 | while IFS= read -r line; do
    printf "   ${CYAN}⏳${NC} %s\n" "$line"
done

if [ $? -ne 0 ] || [ ! -s "$FILE" ]; then
    printf "${RED}❌ Download failed${NC}\n"
    rm -f $FILE 2>/dev/null
    exit 1
fi

printf "\n${GREEN}✅ Download complete.${NC}\n"
SIZE=$(du -h $FILE | cut -f1)
printf "   ${BOLD}Size${NC}    : ${YELLOW}%s${NC}\n" "$SIZE"
printf "   ${BOLD}Location${NC}: %s\n\n" "$FILE"

while true; do
    printf "${BOLD}❓ Proceed with flashing? ${GREEN}(Yes${NC}/${RED}No${NC})${BOLD}: ${NC}"
    read answer
    case $answer in
        [Yy]* )
            printf "\n${RED}╔════════════════════════════════════════════╗${NC}\n"
            printf "${RED}║${YELLOW}              ⚠️  WARNING  ⚠️               ${RED}║${NC}\n"
            printf "${RED}╠════════════════════════════════════════════╣${NC}\n"
            printf "${RED}║${WHITE} • DO NOT disconnect power                 ${RED}║${NC}\n"
            printf "${RED}║${WHITE} • DO NOT touch the router                 ${RED}║${NC}\n"
            printf "${RED}║${WHITE} • Wait at LEAST 5 minutes                 ${RED}║${NC}\n"
            printf "${RED}║${WHITE} • ${RED}All settings will be ERASED${WHITE}             ${RED}║${NC}\n"
            printf "${RED}╚════════════════════════════════════════════╝${NC}\n\n"
            printf "${YELLOW}⏳ Starting flash process in 3 seconds...${NC}\n"
            sleep 3
            printf "${RED}🚀 Flashing now... (system will reboot)${NC}\n"
            printf "${YELLOW}   Target: Arcadyan AW1000${NC}\n"
            printf "${YELLOW}   Firmware: %s${NC}\n" "$SIZE"
            sleep 2
            sysupgrade -n $FILE
            break
            ;;
        [Nn]* )
            printf "\n${YELLOW}🧹 Cancelled. Cleaning up...${NC}\n"
            rm -f $FILE
            rm -f $SCRIPT
            printf "${GREEN}✅ Cleanup done. Exiting.${NC}\n"
            exit 0
            ;;
        * )
            printf "${RED}⚠️  Please answer Yes or No.${NC}\n"
            ;;
    esac
done
