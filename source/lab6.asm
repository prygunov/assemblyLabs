.model tiny
.code
org 100h

start:
find_first:
mov ah,4Eh
lea dx,fmask
find_first_next:
int 21h
jc exit
open:
mov ax,3D02h
mov dx,9Eh
int 21h
jc exit
xchg ax,bx
mov ah,3Fh
mov cx,ds:[9Ah]
lea dx,file_body
int 21h

jc exit
lea si,file_body
mov al,priznak
cmp al,byte ptr[si+3]
jne find_next
mov ax,[si+1]
add ax,3
add si,ax
;Перешли на начало вируса
push si
mov di,offset sign
mov cx,10
sravn:
mov al,[si]
cmp al,[di]
jnz find_next
inc si
inc di
loop sravn
mov ax, 4200h ;Это вирус! Лечим его
xor cx, cx
xor dx, dx
int 21h
mov ah, 40h
mov dx,old_bytes_offset
pop si
add dx,si
mov cx, 4
int 21h
jc exit
mov dx, si
sub dx,offset file_body
xor cx, cx
mov ax, 4200h
int 21h
jc exit
mov ah, 40h
xor cx, cx

int 21h
jc exit
find_next:
mov ah, 3Eh
int 21h
mov ah, 4Fh
jmp find_first_next
exit:
Ret
fmask db '*.com', 0
;Область данных антивируса
priznak db 0ffh ;'7'
old_bytes_offset dw 8Ch
sign db 0E8h, 00h, 00h, 05Dh, 81h, 0EDh, 07h, 01h, 8Bh, 86h
file_body equ $
end start