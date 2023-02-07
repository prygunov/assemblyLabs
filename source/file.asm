.model tiny
.code
org 100h
start:

mov dx, offset file; адрес строки с именем файла
mov al,0; режим открытия - для чтения
mov ah,3dh; .....
int 21h
jc terminate
mov bx,ax

mov cx, 99
mov dx, offset buf
mov ah, 3fh
int 21h
JZ terminate


MOV SI, offset buf
print:
mov al, [SI]
mov ah,0eh
int 10h
INC SI
CMP BYTE PTR [SI], 0  ;CMP [SI], 0
JNE print

terminate:

mov ax, 4C00h
int 21h

file db "text",0 ;****PLACE THE FILE IN C:\EMU8086\vdrive\C***
buf db 99 dup(0)
counter db 0

end start