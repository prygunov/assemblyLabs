.model tiny
.code
org 100h
start:


    ;print dx
    lea dx, msg
    mov ah, 09h
    int 21h

    ; exit
    mov ah, 4ch
    int 21h

msg:
    db 'victim', 13, 10,'$'

end start