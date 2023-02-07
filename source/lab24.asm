.model tiny               ; ?????? ??????, ???????????? ??? COM
.code                     ; ?????? ???????? ????
org  100h

start:
mov ax,3d02h
mov dx,offset file1
int 21h
xchg ax,bx
mov ah,3Fh
mov cx,100h
mov dx,pointer
int 21h
add pointer,ax
mov ax,3d02h
mov dx,offset filename
int 21h
xchg ax,bx
push bx
mov ah,3Fh
mov cx,1000h
mov dx,pointer
int 21h
mov di,pointer
mov [di-2],ax
add pointer,ax
xchg ax,cx
mov si,dx
crypt:
xor byte ptr [si],0AAh
inc si
loop crypt
mov ax,3d02h
mov dx,offset file2
int 21h
xchg ax,bx
mov ah,3Fh
mov cx,100h
mov dx,pointer
int 21h
add pointer,ax
mov ax,4200h
pop bx
xor cx,cx
xor dx,dx
int 21h
mov ah,40h
mov dx,offset buffer
mov cx,pointer
sub cx,dx
int 21h
ret
filename db 'lab22.com',0
file1 db 'lab21.com',0
file2 db 'lab23.com',0
pointer dw offset buffer
buffer:

end start