; 实验，开启big real mode，寻址4G的实模式

org 0x7c00

jmp Label_Start

%include "../include/print.asm"

Label_Start:

; A20引脚设为高电平，开启32位地址线
in      al,     92h
or      al,     00000010b
out     92h,    al

cli     ; 禁止中断

db      0x66    ; 下面lgdt指令的前缀，表示32位

; LGDT/LIDT - 加载全局/中断描述符表格寄存器
; 将源操作数中的值加载到全局描述符表格寄存器 (GDTR) 或中断描述符表格寄存器 (IDTR)。
; 源操作数指定 6 字节内存位置，它包含全局描述符表格 (GDT) 或中断描述符表格 (IDT) 的基址（线性地址）与限制（表格大小，以字节计）。
; 如果操作数大小属性是 32 位，则将 16 位限制（6 字节数据操作数的 2 个低位字节）与 32 位基址（数据操作数的 4 个高位字节）加载到寄存器。
; 如果操作数大小属性是 16 位，则加载 16 位限制（2 个低位字节）与 24 位基址（第三、四、五字节）。这里，不使用操作数的高位字节，GDTR 或 IDTR 中基址的高位字节用零填充。
; LGDT 与 LIDT 指令仅用在操作系统软件中；它们不用在应用程序中。在保护模式中，它们是仅有的能够直接加载线性地址（即，不是段相对地址）与限制的指令。
lgdt    [GdtPtr]            ; 设置全局描述符表格寄存器 (GDTR) 地址

mov     eax,    cr0
or      eax,    1           ; 最后一位置1
mov     cr0,    eax         ; 开启保护模式

mov     ax,     SelectorData32
mov     fs,     ax
mov     eax,    cr0
and     al,     11111110b
mov     cr0,    eax         ; 关闭保护模式

sti     ; 开启中断

mov     ecx,0x0001
mov     byte [fs:ecx],       0xff      ; 32位寻址

mov     ax,     Message
mov     bx,     13
call    Func_Print

jmp     $





; 全局描述符表，每个段描述符64位（8个字节）

LABLE_GDT:      dd      0, 0                            ; 第一个段描述符必须是0
LABLE_DESC_CODE32:      dd      0x0000ffff,0x00cf9a00   ; 实际上是ffff 0000 009a cf00，
                                                        ; 偏移量cf00h, 首字节线性地址0xff00009a

; 定义全局描述表大小
GdtLen          equ     $ - LABLE_GDT


; 定义全局描述表的基址与大小，基址是32位，4个字节，大小是2个字节
GdtPtr          dw      GdtLen - 1 ; 
                dd      LABLE_GDT



SelectorData32  equ     LABLE_DESC_CODE32 - LABLE_GDT

Message:
    db "big real mode"




	; 填满512个字节且以0x55、0xaa结尾
	times 510 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区
	dw 0xaa55						;dw表示定义字类型变量（define word），以0x55 和 0xaa结尾标识这个扇区是一个引导扇区