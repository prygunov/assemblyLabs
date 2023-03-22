.386
.model use16 tiny
.code
org 100h

start:
    xor ax,ax
    push ax
    pop ds
    push ds
    mov si,84h
    push si
    lodsw
    push ax
    lodsw
    mov ds,ax
    pop si
    lea  di,sign
    mov cx,4
    repe cmpsb
    jnz find_MCB
    pop di
    pop es
    xor si,si
    jmp restore

find_MCB:
    pop di
    pop es
    push cs
    pop ds
    mov ah,52h  ;Находим превый MCB
    int 21h
    dec bx
    dec bx
    mov ax,es:[bx]
    push cs
    pop es
    mov dx,sign_off

find_next:
    mov ds,ax
    xor si,si
    lodsb
    dec si
    add si,dx
    lea di,sign
    mov cx,4
    repe cmpsb
    jz find
    cmp al,'Z'
    jz exit
    mov ax,ds
    add ax,ds:[3]
    inc ax
    jmp find_next

find:
    push cx
    pop es
    mov di,84h
    xor si,si
    mov ax,ds
    xchg bx,ax
    mov cl,4
    mov ax,cs:vir_off
    shr ax,cl
    add bx,ax
    mov ax,es:[di]
    shr ax,cl
    add ax,es:[di+2]
    cmp ax,bx
    jnz copy_jump

restore:
    add si,cs:vir_int_off
    movsw
    movsw
    jmp exit

copy_jump:
    add si,cs:vir_int_off
    push cs
    pop es
    mov di,offset int_off
    movsw
    movsw
    mov cx,5
    sub di,cx
    mov si,cs:vir_off
    xchg si,di
    push ds
    push es
    pop ds
    pop es
    rep movsb

exit:
    ret

    jump_int db 0EAh
    int_off dw 0
    int_seg dw 0
    sign_off dw 87h
    sign db 3dh,0ffh,0ffh,75h
    vir_off dw 97h
    vir_int_off dw 83h


end start
