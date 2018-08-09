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


Label_Start:
	;初始化一些段寄存器
	mov ax, cs						;cs寄存器（代码段寄存器） -> ax寄存器 
	mov ds, ax						;ax寄存器 -> ds寄存器（数据段寄存器）
	mov es, ax 						;ax寄存器 -> es寄存器（附加段寄存器）
	mov ss, ax 						;ax寄存器 -> ss寄存器（堆栈段寄存器）
	mov sp, BaseOfStack 			;a起始地址 -> sp寄存器（堆栈指针寄存器）

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

;读取一个扇区，执行下面代码时需先把ax设为待读取的磁盘起始逻辑扇区号，把cl设为读取扇区数量
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
	jc		Label_Go_On_Reading				;jc是条件转移指令，当cf=1时跳转，13h中断返回时，如遇错误，则cf=1


	add		esp, 2							;恢复esp
	pop 	bp 								;恢复bp
	ret 									;ret指令，栈顶字单元出栈给ip寄存器（指令指针寄存器），调用前栈中压入了调用完应当执行的指令地址，因此这里可以返回继续执行

