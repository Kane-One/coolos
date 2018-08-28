#!/usr/bin/bash

nasm boot.asm -o boot.img 
nasm loader.asm -o loader.bin 
ndisasm loader.bin > loader.txt

hdiutil attach -mountpoint loader boot.img 
cp loader.bin loader  
cp kernel/kernel.bin loader  
# cp test loader/kernel.bin
sync  
umount loader
hdiutil detach /dev/disk2