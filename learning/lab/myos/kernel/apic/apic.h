#ifndef MYOS_APIC
#define MYOS_APIC

#include "../cpu/cpu.h"

int enable_x2apic(void);

int enable_software_lapic(void);

int disable_eoi(void);

void disable_lvt();

void disable_8259a();

void setup_keyboard();
#endif