;boot程序，FAT12文件系统驱动，载入loader.bin并执行

org 0x7c00												;指定程序起始地址

BaseOfStack 		equ 0x7c00
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


;读取一个扇区
Func_ReadOneSector:
	
	push	bp 								;把基址指针寄存器bp的值压入堆栈存起来
	mov		bp, sp 							;栈指针寄存器sp -> bp
	sub		esp, 2							;esp是32位的sp，esp寄存器减2，即把栈顶指针地址减2
	mov		byte [bp - 2], cl 				;把cl寄存器的值copy到bp - 2内存地址处，上面bp的值实际上是栈指针寄存器地址，因此这里实际上是在堆栈顶端地址 - 2处，结合上面2步，其实就是把cl的值压入堆栈的花式玩法
	push	bx								;把bx寄存器压如栈中
	mov		bl, [BPB_SecPerTrk]				;每个磁道扇区数 -> bl寄存器
	div		bl 								;bl是八位，所以被除数16位ax寄存器，商在al中，余数在ah中。
											;在调用Func_ReadOneSector前，需要先把ax设为待读取的磁盘起始扇区号，因此扇区号除以每个磁道的扇区数得到磁道号存在al中，余数在ah中，计算磁头号会用到。
	inc		ah								;ah寄存器+1
	mov		cl,	ah 							;ah -> cl，cl存放读入扇区数量
	mov		dh,	al							;al -> dh, dh存放磁头号
	shr 	al, 1							;al右移1位，相当于除以2
	mov 	ch, al							;al -> ch，ch存放磁道号					
	and		dh, 1
	pop		bx
	mov		dl, [BS_DrvNum]

Label_Go_On_Reading:
	mov		ah, 2
	mov		al, byte [bp - 2]
	int		13h
	jc		Label_Go_On_Reading


	add		esp, 2
	pop 	bp
	ret

