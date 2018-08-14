;boot程序，FAT12文件系统驱动，载入loader.bin并执行

org 0x7c00												;指定程序起始地址

	jmp short Label_Start								;段内跳转到Label_start处执行
	nop													;伪指令，啥也不干，这里应该只是为了凑个数，因为FAT12启动扇区格式为前3个字节为跳转指令

	BS_OEMName 				db '        '				;生产商
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


Label_Start:
	times 510 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区
	dw 0xaa55						;dw表示定义字类型变量（define word），以0x55 和 0xaa结尾标识这个扇区是一个引导扇区

	times 1474560 - ($ - $$) db 0		;$表示本行地址，$$表示节起始地址，重复定义填满一个扇区