#!/usr/bin/bash


cd  ../../../../tools/docker
docker-compose run -w /home/myos/learning/lab/myos/kernel linux sh -c "make clean && make"

cd ../../learning/lab/myos/boot
nasm boot.asm -o boot.img 
nasm loader.asm -o loader.bin 
ndisasm loader.bin > loader.txt

mkdir tmp
hdiutil attach -mountpoint tmp boot.img 
cp loader.bin tmp  
cp ../kernel/kernel.bin tmp  
sync  
umount tmp
hdiutil detach /dev/disk3
rm -rf tmp