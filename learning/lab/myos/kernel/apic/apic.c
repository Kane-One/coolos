#include "apic.h"
#include "../video/video.h"
#include "../memory/memory.h"


//向端口写入8位
void io_out8(unsigned int port, unsigned int value) {
    value = (char) value;
    asm volatile(
    "out %%al, %%dx;"
    :
    : "a"(value), "d"(port)
    : "memory");
}

int disable_x2apic(void) {
    int x;
    asm volatile("movq $0x1b, %%rcx;"
                 "rdmsr;"
                 "btr $10, %%rax;" // x2apic mode
                 "btr $11, %%rax;" // apic mode
                 "wrmsr;"
                 "movq $0x1b, %%rcx;"
                 "rdmsr;"
    : "=a"(x)
    :
    : "memory");

    return (x >> 10 & 1) == 0 && (x >> 11 & 1) == 0;
}

int enable_x2apic(void) {
    int x;
    asm volatile("movq $0x1b, %%rcx;"
                 "rdmsr;"
                 "bts $10, %%rax;" // x2apic mode
                 "bts $11, %%rax;" // apic mode
                 "wrmsr;"
                 "movq $0x1b, %%rcx;"
                 "rdmsr;"
    : "=a"(x)
    :
    : "memory");

    return (x >> 10 & 1) == 1 && (x >> 11 & 1) == 1;
}

int enable_software_lapic(void) {
    int x;

    asm volatile("movq $0x80f, %%rcx;"
                 "rdmsr;"
                 "bts $8, %%rax;"
                 "btr $12, %%rax;"
                 "wrmsr;"
                 "movq $0x80f, %%rcx;"
                 "rdmsr;"
    : "=a"(x)
    :
    : "memory");

    return (x & 0b1000000000000) && (x & 0b100000000);
}

// 屏蔽所有lvt项
void mask_lvts() {
    asm volatile(
//    "movq   $0x82f, %%rcx;" // CMCI 这里会报错，可能不支持
//    "wrmsr;"
    "movq   $0x832, %%rcx;" // Timer
    "wrmsr;"
    "movq   $0x833, %%rcx;" // Thermal Monitor
    "wrmsr;"
    "movq   $0x834, %%rcx;" // Performance Monitor
    "wrmsr;"
    "movq   $0x835, %%rcx;" // LINT0
    "wrmsr;"
    "movq   $0x836, %%rcx;" // LINT1
    "wrmsr;"
    "movq   $0x837, %%rcx;" // ERROR
    "wrmsr;"
    :
    :   "a"(0x10000), "d"(0x00)
    :   "memory");

    // 0x10000 = 0001 0000 0000 0000 0000
    // 第17位为1时屏蔽
}

void disable_8259a() {
    io_out8(0x21, 0xff);
    io_out8(0xa1, 0xff);
}

void cli() {
    asm volatile("cli");
}

void sti() {
    asm volatile("sti;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
                 "nop;"
    );
}

int init_x2apic() {

    // todo remap

    // enable IMCR

    // init lapic

    // init ioapic





    /*****************************************************/

    disable_8259a();
    printl("8259a disabled");

    if (enable_x2apic() < 0) {
        printl("Failed to enable X2APIC mode");
        return -1;
    }

    printl("X2APIC mode enabled...");

    if (enable_software_lapic() < 0) {
        printl("Failed to enable APIC software");
        return -2;
    }

    printl("APIC software enabled, EOI disabled...");

    mask_lvts();
    printl("LVT all disabled");

    print_msr(0x808);
    print_msr(0x80a);

    // 开启外中断
    sti();
    printl("External interrupts enabled");

    return 0;
}

void setup_keyboard() {


    printl("Keyboard set up");
}


void ioapic_remap() {
    unsigned long *tmp;
    unsigned char *ioapic_addr = (unsigned char *) phy_to_virt(0xfec0000);

    ioapic_map.physical_address = 0xfec0000;
    ioapic_map.virtual_index_address = ioapic_addr;
    ioapic_map.virtual_data_address = (unsigned int *) (ioapic_addr + 0x10);
    ioapic_map.virtual_eoi_address = (unsigned int *) (ioapic_addr + 0x40);



}