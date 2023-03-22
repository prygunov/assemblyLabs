.model tiny
.code
org 100h
start:

    lea dx, msg
    mov ah, 09h
    int 21h

    mov ah, 4ch
    int 21h

    msg db 0Dh, 0Ah, 'Hello world!', 13, 10,'$'

end start