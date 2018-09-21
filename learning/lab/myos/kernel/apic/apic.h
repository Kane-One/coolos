#ifndef MYOS_APIC
#define MYOS_APIC

#include "../cpu/cpu.h"


struct ioapic_map_s {
    unsigned int physical_address;
    unsigned char *virtual_index_address;
    unsigned int *virtual_data_address;
    unsigned int *virtual_eoi_address;
} ioapic_map;


int disable_x2apic(void);

int enable_x2apic(void);

int enable_software_lapic(void);

void mask_lvts();

void disable_8259a();

void cli();

void sti();

void setup_keyboard();

int init_x2apic();

void ioapic_remap();


#endif