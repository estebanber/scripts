#!/bin/bash

BGreen='\033[1;32m'
NC='\033[0m'

# Function to install a section
install_section() {
    section_name=$1
    packages=$2

    echo -e "${BGreen}Installing $section_name packages...${NC}"
    sudo pacman -S --needed $packages
    echo "$section_name packages installed!"
    echo
}

# Function to prompt for section installation
prompt_section() {
    section_name=$1
    packages=$2

    while true; do
        read -p "Do you want to install the $section_name packages? [y/n]: " yn
        case $yn in
            [Yy]* ) install_section "$section_name" "$packages"; break;;
            [Nn]* ) echo "Skipping $section_name packages."; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Main script
echo -e "${BGreen}Reading the packages list from packets.txt...${NC}"

# Check if file exists
if [[ ! -f "packets.txt" ]]; then
    echo "Error: packets.txt file not found!"
    exit 1
fi

# Load sections from the file
sections=($(grep "^#" packets.txt | sed 's/#//g'))
packages=($(grep -v "^#" packets.txt))

# Prompt for installing all packages
read -p "Do you want to install all packages? [y/n]: " install_all

if [[ $install_all =~ ^[Yy]$ ]]; then
    # Install all packages
    echo -e "${BGreen}Installing all packages...${NC}"
    sudo pacman -S --needed $(grep -v "^#" packets.txt)
    echo "All packages installed!"
else
    # Read the file line by line outside the while loop
    mapfile -t lines < packets.txt
    
    for line in "${lines[@]}"; do
        # Skip blank lines
        [[ -z "$line" ]] && continue
        
        # Check if the line starts with a '#', meaning a new section
        if [[ $line =~ ^# ]]; then
            # If there is a previous section, prompt to install it
            if [[ -n $current_section && -n $current_packages ]]; then
                prompt_section "$current_section" "$current_packages"
            fi
            # Set new section
            current_section=$(echo "$line" | sed 's/#//g' | xargs)  # Remove '#' and trim spaces
            current_packages=""
        else
            # Append package to the current section's packages
            current_packages="$current_packages $line"
        fi
    done

    # Install the last section
    if [[ -n $current_section && -n $current_packages ]]; then
        prompt_section "$current_section" "$current_packages"
    fi
fi

echo "Installation process complete!"
