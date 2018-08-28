    cli
    db      0x66
    lgdt    [GdtPtr]

    db      0x66
    lidt    [IDT_POINTER]

    mov     eax,    cr0
    or      eax,    1           ; 最后一位置1
    mov     cr0,    eax         ; 开启保护模式

    jmp     dword   SelectorCode32:G0_TO_TMP_PROTECT



[SECTION .s32]
[BITS 32]

support_long_mode:

; cpuid指令
; EAX=80000000h: Get Highest Extended Function Supported
; The highest calling parameter is returned in EAX.

    mov     eax,    0x80000000
    cpuid     ; 获取cpu的一些信息
    cmp     eax,    0x80000001
    setnb   al      ; set when not below，当上面的cmp不小于的时候al置1
    jb      support_long_mode_done
    mov     eax,    0x80000001
    cpuid
    bt      edx,    29  ;执行上面cpuid后，edx第29位表示是否支持IA-32e模式，把该位赋值给cf标志位
    setc    al          ;当cf为1时al置1

support_long_mode_done:

    movzx   eax,    al
    ret

no_support:

    jmp $


G0_TO_TMP_PROTECT:

    mov     ax,     0x10        ; 设置各个段寄存器，段基地址设为10000处
    mov     ds,     ax
    mov     es,     ax
    mov     fs,     ax
    mov     ss,     ax
    mov     esp,    7e00h

    call    support_long_mode
    ; 如果支持长模式，则eax为1，test后zf标志位为0
    test    eax,    eax

    jz      no_support          ; 相同表示eax还是原来的值，不支持



    ; 设置页表项

    mov     dword   [0x90000],  0x91007
    mov     dword   [0x90800],  0x91007

    mov     dword   [0x91000],  0x92007

    mov     dword   [0x92000],  0x000083
    mov     dword   [0x92008],  0x200083
    mov     dword   [0x92010],  0x400083
    mov     dword   [0x92018],  0x600083
    mov     dword   [0x92020],  0x800083
    mov     dword   [0x92028],  0xa00083



    db  0x66
    lgdt    [GdtPtr64]
    mov     ax,     0x10
    mov     ds,     ax
    mov     es,     ax
    mov     fs,     ax
    mov     gs,     ax
    mov     ss,     ax

    mov     esp,    7e00h

    mov     eax,    cr4
    bts     eax,    5
    mov     cr4,    eax


    mov     eax,    0x90000
    mov     cr3,    eax


    mov     ecx,    0c0000080h
    rdmsr

    bts     eax,    8
    wrmsr

    mov     eax,    cr0
    bts     eax,    0
    bts     eax,    31
    mov     cr0,    eax


    ; jmp $
    jmp     SelectorCode64:OffsetOfKernelFile


[SECTION gdt]
[BITS 32]
; 全局描述符表，每个段描述符64位（8个字节）

LABLE_GDT:      dd      0, 0                            ; 第一个段描述符必须是0
LABLE_DESC_CODE32:      dd      0x0000ffff,0x00cf9a00   ; 从低到高是      FF FF 00 00 00 9A CF 00
                                                        ; 从高到底是      00 cf 9a 00 00 00 ff ff  
                                                        ; 按照代码段描述符的格式划分后得到
                                                            ; Base:   00h
                                                            ; G:      1b，段大小以4K为单位计
                                                            ; B:      1b
                                                            ; O:      0b
                                                            ; AVI:    0b
                                                            ; Limit:  fh
                                                            ; 1:      1b
                                                            ; DPI:    00b
                                                            ; S:      1b，表示普通代码或数据段
                                                            ; TYPE:   ah，段权限为执行、可读
                                                            ; Base:   00h
                                                            ; Base:   0000h
                                                            ; Limit:  ffffh

                                                        ; 段限长 fffffh  单位是4k，所以先限长是4G
                                                        ; 段基地址 00000000h


LABEL_DESC_DATA32:      dd      0x0000ffff,0x00cf9200   ; 从低到高      ffff 0000 0092 cf00 
                                                        ; 从高到低      00 cf 92 00 00 00 ff ff
                                                        ; 跟上个段描述符一样，只是type位是2h，表示可读写


; 定义全局描述表大小
GdtLen          equ     $ - LABLE_GDT


; 定义全局描述表的基址与大小，基址是32位，4个字节，大小是2个字节
GdtPtr          dw      GdtLen - 1 ; 
                dd      LABLE_GDT

SelectorData32  equ     LABEL_DESC_DATA32 - LABLE_GDT
SelectorCode32  equ     LABLE_DESC_CODE32 - LABLE_GDT

IDT:
    times   0x50        dq      0
IDT_END:

IDT_POINTER:
    dw      IDT_END - IDT - 1
    dd      IDT


[SECTION gdt64]

LABEL_GDT64:         dq  0x0000000000000000
LABLE_DESC_CODE64:   dq  0x0020980000000000
LABEL_DESC_DATA64:   dq  0x0000920000000000

GdtLen64    equ     $ - LABEL_GDT64
GdtPtr64    dw      GdtLen64 - 1
            dd      LABEL_GDT64

SelectorCode64  equ LABLE_DESC_CODE64 - LABEL_GDT64
SelectorData64  equ LABEL_DESC_DATA64 - LABEL_GDT64

