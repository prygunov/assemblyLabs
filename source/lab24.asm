;программа уже с выбором программы для зашифровки

.model tiny
.code
org  100h

start:

    mov ah, 09h
    mov dx, offset input_msg
    int 21h

    mov ah, 0ah
    mov dx, offset maxlen
    int 21h

    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed

    mov al, len
    cbw ; extend al to ax
    mov si, ax
    mov filename+si, '$' ;нужно засунуть в конец

    mov ah, 09h
    mov dx, offset file_msg
    int 21h

    mov dx, offset filename
    int 21h

    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed

    mov ax,3d02h
    mov dx,offset file1
    int 21h
    xchg ax,bx;

    mov ah,3Fh
    mov cx,100h
    mov dx,pointer
    int 21h

    add pointer,ax
    mov ax,3d02h
    mov dx,offset filename
    int 21h
    jc error

    xchg ax,bx
    push bx

    mov ah,3Fh
    mov cx,1000h
    mov dx,pointer
    int 21h

    mov di,pointer
    mov [di-2],ax
    add pointer,ax

    xchg ax,cx
    mov si,dx
crypt:
    xor byte ptr [si],55h
    inc si
    loop crypt


    mov ax,3d02h
    mov dx,offset file2
    int 21h

    xchg ax,bx
    mov ah,3Fh
    mov cx,100h
    mov dx,pointer
    int 21h

    add pointer,ax
    mov ax,4200h
    pop bx
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,40h
    mov dx,offset buffer
    mov cx,pointer
    sub cx,dx
    int 21h

    mov ah, 09h
    mov dx, offset success_msg
    int 21h

    jmp end

error:
    mov ah, 09h
    mov dx, offset err_msg
    int 21h
    jmp end

end:

    ret

    maxlen db 20 ;max number of characters allowed (20).
    len db 0 ;number of characters entered by user.
    filename db 20 dup(?) ;characters entered by user.
    success_msg db 'Success!','$'
    err_msg db 'Error, can not find or open such file.','$'
    input_msg db 'Hello, input filename to crypt:','$'
    file_msg db 'File to crypt specified:','$'
    file1 db 'lab21.com',0
    file2 db 'lab23.com',0
    pointer dw offset buffer
buffer:

end start