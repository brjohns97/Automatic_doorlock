#!/bin/sh

# This script will make an SD card from the buildroot rootfs and boot partitions
# while also modifiing the unzipped rootfs once its been partitioned to the SD card

DEVICE='/dev/sdc'


# This script probably needs sudo access somewhere...
if [ $(id -u) != 0 ]; then
    echo "Please run as root"
    exit
fi

# Make sure the SD card exists
if fdisk -l 2> /dev/null | grep "$DEVICE" 1> /dev/null; then
    echo -n "SD card found ----> "
    echo $(fdisk -l 2>/dev/null | grep "Disk $DEVICE")
else
    echo "SD card not found"
    exit
fi

# Politely ask them if they would like to part ways with their SD card
while true; do
    read -p "Do you wish to OBLITERATE this SD card? [y/n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )
    esac
done

# Unmount giggity and delete partition
NUM_PARTITIONS=$(grep -c 'sda[0-9]' /proc/partitions)
a=0
while [ $a -lt $NUM_PARTITIONS ]
do
    a=`expr $a + 1`
    umount $DEVICE$a 2>/dev/null
    parted $DEVICE rm $a 2>/dev/null
done
echo "YEEEEEEEEEP"

exit