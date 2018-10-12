#include "head.h"
#include "video/video.h"
#include "idt/idt.h"
#include "apic/apic.h"
#include "memory/memory.h"
#include "cpu/cpu.h"


void die(char *msg) {
    printl(msg);

    while (1) {
        asm("hlt");
    }
}

void Start_Kernel(void) {

    // 设置IDT
    set_up_idt();

    // 初始化屏幕
    init_screen();

    printl("");
    printl("MyOS is running...");
    printl("");

    long long gdt = get_gdt();

    char *s = (char *) malloc(32);

    n2s(s, gdt);

    printl(s);
    die("OS has nothing to do now.");

    // 触发测试中断
    __asm__("int $5");

    // 初始化x2apic
    if (init_x2apic() < 0) {
        die("");
    }

    setup_keyboard();


    printl("");
    die("OS has nothing to do now.");

}
