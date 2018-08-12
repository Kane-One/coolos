;boot程序，FAT12文件系统驱动，载入loader.bin并执行

org 0x7c00												;指定程序起始地址

BaseOfStack 		equ 0x7fff
BaseOfExtraStack  	equ 0x7ec8
BaseOfLoader 		equ 0x1000
OffsetOfLoader 		equ 0x00


RootDirSectors 				equ 14						;根目录扇区数
SectorNumOfRootDirStart 	equ 19						;根目录起始扇区号
SectorNumOfFAT1Start 		equ 1						;FAT1扇区号
SectorBalance 				equ 17						;未知


	jmp short Label_Start								;段内跳转到Label_start处执行
	nop													;伪指令，啥也不干，这里应该只是为了凑个数，因为FAT12启动扇区格式为前3个字节为跳转指令

	BS_OEMName 				db 'MyOS'					;生产商
	BPB_BytesPerSec 		dw 512						;每个扇区512个字节
	BPB_SecPerClus			db 1						;每簇1个扇区
	BPB_RsvdSecCnt			db 1						;保留1个扇区，第一个扇区是启动扇区
	BPB_NumFATs				db 2						;两个FAT扇区
	BPB_RootEntCnt			dw 224						;根目录可容纳的目录项数
	BPB_TotalSec16			dw 2880						;总扇区数
	BPB_Media				db 0xf0						;介质类型
	BPB_FATSz16				dw 9						;每个FAT占用扇区数
	BPB_SecPerTrk			dw 18						;每个磁道扇区数
	BPB_NumHeads			dw 2						;磁头数
	BPB_HiddSec				dd 0						;隐藏扇区数
	BPB_TotSec32			dd 0
	BS_DrvNum				dd 0						;中断13（读取磁盘扇区）的驱动器号
	BS_Reserved1			dd 0
	BS_BootSig				dd 0x29						;扩展引导标志
	BS_VolID				dd 0						;卷序列号
	BS_VolLab				db 'MyOS       '			;卷标，必须是11个字符，不足以空格填充
	BS_FileSysType			db 'FAT12   '				;文件系统类型，必须是8个字符，不足填充空格


Label_Start:
	;初始化一些段寄存器
	mov 	ax, cs						;cs寄存器（代码段寄存器） -> ax寄存器 
	mov 	ds, ax						;ax寄存器 -> ds寄存器（数据段寄存器）
	mov 	es, ax 						;ax寄存器 -> es寄存器（附加段寄存器）
	mov 	ss, ax 						;ax寄存器 -> ss寄存器（堆栈段寄存器）
	mov 	sp, BaseOfStack 			;起始地址 -> sp寄存器（堆栈指针寄存器）
	mov 	ax, StartBootMessage
	mov 	bx, 13
	call	Func_Print
	jmp		Label_End



StartBootMessage:
	db "Hello world! " 				;db表示定义字节类型变量（define byte），定义一个字符串

StartBootMessage2:
	db "What is up?" 				;db表示定义字节类型变量（define byte），定义一个字符串


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
	; mov		dx, 0000h

	int     10h

	pop		es
	pop     bp
	pop  	cx
	pop		dx

	ret  									;ret指令，栈顶字单元出栈给ip寄存器（指令指针寄存器），调用前栈中压入了调用完应当执行的指令地址，因此这里可以返回继续执行



;读取一个扇区，执行下面代码时需先把ax设为待读取的磁盘起始逻辑扇区号，把cl设为读取扇区数量，bx设为缓存区地址

;---------------------------------------------------------------------------------
	; INT 10h,  02h         Read Disk Sectors


	; AH = 02
	; AL = number of sectors to read	(1-128 dec.)
	; CH = track/cylinder number  (0-1023 dec., see below)
	; CL = sector number  (1-17 dec.)
	; DH = head number  (0-15 dec.)
	; DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
	; ES:BX = pointer to buffer


	; on return:
	; AH = status  (see INT 13,STATUS)
	; AL = number of sectors read
	; CF = 0 if successful
	;    = 1 if error
;---------------------------------------------------------------------------------

Func_ReadOneSector:
	
	push	bp 								;把基址指针寄存器bp的值压入堆栈存起来
	mov		bp, sp 							;栈指针寄存器sp -> bp
	sub		esp, 2							;esp是32位的sp，esp寄存器减2，即把栈顶指针地址减2
	mov		byte [bp - 2], cl 				;把cl寄存器的值copy到bp - 2内存地址处，上面bp的值实际上是栈指针寄存器地址，因此这里实际上是在堆栈顶端地址 - 2处，结合上面2步，其实就是把cl的值压入堆栈的花式玩法
	push	bx								;把bx寄存器压如栈中
	mov		bl, [BPB_SecPerTrk]				;每个磁道扇区数 -> bl寄存器
	div		bl 								;bl是八位，所以被除数是16位的ax寄存器，商在al中，余数在ah中。
											;ax寄存器存了待读取的磁盘起始逻辑扇区号，扇区号除以每个磁道的扇区数的商存在al中，余数存在ah中。
	inc		ah								;按照公式，ah寄存器存的上述余数加1后得到起始扇区号
	mov		cl,	ah 							;ah -> cl，cl的6~7位存放磁道号（只对硬盘有效，这里没用到）,0~5位存放起始扇区号
	mov		dh,	al							;al -> dh, 方便后面计算
	shr 	al, 1							;根据公式，al右移1位得到磁道号
	mov 	ch, al							;al -> ch，磁道号存在ch中					
	and		dh, 1							;根据公式，上面计算得到的商和1进行位与运算，得到磁头号
	pop		bx 								;从栈里面弹出恢复之前的bx寄存器
	mov		dl, [BS_DrvNum]					;dl设置为驱动器号，到这里准备工作完成


;执行读取操作
Label_Go_On_Reading:

	mov		ah, 2							;准备触发int 13h，ah 02h中断
	mov		al, byte [bp - 2]				;把栈中保存的读取扇区数置入al中
	int		13h								;触发13h中断，即读取扇区
	jc		Label_Go_On_Reading				;jc是条件转移指令，当cf=1时跳转，如遇错误循环尝试

	add		esp, 2							;恢复esp
	pop 	bp 								;恢复bp
	ret 									

	mov		word 	[SectorNo],		SectorNumOfRootDirStart


Label_Search_In_Root_Dir_Begin:

	;开始遍历根目录扇区
	cmp		word 	[RootDirSizeForLoop],		0
	jz		Label_No_LoaderBin
	dec 	word 	[RootDirSizeForLoop]
	mov		ax,		0000h
	mov		es,		ax
	mov		bx,		BaseOfExtraStack				;缓存区设为扩展栈底地址
	; 下面两行准备好调用读取一个扇区内容的参数
	mov		ax,		[SectorNo]
	mov		cl,		1
	call	Func_ReadOneSector
	mov		si,		LoaderFileName					;把指向loader程序文件名的地址存在si寄存器
	mov		di,		BaseOfExtraStack				;把di寄存器重置为扩展栈段地址
	cld 											;df标志位置0 应该是clear df的缩写
	mov		dx,		10h 							;每个扇区512个字节，每个目录项占据32个字节，因此每个扇区有16个目录项


Label_Search_For_LoaderBin:

	cmp		dx,		0								;若一个扇区16个目录项都不符合则读取下个扇区接着匹配	
	jz		Label_Goto_Next_Sector_In_Root_Dir
	dec 	dx
	mov		cx,		11 								;cx存储loader.bin文件名长度为11


Label_Cmp_FileName:

	cmp 	cx,		0
	jz 		Label_FileName_Found
	dec 	cx
	;下面开始逐个字符对比文件名
	lodsb											;从ds:si读取一个字节，存入al中，ds:si上面指向的是loader程序文件名地址
	cmp 	al,		byte 	[es:di]					;与从扇区读取放入缓冲区的数据做对比，每个目录项前32个字节为文件名
	jz		Label_Go_On 							;相同则接着取下一个字节对比
	jmp		Label_Different


Label_Go_On:

	inc		di
	jmp		Label_Cmp_FileName


Label_Different:

	and		di,		0ffe0h							;因为每个文件项占32个内存单元，所以每个文件项起始地址都是二进制100000的整数倍，低5位清零后相当于回到文件项起始处
	add		di,		20h								;前进32个内存单元，即下一个文件项开始
	
	mov		si,		LoaderFileName
	jmp		Label_Search_For_LoaderBin


Label_Goto_Next_Sector_In_Root_Dir:

	add		word 	[SectorNo],		1
	jmp 	Label_Search_In_Root_Dir_Begin


Label_No_LoaderBin:

	mov		ax,		1301h
	mov		bx,		008ch
	mov		dx,		0100h
	mov		cx,		21
	push	ax
	mov		ax,		ds
	mov 	es,		ax
	pop		ax
	mov		bp,		NoLoaderMessage
	int 	10h
	jmp		$


Func_GetFATEntry:
	
	push	es
	push	bx
	push	ax
	mov		ax,		00
	mov		es,		ax
	pop		ax
	mov		byte 	[Odd],		0
	mov	 	bx,		3
	mul		bx
	mov		bx,		2
	div		bx
	cmp 	dx,		0
	jz		Label_Even
	mov		byte 	[Odd],		1


Label_Even:

	xor		dx,		dx
	mov		bx,		[BPB_BytesPerSec]
	div		bx
	push	dx
	mov		bx,		8000h
	add		ax,		SectorNumOfFAT1Start
	mov		cl,		2
	call	Func_ReadOneSector

	pop		dx
	add		bx,		dx
	mov		ax,		[es:bx]
	cmp 	byte  	[Odd],		1
	jnz		Label_Even_2
	shr 	ax,		4


Label_Even_2:

	and		ax,		0fffh
	pop		bx
	pop		es
	ret


Label_FileName_Found:

	mov		ax,		RootDirSectors
	and		di,		0ffe0h
	add		di,		01ah
	mov		cx,		word 		[es:di]
	push	cx
	add		cx,		ax
	add		cx,		SectorBalance
	mov		ax,		BaseOfLoader
	mov		es,		ax
	mov		bx,		OffsetOfLoader
	mov		ax,		cx


Label_Go_On_Loading_File:

	push 	ax
	push	bx
	mov		ah,		0eh
	mov		al,		'.'
	mov		bl,		0fh
	int 	10h
	pop		bx
	pop		ax

	mov		cl,		1
	call	Func_ReadOneSector
	pop		ax
	call 	Func_GetFATEntry
	cmp 	ax,		0fffh
 	jz 		Label_File_Loaded
 	push	ax
 	mov		dx, 	RootDirSectors
 	add		ax,		dx
 	add		ax,		SectorBalance
 	add		bx,		[BPB_BytesPerSec]
 	jmp 	Label_Go_On_Loading_File


Label_File_Loaded:

	jmp		$


RootDirSizeForLoop:	dw 	RootDirSectors
SectorNo: 			dw 	0
Odd:				db  0
NoLoaderMessage:	db 	"Error: No Loader Found"
LoaderFileName:		db 	"LOADER BIN", 0


;结束地址
Label_End:



;用0填满本扇区，并以55aa结尾代表这是一个启动扇区
Label_Fill_Boot_Section:
	times 510 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区
	dw 0xaa55						;dw表示定义字类型变量（define word），以0x55 和 0xaa结尾标识这个扇区是一个引导扇区

