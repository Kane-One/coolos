#ifndef MYOS_MEMORY
#define MYOS_MEMORY

#include "../head.h"
// 从10MB处开始
#define BASE_MEMORY_ADDRESS (BASE_ADDRESS + 0xa00000)

// 单位byte
unsigned int memory_used;


void *memcpy(void *dest, const void *src, size_t n);

void *malloc(unsigned int n);


#endif