;封装在当前光标处打印字符串程序，以便调用，调用前，ax存入字符串起始地址，bx存入字符串长度
Func_Print:
; 用 int 10h 03h 获取光标信息，用 int 10h 13h打印字符串，下面是这两个中段的用法

;---------------------------------------------------------------------------------
; INT 10h,  03h (3)        Read Cursor Position and Size

;     Reports the cursor position (row and column) and size for a specified
;     display page.

;        On entry:      AH         03h
;                       BH         Display page number

;        Returns:       CH         Cursor start line
;                       CL         Cursor end line
;                       DH         Row
;                       DL         Column

;        Registers destroyed:      AX, SP, BP, SI, DI

;---------------------------------------------------------------------------------
; INT 10h,  13h (19)       Write Character String                          many
 
;     Writes a string of characters with specified attributes to any display
;     page.
 
;        On entry:      AH         13h
;                       AL         Subservice (0-3)
;                       BH         Display page number
;                       BL         Attribute (Subservices 0 and 1)
;                       CX         Length of string
;                       DH         Row position where string is to be written
;                       DL         Column position where string is to be written
;                       ES:BP      Pointer to string to write
 
;        Returns:       None
 
;        Registers destroyed:      AX, SP, BP, SI, DI

;---------------------------------------------------------------------------------
	;ax bx cx dx入栈保存

	push	dx
	push	cx
	push	bx
	push	ax

	mov		ah, 03h
	mov		bh, 0

	int 	10h								;触发中断获取光标位置，此时dh=行号，dl=列号

	pop		ax
	pop		bx

	push	bp
	push	es

	mov		cx, bx
	mov		bp, ax 							;ES:BP指向字符串起始地址
	mov		ax, ds
	mov     es, ax
	mov		ax, 1301h
	mov		bx, 000fh

	int     10h

	pop		es
	pop     bp
	pop  	cx
	pop		dx

	ret  									;ret指令，栈顶字单元出栈给ip寄存器（指令指针寄存器），调用前栈中压入了调用完应当执行的指令地址，因此这里可以返回继续执行
