; 测试下org指令

; org 20h

mov ax,cs
mov bx,Label_Test

Label_Test:
mov cx,1

; 编译后实际指令

; 00000020  8CC8              mov ax,cs
; 00000022  BB2500            mov bx,0x25
; 00000025  B90100            mov cx,0x1