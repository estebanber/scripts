#!/bin/bash


DEVICE1="/dev/nvme0n1p3"
DEVICE2="/dev/nvme0n1p2"

# Function to get password via zenity (graphical dialog)
get_password_gui() {
    password=$(zenity --password --title="Enter Password to Unlock Partition")
    echo $password
}

# Function to get password via console
get_password_console() {
    echo -n "Enter Password to Unlock Partition: "
    read -s password
    echo $password
}

# Check if script is running in a GUI environment
if [ -n "$DISPLAY" ]; then
    password=$(get_password_gui)
    firefox -new-tab https://teams.microsoft.com/ -new-tab https://outlook.office.com/ & disown
    firefox -P Budderfly -new-tab https://teams.microsoft.com/ -new-tab https://outlook.office.com/ & disown
    slack & disown
else
    password=$(get_password_console)
fi

TMPFILE=$(mktemp)
echo -n $password > $TMPFILE

# Unlock the encrypted partition
UNLOCK_OUTPUT=$(udisksctl unlock --block-device $DEVICE1 --key-file=$TMPFILE)

# Clean up the temporary file
rm -f $TMPFILE


# Check if unlock was successful
if echo "$UNLOCK_OUTPUT" | grep -q "Unlocked"; then
    # Extract the unlocked device path from the output
    UNLOCKED_DEVICE=$(echo "$UNLOCK_OUTPUT" | grep -o '/dev/dm-[0-9]*')

    # Mount the unlocked device
    if [ -n "$UNLOCKED_DEVICE" ]; then
        udisksctl mount --block-device $UNLOCKED_DEVICE
        if [ $? -eq 0 ]; then
            echo "Partition successfully unlocked and mounted."
        else
            echo "Failed to mount the unlocked partition."
        fi
    else
        echo "Failed to find the unlocked device."
    fi
else
    echo "Failed to unlock the partition"
    echo "$UNLOCK_OUTPUT"
    exit 1
fi

udisksctl mount --block-device $DEVICE2


if [ -n "$DISPLAY" ]; then
    kitty /run/media/eberna/Budderfly/repo/ & disown
else
    echo "Nothing to do"
fi
