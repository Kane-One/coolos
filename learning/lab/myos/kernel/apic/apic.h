#ifndef MYOS_APIC
#define MYOS_APIC

#include "../cpu/cpu.h"

int enable_lapic(void);
int disable_eoi(void);

#endif