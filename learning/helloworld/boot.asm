;boot程序，仅显示hello world！

org 0x7c00							;指定程序起始地址

BaseofStack equ 0x7c00

Label_Start:

	;初始化一些段寄存器
	mov ax, cs						;cs寄存器（代码段寄存器） -> ax寄存器 
	mov ds, ax						;ax寄存器 -> ds寄存器（数据段寄存器）
	mov es, ax 						;ax寄存器 -> es寄存器（附加段寄存器）
	mov ss, ax 						;ax寄存器 -> ss寄存器（堆栈段寄存器）
	mov sp, BaseofStack 			;a起始地址 -> sp寄存器（堆栈指针寄存器）

	;打印ello world到屏幕，鸡冻吗？
	mov ax, 1301h					;当发生int 10h中断时（下面会触发），ah = 13h表示显示一行字符串，al=01h表示字符串属性由寄存器bl表示，字符串长度由寄存器cx表示
	mov bx, 000fh					;bl = 0fh表示字体颜色绿
	mov dx, 0000h					;dl表示行号，dh表示列号
	mov cx, 12						;字符串长度为11
	push ax 						;寄存器ax要干点临时活，先把它的值压入堆栈
	mov ax,ds 						;数据段地址 -> ax寄存器
	mov es,ax 						;ax寄存器 -> es寄存器
	pop ax 							;把之前压如堆栈的值弹出到ax寄存器
	mov bp, StartBootMessage		;es:bp指定要显示的字符串内存地址
	int 10h 						;中断

StartBootMessage:

	db "hello world!" 				;db表示定义字节类型变量（define byte），定义一个字符串
	times 510 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区
	dw 0xaa55						;dw表示定义字类型变量（define word），以0x55 和 0xaa结尾标识这个扇区是一个引导扇区

