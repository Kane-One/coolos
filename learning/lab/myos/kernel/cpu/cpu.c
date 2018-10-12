#include "cpu.h"

void get_cpuid(unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d)
{
    asm volatile("cpuid"     // 汇编模板
                 : "=a"(*a), // 输出项（必须带=）
                   "=b"(*b),
                   "=c"(*c),
                   "=d"(*d)
                 : "0"(*a), "2"(*c) // 输入项
                 : "memory");
}

void print_cpuid(int a, int c)
{
    char *s = (char *)malloc(33);

    // Error __stack_chk_fail
    // int eax = a;
    // int ebx = 0;
    // int ecx = c;
    // int edx = 0;
    // get_cpuid(&eax, &ebx, &ecx, &edx);

    int *eax = (int *)malloc(4);
    int *ebx = (int *)malloc(4);
    int *ecx = (int *)malloc(4);
    int *edx = (int *)malloc(4);
    *eax = a;
    *ebx = 0;
    *ecx = c;
    *edx = 0;
    get_cpuid(eax, ebx, ecx, edx);

    b2s(s, *eax, 32);
    printl("eax");
    printl(s);
    b2s(s, *ebx, 32);
    printl("ebx");
    printl(s);
    b2s(s, *ecx, 32);
    printl("ecx");
    printl(s);
    b2s(s, *edx, 32);
    printl("edx");
    printl(s);
}

void rdmsr(unsigned long *rax, unsigned long *rcx)
{
    asm volatile(
        "movq %0, %%rcx;"
        "rdmsr"    // 汇编模板
        : "=a"(*rax) // 输出项（必须带=）
        : "0"(*rcx)  // 输入项
        : "memory");
}

void print_msr(unsigned long c)
{
    char *s = (char *)malloc(65);
    unsigned long *rax = (unsigned long *)malloc(8);
    unsigned long *rcx = (unsigned long *)malloc(8);

    *rax = 0;
    *rcx = c;
    rdmsr(rax, rcx);

    b2s(s, *rax, 64);
    printl(s);
}