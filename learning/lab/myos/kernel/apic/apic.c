#include "apic.h"
#include "../video/video.h"
#include "../memory/memory.h"

void io_out8(unsigned int port, unsigned int value) {
    value = (char) value;
    asm volatile(
    "out %%al, %%dx;"
    :
    : "a"(value), "d"(port)
    : "memory");
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

    return x & 0b110000000000;
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

int get_lapic_version() {

}

int disable_eoi(void) {
    int x;
    asm volatile("movq $0x80f, %%rcx;"
                 "rdmsr;"
                 "bts $12, %%rax;"
                 "wrmsr;"
                 "movq $0x80f, %%rcx;"
                 "rdmsr;"
    : "=a"(x)
    :
    : "memory");

    return x == 0 ? 0 : -1;
}

void disable_lvt() {
    asm volatile(
//                 "movq   $0x82f, %%rcx;" // CMCI 这里会报错，不知道为什么，可能bochs不支持
//                 "wrmsr;"
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
}

void disable_8259a() {
    io_out8(0x21, 0xff);
    io_out8(0xa1, 0xff);
}

void setup_keyboard() {
    
}