.186
.model tiny
.code
org 100h

start:
    mov ah,0E8h
    int 2Fh
    cmp al,0FFh
    jz uninst
    cmp byte ptr cs:[80h],0
    jz usage
    xor cx,cx
    mov cl,cs:[80h]
    mov  di,81h

tobig:
    cmp byte ptr[di],61h
    jbe big
    and byte ptr[di],0DFh

big:
    inc di
    loop tobig
    mov ax,352Fh
    int 21h

    mov word ptr cs:old_2Fh,bx
    mov word ptr cs:old_2Fh+2,es
    mov ax,3521h
    int 21h

    mov word ptr cs:old_21h,bx
    mov word ptr cs:old_21h+2,es
    mov ax,252Fh
    mov dx,offset cs:new_2Fh
    push cs
    pop ds
    int 21h

    mov ax,2521h
    mov dx,offset cs:new_21h
    push cs
    pop ds
    int 21h

    mov ah,09h
    mov dx,offset insmsg
    int 21h
    mov dx,1000h
    int 27h

uninst:
    mov ah,09h
    mov dx,offset remmsg
    int 21h
    jmp exit

usage:
    mov ah,09h
    mov dx,offset usemsg
    int 21h

exit:
    ret

new_2Fh:
    cmp ah,0E8h
    jne o2Fh
    push ds
    push es
    pusha
    mov ax,2521h
    lds dx,cs:old_21h
    int 21h

    mov ax,252Fh
    lds dx,cs:old_2Fh
    int 21h

    mov es,word ptr cs:2Ch
    mov ah,49h
    int 21h

    push cs
    pop es
    mov ah,49h
    int 21h

    popa
    pop es
    pop ds
    mov al,0FFh
    iret

o2Fh:
    jmp cs:old_2Fh

new_21h:
    cmp ah,39h
    jz n21h
    cmp ah,3Ah
    jz n21h
    cmp ah,3Bh
    jz n21h
    cmp ah,3Ch
    jz n21h
    cmp ah,3Dh
    jz n21h
    cmp ah,41h
    jz n21h
    cmp ah,43h
    jz n21h
    cmp ah,4Bh
    jz n21h
    cmp ah,4Eh
    jz n21h

o21h:
    jmp cs:old_21h

n21h:
    cld
    pusha
    push es
    push ds
    push cs
    pop es
    mov di,offset curpath
    mov si,dx
    cmp byte ptr ds:[si+1],':'
    jz fullpath
    mov ah,19h
    int 21h
    mov dl,al
    inc dl
    add al,'A'
    mov ah,':'
    stosw
    mov ah,47h
    push ds
    push cs
    pop ds
    xchg si,di
    int 21h
    pop ds
    xchg si,di
    mov di,offset curpath
    xor ax,ax
    mov cx,67
    repne scasb
    dec di
    cmp byte ptr ds:[di],'\'
    jz fullpath
    mov al,'\'
    stosb

fullpath:
    lodsb
    stosb
    or al,al
    jz eep
    jmp fullpath

eep:
    push cs
    pop ds
    mov si,offset curpath
    mov di,82h
    xor cx,cx
    mov cl,cs:[80h]
    dec cx
    repe cmpsb
    pop ds
    pop es
    popa
    jne o21h
    mov ax,3
    push bp
    mov bp,sp
    or word ptr ss:[bp+6],1
    pop bp
iret

    old_2Fh dd 0
    old_21h dd 0
    usemsg db 'Usage: dirlock.com <directory_full_path>','$'
    insmsg db 'Installed','$'
    remmsg db 'Removed','$'
    curpath db 67 dup(0)

end start
