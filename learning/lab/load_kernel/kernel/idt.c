#include "idt.h"
#include "head.h"
#include "graph/graph.h"

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

void idt_init_desc(gate_desc *gate, const struct idt_data *d)
{
    unsigned long addr = (unsigned long)d->addr;

    gate->offset_low = (u16)addr;
    gate->segment = (u16)d->segment;
    gate->bits = d->bits;
    gate->offset_middle = (u16)(addr >> 16);
    gate->offset_high = (u32)(addr >> 32);
    gate->reserved = 0;
}

void set_intr_gate(int n, const void *addr)
{
    // 准备中断段描述符数据
    struct idt_data data;
    gate_desc gate;

    data.vector = n;
    data.segment = KERNEL_CS;
    data.addr = addr;

    data.bits.type = GATE_INTERRUPT;
    data.bits.p = 1;
    data.bits.ist = 0;
    data.bits.zero = 0;
    data.bits.dpl = 0;

    // 按规定格式转化为128位的中断段描述符

    idt_init_desc(&gate, &data);

    // 写入内存
    long long idt_base = BASE_ADDRESS + 0x104092;
    int *idt = (int *)(idt_base + 16 * n);
    memcpy(idt, &gate, 16);
}

void set_up_idt(void)
{
}