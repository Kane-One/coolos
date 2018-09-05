#include "graph/graph.h"
#include "idt.h"

void Div_Error(void)
{
    print_string("div error detected.", 40, 10, 0xffcc00);
}

void Start_Kernel(void)
{
    set_screen_color(0x022b35);
    print_string("MyOS is a OS which has nothing to do with you at all. Fuck off, idiot.", 10, 10, 0x839496);

    set_intr_gate(0, Div_Error);

    // 触发一个除法错误
    int a = 10;
    int b = 0;
    int c = 0;
    c = a / b;
    while (1)
        ;
}