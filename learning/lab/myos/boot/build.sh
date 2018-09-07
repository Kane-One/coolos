#!/usr/bin/bash

nasm boot.asm -o boot.img 
nasm loader.asm -o loader.bin 
ndisasm loader.bin > loader.txt

mkdir tmp
hdiutil attach -mountpoint tmp boot.img 
cp loader.bin tmp  
cp ../kernel/kernel.bin tmp  
sync  
umount tmp
hdiutil detach /dev/disk2
rm -rf tmp