#include "head.h"
#include "video/video.h"
#include "idt/idt.h"
#include "apic/apic.h"
#include "memory/memory.h"
#include "cpu/cpu.h"

void Start_Kernel(void)
{
    // 设置IDT
    set_up_idt();

    // 初始化屏幕
    init_screen();

    printl("");
    printl("MyOS is running...");
    printl("");

    // 触发测试中断
    __asm__("int $33");

    if (enable_lapic() < 0)
    {
        printl("Failed to enable Local APIC");
    }
    else
    {
        printl("Local APIC enabled...");
    }

    print_cpuid(1, 0);
    printl("------");
    
    printl("802:");
    print_msr(0x802);
    
    printl("803:");
    print_msr(0x803);
    // if (disable_eoi() < 0)
    // {
    //     printl("Failed to disable EOI");
    // }
    // else
    // {
    //     printl("EOI disabled...");
    // }

    while (1)
        ;
}
