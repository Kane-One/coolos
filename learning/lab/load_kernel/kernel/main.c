#include "graph/graph.h"
#include "idt.h"

void test_int(void)
{
    print_string("testing interrupt procedure is triggered", 30, 10, 0xffcc00);
}

void Div_Error(void)
{
    print_string("div error detected.", 50, 10, 0xffcc00);
}

void Start_Kernel(void)
{
    set_screen_color(0x022b35);

    print_string("MyOS is running...", 10, 10, 0x839496);

    set_intr_gate(0, Div_Error);

    set_intr_gate(33, test_int);

    // 触发测试中断
    __asm__("int $33");

    // 触发一个除法错误
    int a = 10;
    int b = 0;
    int c = 0;
    c = a / b;

    while (1)
        ;
}



