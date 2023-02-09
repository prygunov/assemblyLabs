.model tiny
.code
org 100h
start:
    mov ah, 0ah
    mov dx, offset maxlen
    int 21h

    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed

    mov al, len
    cbw ; extend al to ax
    mov si, ax
    mov msg+si, '$' ;нужно засунуть в конец

    mov ah, 09h
    mov dx, offset msg
    int 21h
    ret

    ;мега определение строки
    maxlen db 20 ;max number of characters allowed (20).
    len db 0 ;number of characters entered by user.
    msg db 20 dup(?) ;characters entered by user.
end start