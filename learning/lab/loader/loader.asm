; 引导程序hello world

org 10000h							; 本程序会被加载到内存1MB处执行，所以这里设为10000h

jmp Label_Start

LoaderMessage:
    db "holy shit"

Label_Start:

	; 初始化一些段寄存器
    mov ax, 0                       
	mov ax, cs						 
	mov ds, ax						
	mov es, ax 						
	mov ss, ax 							

	; 打印holy shit
	mov ax, 1301h					; 当发生int 10h中断时（下面会触发），ah = 13h表示显示一行字符串，al=01h表示字符串属性由寄存器bl表示，字符串长度由寄存器cx表示
	mov bx, 000fh					; bl = 0fh表示字体颜色绿
	mov dx, 0100h					; dl表示行号，dh表示列号
	mov cx, 9						; 字符串长度为9
	mov bp, LoaderMessage		    ; es:bp指定要显示的字符串内存地址
	int 10h 						; 中断