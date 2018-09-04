	
all: system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary system kernel.bin
	rm -f head.o head.p main.o graph.o idt.o system

system: head.o main.o graph.o idt.o
	ld -b elf64-x86-64 -o system head.o main.o graph.o idt.o -T Kernel.lds
	objdump -D system > system.txt
	
head.o:	head.S
	gcc	-E head.S > head.p
	as --64 -o head.o head.p

main.o: main.c
	gcc -mcmodel=large -fno-builtin -m64 -c main.c

graph.o: graph/graph.c
	gcc -mcmodel=large -fno-builtin -m64 -c graph/graph.c

idt.o: idt.c
	gcc -mcmodel=large -fno-builtin -m64 -c idt.c
	