#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

IMG_FILE=$SCRIPT_DIR/disk.img
if [ -f $IMG_FILE ]; then
	rm $IMG_FILE
fi

qemu-img create -f raw $IMG_FILE 1G

losetup -D
loopDevice=$(losetup -f)
echo "Using $loopDevice..."
# losetup $loopDevice $IMG_FILE
# sgdisk -Z $loopDevice
# sgdisk -n 0:0:+200M -t 0:ef02 -c 0:"bios_boot" $loopDevice
# echo 'label: gpt' | sfdisk $loopDevice

# sfdisk $IMG_FILE <<-EOF
#	label: gpt
#	label-id: D9265732-F7D1-ADBA-513C-502CE422E600
#	unit: sectors
#	first-lba: 34
#	1 : start=512, size=256768, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=D9265732-F7D1-ADBA-513C-502CE422E601, name="EFI System Partition"
# EOF

cat << EOF | sfdisk --label gpt $IMG_FILE
1: start=1M,size=100M,bootable,type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
EOF

losetup -P $loopDevice $IMG_FILE
mkfs.vfat ${loopDevice}p1

MOUNTPOINT=/mnt/tmp/
mount ${loopDevice}p1 $MOUNTPOINT
mkdir $MOUNTPOINT/
cp $SCRIPT_DIR/vmlinuz $MOUNTPOINT/
cp $SCRIPT_DIR/initramfs.linux_amd64.cpio $MOUNTPOINT/
sudo grub-install --target=x86_64-efi --efi-directory=$MOUNTPOINT/ --no-nvram --removable --no-floppy ${loopDevice}
cp $SCRIPT_DIR/grub.cfg $MOUNTPOINT/EFI/BOOT/grub.cfg
umount /mnt/tmp/
# losetup -D
