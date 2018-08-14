; 实验，开启big real mode，寻址4G的实模式

org 10000h

jmp Label_Start

%include "../include/print.asm"

Label_Start:

push    ax
; A20引脚设为高电平，开启32位地址线
in      al,     92h
or      al,     00000010b
out     92h,    al
pop     ax

cli     ; 禁止中断

db      0x66
lgdt    [GdtPtr]            ; 设置全局描述符表格寄存器 (GDTR) 地址

mov     eax,    cr0
or      eax,    1           ; 最后一位置1
mov     cr0,    eax         ; 开启保护模式

mov     ax,     SelectorData32
mov     fs,     ax
mov     eax,    cr0
and     al,     11111110b
mov     cr0,    eax

sti



