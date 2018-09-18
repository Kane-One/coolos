#include "head.h"
#include "video/video.h"
#include "idt/idt.h"
#include "apic/apic.h"
#include "memory/memory.h"
#include "cpu/cpu.h"


void die(char *msg) {
    printl(msg);
    while (1);
}

void Start_Kernel(void) {
    // 设置IDT
    set_up_idt();

    // 初始化屏幕
    init_screen();

    printl("");
    printl("MyOS is running...");
    printl("");

    // 触发测试中断
    __asm__("int $33");

    if (enable_x2apic() < 0) {
        die("Failed to enable X2APIC mode");
    } else {
        printl("X2APIC mode enabled...");
    }

    if (enable_software_lapic() < 0) {
        die("Failed to enable APIC software");
    } else {
        printl("APIC software enabled, EOI disabled...");
    }

    disable_lvt();
    printl("LVT all disabled");

    disable_8259a();
    printl("8259a disabled");

    setup_keyboard();

    printl("");
    die("OS has nothing to do now.");

}
