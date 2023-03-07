.model small

.stack 100h

.data
msg db 0Dh, 0Ah, 'Hello world!', 13, 10,'$'

.code
start:
    mov ax, @data
    mov ds, ax

    lea dx, msg
    ;print dx
    mov ah, 09h
    int 21h

    ; exit
    mov ah, 4ch
    int 21h

end start