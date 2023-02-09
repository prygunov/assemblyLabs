.model tiny

.code
start:
    msg db 0Dh, 0Ah, 'Hello world!', 13, 10,'$'

    lea dx, msg
    ;print dx
    mov ah, 09h
    int 21h

    ; exit
    mov ah, 4ch
    int 21h

end start