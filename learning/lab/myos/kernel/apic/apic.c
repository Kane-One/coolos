#include "apic.h"
#include "../video/video.h"
#include "../memory/memory.h"

int enable_lapic(void)
{
  int x;
  int y;
  asm volatile(
      "movq $0x1b, %%rcx;"
      "rdmsr;"
      "bts $10, %%rax;"
      "bts $11, %%rax;"
      "wrmsr;"
      "movq $0x1b, %%rcx;"
      "rdmsr;"
      : "=a"(x), "=d"(y)
      :
      : "memory");

  return (x == 0 || y == 0) ? 0 : -1;
}

int disable_eoi(void)
{
  int x;
  int y;
  asm volatile(
      "movq $0x80f, %%rcx;"
      "rdmsr;"
      "bts $8, %%rax;"
      "bts $12, %%rax;"
      "wrmsr;"
      "movq $0x80f, %%rcx;"
      "rdmsr;"
      : "=a"(x), "=d"(y)
      :
      : "memory");

  return (x == 0 || y == 0) ? 0 : -1;
}