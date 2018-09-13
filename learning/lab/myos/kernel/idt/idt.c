#include "idt.h"
#include "../head.h"
#include "../memory/memory.h"
#include "../video/video.h"

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
    struct idt_data *data = (struct idt_data *)malloc(sizeof(struct idt_data));
    gate_desc *gate = (gate_desc *)malloc(sizeof(gate_desc));

    data->vector = n;
    data->segment = KERNEL_CS;
    data->addr = addr;

    data->bits.type = GATE_INTERRUPT;
    data->bits.p = 1;
    data->bits.ist = 0;
    data->bits.zero = 0;
    data->bits.dpl = 0;

    // 按规定格式转化为128位的中断段描述符
    idt_init_desc(gate, data);

    // 写入内存
    int *idt = (int *)(IDT_BASE + 16 * n);
    memcpy(idt, gate, 16);
}

void test_int(void)
{
    printl("Testing interrupt procedure is triggered");
}

void div_error(void)
{
    printl("Div error detected.");
}

void tmp_int(void)
{
    printl("Unhandled error");
}

void set_up_idt(void)
{
    int i = 1;
    for (; i < 33; i++)
    {
        set_intr_gate(i, tmp_int);
    }
    set_intr_gate(0, div_error);
    set_intr_gate(33, test_int);
}
