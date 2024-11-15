#!/bin/bash

#Description    : Arch post installation script.
#Author         : Esteban Berná
#Web            : www.___.com

set -euo pipefail

# Set up the color variables
BBlue='\033[1;34m'
NC='\033[0m'
TIMEZONE='America/Mendoza'

# Check if user is root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." >&2
   exit 1
fi

# Set the timezone
echo -e "${BBlue}Setting the timezone to $TIMEZONE...${NC}"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc --utc

# Set up locale
echo -e "${BBlue}Setting up locale...${NC}"
sed -i -e 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i -e 's/#es_AR.UTF-8/es_AR.UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
export LANG="en_US.UTF-8"

echo -e "${BBlue}Setting up console keymap and fonts...${NC}"
echo 'KEYMAP=la-latin1' > /etc/vconsole.conf

# Set hostname
echo -e "${BBlue}Setting hostname...${NC}"
read -p "Enter hostname: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname &&
echo "127.0.0.1 localhost localhost.localdomain $HOSTNAME.localdomain $HOSTNAME" > /etc/hosts

# Create a new resolv.conf file with the following settings:
# echo "nameserver 1.1.1.1" > /etc/resolv.conf
# echo "nameserver 8.8.8.8" >> /etc/resolv.conf 

# Using NTP for better reliability
echo -e "${BBlue}Using NTP Daemon or NTP Client to Prevent Time Issues...${NC}"
pacman -Sy chrony
systemctl enable chronyd
#pacman -Sy ntp
#systemctl enable --now ntpd

sed -i -e 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

echo -e "${BBlue}Set root password, first user and user password${NC}"
echo -n 'Password: '
passwd

read -p "Enter username: " name
useradd -m $name
echo "Set password for $name"
passwd $name

echo -e "${BBlue}Add user to common groups${NC}"
usermod -aG wheel,audio,video,optical,storage,uucp,dialout $name

echo -e "${BBlue}Initiate and populate pacman keys${NC}"
sudo pacman-key --init
sudo pacman-key --populate archlinux

