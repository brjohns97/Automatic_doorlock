#!/bin/sh

# This script will make an SD card from the buildroot rootfs and boot partitions
# while also modifiing the unzipped rootfs once its been partitioned to the SD card
LOCATION=sdc
DEVICE=/dev/$LOCATION
BR_ROOT=/home/$SUDO_USER/buildroot
LOGFILE=$BR_ROOT/script_log.txt
CUSTOM_DIR=/home/$SUDO_USER/rpi0-w-code/Automatic_doorlock


>"$LOGFILE"

yn_prompt () {
    while true; do
        read -p "$1 [y/n]" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * )
        esac
    done
}

create_fs () {
   PROG=$1
   DEV=$2
   #sudo $PROG $DEV &>>"$LOGFILE"
   if [[ "$PROG" == "mkfs.ext4" ]]; then
      $PROG -F -v $DEV &>>"$LOGFILE"
   else
      $PROG -v $DEV &>>"$LOGFILE"
   fi
   RESULT=$?
   if [[ ! $RESULT -eq 0 && ! $RESULT -eq 2 ]]; then
      echo "$PROG returned $RESULT."
      echo "Unable to create file system on ${DEV}."
      exit
   fi
}

do_mount () {
   DEV=$1
   DIR=$2
   OPTS=$3
   if [ ! -d $DIR ]; then
      mkdir $DIR
   fi

   if ! mount $DEV $DIR $OPTS &>>"$LOGFILE"; then
      echo "Could not mount ${DEV} into ${DIR}."
   fi
}

do_unmount () {
   DEV=$1
   if ! umount $DEV &>>"$LOGFILE"; then
      echo "Could not unmount ${DEV}."
   fi
}

# This script probably needs sudo access somewhere...
if [ $(id -u) != 0 ]; then
    echo "Please run as root"
    exit
fi

# Make sure the SD card exists
if fdisk -l 2>> "$LOGFILE" | grep "$DEVICE" 1>> "$LOGFILE"; then
    echo -n "SD card found ----> "
    echo $(fdisk -l 2>>"$LOGFILE" | grep "Disk $DEVICE")
else
    echo "SD card not found"
    exit
fi

# Politely ask them if they would like to part ways with their SD card
if ! yn_prompt "Do you wish to OBLITERATE this SD card?"; then
    echo "Then put a different one in ya dingus"
    exit
fi


# Unmount giggity and delete partition
echo "Unmounting and deleting sd card data"
NUM_PARTITIONS=$(grep -c '$LOCATION[0-9]' /proc/partitions)
a=0
while [ $a -lt $NUM_PARTITIONS ]
do
    a=`expr $a + 1`
    umount $DEVICE$a 2>>"$LOGFILE"
    parted $DEVICE rm $a 2>>"$LOGFILE"
done

# Create the boot partition and rootfs partition
echo "Partitioning device..."
   fdisk $DEVICE &>>"$LOGFILE" << EOF
o
n
p
1

+100M
t
c
n
p
2

+1G
w
EOF

# Make sure that linux knows the current status of disk partitions
echo "Syncing file systems..."
sync
/sbin/partprobe
sleep 5
sync
[ -d $DEVICE ] && ls -l ${DEVICE}? > /dev/null
sleep 3

# Create file systems on the partitions
echo "Creating file systems on ${DEVICE}. This can take a few minutes"
create_fs mkfs.vfat ${DEVICE}1
create_fs mkfs.ext2 ${DEVICE}2

# Make sure everything in synced.
echo "Waiting for system to synchronize file systems..."
sync
sleep 5


# It's time to mount giggity
MOUNTDIR=/run/shm
BOOTDIR=${MOUNTDIR}/boot
ROOTDIR=${MOUNTDIR}/root

do_mount "${DEVICE}1" "$BOOTDIR"
do_mount "${DEVICE}2" "$ROOTDIR"

echo "File systems have been mounted."
echo "   Boot data  . . . . . $BOOTDIR"
echo "   Root file system . . $ROOTDIR"


# This is here for debugging
if ! yn_prompt "We good?"; then
    exit
fi

# Go into the buildroot directory and grab the rootfs, then the boot stuff
echo "Copying root file system..."
sleep 1
tar xvf $BR_ROOT/output/images/rootfs.tar -C "$ROOTDIR"

echo "Copying kernel and configuration data..."
sleep 1
cp -r $BR_ROOT/output/images/rpi-firmware/* "$BOOTDIR"
cp $BR_ROOT/output/images/*.dtb "$BOOTDIR"
#cp $BR_ROOT/board/all-line/config.txt "$BOOTDIR"
#cp $BR_ROOT/board/all-line/cmdline.txt "$BOOTDIR"
cp $BR_ROOT/output/images/zImage "$BOOTDIR"

# Copy the custom init.d files into the rootfs
echo "Coping the cusotm init.d files"
CUSTOM_INIT="$CUSTOM_DIR/custom_init.d_files"
cp $CUSTOM_INIT/S45ntpd $ROOTDIR/etc/init.d
cp $CUSTOM_INIT/S99doorlock $ROOTDIR/etc/init.d
chmod +x $ROOTDIR/etc/init.d/S45ntpd
chmod +x $ROOTDIR/etc/init.d/S99doorlock

# Throw in the program
echo "Creating program directory and stuffing it with software"
mkdir $ROOTDIR/program
cp -r $CUSTOM_DIR/program/* $ROOTDIR/program
chmod -R +x $ROOTDIR/program

# unmount the SD partitions... unless they don't want to for some reason
if yn_prompt "Completed successfully. Unmount file systems (almost definitely yes)?"; then
   echo "Syncing and unmounting..."
   sync
   sleep 5

   do_unmount $BOOTDIR
   do_unmount $ROOTDIR
fi

exit