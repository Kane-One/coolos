CFLAGS=-fno-stack-protector -mcmodel=large -fno-builtin -m64 -c

all: system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary system kernel.bin

system: head.o main.o cpu.o memory.o video.o idt.o apic.o
	ld -b elf64-x86-64 -o system head.o main.o cpu.o memory.o video.o idt.o apic.o -T Kernel.lds
	objdump -D system > system.txt
	
head.o:	head.S
	gcc	-E head.S > head.p
	as --64 -o head.o head.p

main.o: main.c
	gcc ${CFLAGS} main.c

cpu.o: cpu/cpu.c
	gcc ${CFLAGS} cpu/cpu.c

video.o: video/video.c
	gcc ${CFLAGS} video/video.c

memory.o: memory/memory.c
	gcc ${CFLAGS} memory/memory.c

idt.o: idt/idt.c
	gcc ${CFLAGS} idt/idt.c

apic.o: apic/apic.c
	gcc ${CFLAGS} apic/apic.c

.PHONY : clean
clean:
	-rm -f *.o *.p

