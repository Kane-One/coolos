;封装在当前光标处打印字符串程序，以便调用，调用前，ax存入字符串起始地址的偏移地址，bx存入字符串长度
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
	push	cx
	push	dx
	push	ax
	push	bx
	mov		ah, 03h
	mov		bh,	0
	int		10h
	pop		bx
	pop		ax

	mov		cx,	bx
	mov		bx,	cs
	push	es
	mov		es,	bx
	push	bp
	mov		bp,	ax

	mov 	bx, 000fh					; bl = 0fh表示字体颜色绿
	mov		ax, 1301h
	add		dh, 1
	mov		dl, 0
	int 	10h

	pop 	bp
	pop		es
	pop		dx
	pop		cx

	ret