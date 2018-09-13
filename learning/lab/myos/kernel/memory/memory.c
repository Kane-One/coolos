#include "memory.h"

void *memcpy(void *dest, const void *src, size_t n)
{
    char *tmp_dest = (char *)dest;
    const char *tmp_src = (const char *)src;

    int i = 0;

    for (; i < n; i++)
    {
        tmp_dest[i] = tmp_src[i];
    }

    return dest;
}

void *malloc(unsigned int n)
{
    long address = BASE_MEMORY_ADDRESS + memory_used;
    memory_used += n;
    return (void *)(address);
}