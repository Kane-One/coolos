org 0x10000

	jmp Label_Start


BaseOfKernelFile        equ     0x00
OffsetOfKernelFile      equ     0x100000
BaseTmpOfKernelAddr     equ     0x00
OffsetTmpOfKernelFile   equ     0x7e00
MemoryStructBufferAddr  equ     0x7e00

RootDirSectors 				equ 14						;根目录扇区数
SectorNumOfRootDirStart 	equ 19						;根目录起始扇区号
SectorNumOfFAT1Start 		equ 1						;FAT1扇区号
SectorBalance 				equ 17						;未知

	BS_OEMName 				db '        '				;生产商，8个字节，不足以空格填充
	BPB_BytesPerSec 		dw 512						;每个扇区512个字节
	BPB_SecPerClus			db 1						;每簇1个扇区
	BPB_RsvdSecCnt			dw 1						;保留1个扇区，第一个扇区是启动扇区
	BPB_NumFATs				db 2						;两个FAT扇区
	BPB_RootEntCnt			dw 224						;根目录可容纳的目录项数
	BPB_TotalSec16			dw 2880						;总扇区数
	BPB_Media				db 0xf0						;介质类型
	BPB_FATSz16				dw 9						;每个FAT占用扇区数
	BPB_SecPerTrk			dw 18						;每个磁道扇区数
	BPB_NumHeads			dw 2						;磁头数
	BPB_HiddSec				dd 0						;隐藏扇区数
	BPB_TotSec32			dd 0
	BS_DrvNum				db 0						;中断13（读取磁盘扇区）的驱动器号
	BS_Reserved1			db 0
	BS_BootSig				db 0x29						;扩展引导标志
	BS_VolID				dd 0						;卷序列号
	BS_VolLab				db '           '			;卷标，必须是11个字符，不足以空格填充
	BS_FileSysType			db 'FAT12   '				;文件系统类型，必须是8个字符，不足填充空格


RootDirSizeForLoop:	dw 	RootDirSectors
SectorNo: 			dw 	0
Odd:				db  0
NoLoaderMessage:	db 	"No Kernel File"
LoaderFileName:		db 	"KERNEL  BIN", 0
LoaderFileFoundMessage:	db "Kernel File Found"
LoaderFileLoadMessage:	db "Kernel File Loaded"
LoaderStarting:		db "Loader Running"

OffsetOfKernelFileCount: dd 0x100000

%include "../include/print.asm"

[SECTION .s16]
[BITS 16]

Label_Start:

	mov 	ax, cs						;cs寄存器（代码段寄存器） -> ax寄存器 
	mov 	ds, ax						;ax寄存器 -> ds寄存器（数据段寄存器）
	mov		es, ax
	mov		ax,	0x00
	mov		ss,	ax
	mov		sp, 0x7c00

	push 	ax
	; A20引脚设为高电平，开启32位地址线
	in      al,     92h
	or      al,     00000010b
	out     92h,    al
	pop		ax

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

	mov 	ax, LoaderStarting
	mov 	bx, 14
	call 	Func_Print

	mov		word 	[SectorNo],		SectorNumOfRootDirStart
	jmp     Label_Search_In_Root_Dir_Begin


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
	

Label_Search_In_Root_Dir_Begin:

	;开始遍历根目录扇区
	cmp		word 	[RootDirSizeForLoop],		0
	jz		Label_No_LoaderBin
	dec 	word 	[RootDirSizeForLoop]
	mov		ax,		00h
	mov		es,		ax
	mov		bx,		8000h				;缓存区设为扩展栈底地址
	; 下面两行准备好调用读取一个扇区内容的参数
	mov		ax,		[SectorNo]
	mov		cl,		1
	call	Func_ReadOneSector
	mov		si,		LoaderFileName					;把指向loader程序文件名的地址存在si寄存器
	mov		di,		8000h				;把di寄存器重置为扩展栈段地址
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

	mov 	ax, NoLoaderMessage
	mov 	bx, 14
	call 	Func_Print
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

	mov 	ax, LoaderFileFoundMessage
	mov 	bx, 17
	call 	Func_Print

	mov		ax,		RootDirSectors
	and		di,		0ffe0h
	add		di,		01ah
	mov		cx,		word 		[es:di]
	push	cx
	add		cx,		ax
	add		cx,		SectorBalance
	mov		eax,	BaseTmpOfKernelAddr
	mov		es,		eax
	mov		bx,		OffsetTmpOfKernelFile
	mov		ax,		cx


Label_Go_On_Loading_File:

	mov		cl,		1
	call	Func_ReadOneSector
	pop		ax




    push    cx
    push    eax
    push    edi
    push    ds
    push    esi

    mov     cx,     200h	; 512个字节
    mov     ax,     BaseOfKernelFile
    mov     edi,    dword       [OffsetOfKernelFileCount]

    mov     ax,     BaseTmpOfKernelAddr
    mov     ds,     ax
    mov     esi,    OffsetTmpOfKernelFile

Label_Mov_Kernel:

    mov     al,     byte    [ds:esi]
    mov     byte    [fs:edi],   al

    inc     esi
    inc     edi

    loop    Label_Mov_Kernel

    mov     eax,    0x1000
    mov     ds,     eax

    mov     dword   [OffsetOfKernelFileCount],  edi

    pop     esi
    pop     ds
    pop     edi
    pop     eax
    pop     cx

	

	call 	Func_GetFATEntry
	cmp 	ax,		0fffh
 	jz 		Label_File_Loaded
 	push	ax
 	mov		dx, 	RootDirSectors
 	add		ax,		dx
 	add		ax,		SectorBalance
 	; add		bx,		[BPB_BytesPerSec]
 	jmp 	Label_Go_On_Loading_File


Label_File_Loaded:
	mov 	ax, LoaderFileLoadMessage
	mov 	bx, 18
	call 	Func_Print

	push	dx
	mov		dx,	03f2h
	mov		al,	0
	out		dx, al
	pop		dx

	mov		ax,		4f02h
	mov		bx,		4143h
	int		10h




%include "switchmode.asm"




