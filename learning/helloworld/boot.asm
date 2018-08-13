; hello world
org 0x7c00

jmp Label_Start

LoaderMessage:
    db "hello world!"

Label_Start:

	; 初始化一些段寄存器
    mov ax, 0                       
	mov ax, cs						 
	mov ds, ax						
	mov es, ax 												

	; 打印holy shit
	mov ax, 1301h					; 当发生int 10h中断时（下面会触发），ah = 13h表示显示一行字符串，al=01h表示字符串属性由寄存器bl表示，字符串长度由寄存器cx表示
	mov bx, 000fh					; bl = 0fh表示字体颜色绿
	mov dx, 0000h					; dl表示行号，dh表示列号
	mov cx, 12						; 字符串长度为12
	mov bp, LoaderMessage		    ; es:bp指定要显示的字符串内存地址
	int 10h 						; 中断

	; 填满512个字节且以0x55、0xaa结尾
	times 510 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区
	dw 0xaa55						;dw表示定义字类型变量（define word），以0x55 和 0xaa结尾标识这个扇区是一个引导扇区