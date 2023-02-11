.model tiny
.code
org 100h
start:
    msg db 0Dh, 0Ah, 'Hello world!', 13, 10,'$'

    ;lea dx, msg
    mov dx, offset msg
    ;print dx
    mov ah, 09h
    int 21h

    ; exit
    mov ah, 4Ch
    int 21h

end start