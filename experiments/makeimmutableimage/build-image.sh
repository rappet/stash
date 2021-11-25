#!/bin/sh
set -x

mkdir /rootfs
#debootstrap stable /rootfs http://httpredir.debian.org/debian/

dd if=/dev/zero of=disk.img bs=1M count=1024

sfdisk disk.img <<EOF
label: gpt
unit: sectors
first-lba: 2048

start=2048, size=1M, type=21686148-6449-6E6F-744E-656564454649
size=256M, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

losetup
losetup disk.img /dev/loop0
kpartx -as /dev/loop0

mkfs.ext2 /dev/mapper/loop0p2
mount /dev/mapper/loop0p2 /rootfs/boot

/bin/bash

umount /rootfs/boot
losetup -D