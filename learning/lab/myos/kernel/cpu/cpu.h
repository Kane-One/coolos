#ifndef MYOS_CPU
#define MYOS_CPU

#include "../memory/memory.h"
#include "../video/video.h"

void get_cpuid(unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d);

void print_cpuid(int a, int c);
void rdmsr(unsigned long *rax, unsigned long *rcx);
void print_msr(int c);

#endif
