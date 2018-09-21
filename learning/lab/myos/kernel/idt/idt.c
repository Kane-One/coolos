#include "idt.h"
#include "../head.h"
#include "../memory/memory.h"
#include "../video/video.h"

void idt_init_desc(gate_desc *gate, const struct idt_data *d) {
    unsigned long addr = (unsigned long) d->addr;

    gate->offset_low = (u16) addr;
    gate->segment = (u16) d->segment;
    gate->bits = d->bits;
    gate->offset_middle = (u16) (addr >> 16);
    gate->offset_high = (u32) (addr >> 32);
    gate->reserved = 0;
}

void set_intr_gate(int n, const void *addr) {
    // 准备中断段描述符数据
    struct idt_data *data = (struct idt_data *) malloc(sizeof(struct idt_data));
    gate_desc *gate = (gate_desc *) malloc(sizeof(gate_desc));

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
    int *idt = (int *) (IDT_BASE + 16 * n);
    memcpy(idt, gate, 16);
}

void test_int(void) {
    printl("Testing interrupt works fine");
}

void div_error(void) {
    printl("Div error detected.");
}

void tmp_int(void) {
    printl("Unhandled error");
    asm("hlt");
}


void interrupt_handle_0() {
    printl("interrupt 0");
}

void interrupt_handle_1() {
    printl("interrupt 1");
}

void interrupt_handle_2() {
    printl("interrupt 2");
}

void interrupt_handle_3() {
    printl("interrupt 3");
}

void interrupt_handle_4() {
    printl("interrupt 4");
}

void interrupt_handle_5() {
    printl("interrupt 5");
}


void interrupt_handle_6() {
    printl("interrupt 6 - Invalid Opcode");
}

void interrupt_handle_7() {
    printl("interrupt 7");
}

void interrupt_handle_8() {
    printl("interrupt 8 - Double Fault");
}

void interrupt_handle_9() {
    printl("interrupt 9");
}

void interrupt_handle_10() {
    printl("interrupt 10");
}

void interrupt_handle_11() {
    printl("interrupt 11");
}

void interrupt_handle_12() {
    printl("interrupt 12");
}

void interrupt_handle_13() {
    printl("interrupt 13 - General Protection");
}

void interrupt_handle_14() {
    printl("interrupt 14 - Page Fault");
}

void interrupt_handle_15() {
    printl("interrupt 15");
}

void interrupt_handle_16() {
    printl("interrupt 16");
}

void interrupt_handle_17() {
    printl("interrupt 17");
}

void interrupt_handle_18() {
    printl("interrupt 18");
}

void interrupt_handle_19() {
    printl("interrupt 19");
}

void interrupt_handle_20() {
    printl("interrupt 20");
}

void interrupt_handle_32() {
    printl("interrupt 32");
}

void interrupt_handle_33() {
    printl("interrupt 33");
}

void interrupt_handle_34() {
    printl("interrupt 34");
}

void interrupt_handle_35() {
    printl("interrupt 35");
}

void interrupt_handle_36() {
    printl("interrupt 36");
}

void interrupt_handle_37() {
    printl("interrupt 37");
}

void interrupt_handle_38() {
    printl("interrupt 38");
}

void interrupt_handle_39() {
    printl("interrupt 39");
}

void interrupt_handle_40() {
    printl("interrupt 40");
}

void interrupt_handle_41() {
    printl("interrupt 41");
}

void interrupt_handle_42() {
    printl("interrupt 42");
}

void interrupt_handle_43() {
    printl("interrupt 43");
}

void interrupt_handle_44() {
    printl("interrupt 44");
}

void interrupt_handle_45() {
    printl("interrupt 45");
}

void interrupt_handle_46() {
    printl("interrupt 46");
}

void interrupt_handle_47() {
    printl("interrupt 47");
}

void interrupt_handle_48() {
    printl("interrupt 48");
}

void interrupt_handle_49() {
    printl("interrupt 49");
}

void interrupt_handle_50() {
    printl("interrupt 50");
}

void interrupt_handle_51() {
    printl("interrupt 51");
}

void interrupt_handle_52() {
    printl("interrupt 52");
}

void interrupt_handle_53() {
    printl("interrupt 53");
}

void interrupt_handle_54() {
    printl("interrupt 54");
}

void interrupt_handle_55() {
    printl("interrupt 55");
}

void interrupt_handle_56() {
    printl("interrupt 56");
}

void set_up_idt(void) {
    set_intr_gate(0, interrupt_handle_0);
    set_intr_gate(1, interrupt_handle_1);
    set_intr_gate(2, interrupt_handle_2);
    set_intr_gate(3, interrupt_handle_3);
    set_intr_gate(4, interrupt_handle_4);
    set_intr_gate(5, interrupt_handle_5);
    set_intr_gate(6, interrupt_handle_6);
    set_intr_gate(7, interrupt_handle_7);
    set_intr_gate(8, interrupt_handle_8);
    set_intr_gate(9, interrupt_handle_9);
    set_intr_gate(10, interrupt_handle_10);
    set_intr_gate(11, interrupt_handle_11);
    set_intr_gate(12, interrupt_handle_12);
    set_intr_gate(13, interrupt_handle_13);
    set_intr_gate(14, interrupt_handle_14);
    set_intr_gate(15, interrupt_handle_15);
    set_intr_gate(16, interrupt_handle_16);
    set_intr_gate(17, interrupt_handle_17);
    set_intr_gate(18, interrupt_handle_18);
    set_intr_gate(19, interrupt_handle_19);
    set_intr_gate(20, interrupt_handle_20);


    // 以下是可屏蔽外中断
    set_intr_gate(32, interrupt_handle_32);
    set_intr_gate(33, interrupt_handle_33);
    set_intr_gate(34, interrupt_handle_34);
    set_intr_gate(35, interrupt_handle_35);
    set_intr_gate(36, interrupt_handle_36);
    set_intr_gate(37, interrupt_handle_37);
    set_intr_gate(38, interrupt_handle_38);
    set_intr_gate(39, interrupt_handle_39);
    set_intr_gate(40, interrupt_handle_40);
    set_intr_gate(41, interrupt_handle_41);
    set_intr_gate(42, interrupt_handle_42);
    set_intr_gate(43, interrupt_handle_43);
    set_intr_gate(44, interrupt_handle_44);
    set_intr_gate(45, interrupt_handle_45);
    set_intr_gate(46, interrupt_handle_46);
    set_intr_gate(47, interrupt_handle_47);
    set_intr_gate(48, interrupt_handle_48);
    set_intr_gate(49, interrupt_handle_49);
    set_intr_gate(50, interrupt_handle_50);
    set_intr_gate(51, interrupt_handle_51);
    set_intr_gate(52, interrupt_handle_52);
    set_intr_gate(53, interrupt_handle_53);
    set_intr_gate(54, interrupt_handle_54);
    set_intr_gate(55, interrupt_handle_55);
    set_intr_gate(56, interrupt_handle_56);

    int i;
    for (i = 57; i < 256; i++) {
        set_intr_gate(i, tmp_int);
    }
}