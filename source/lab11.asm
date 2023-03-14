.model tiny
.code
org 100h

start:	;Точка входа в программу
    mov ah,40h	;В AH помещаем значение 40h https://prygunov.github.io/assembly/real/dos/int21/f40.htm
    mov bx,1	;В BX помещаем значение 1 (пишем на экран, а не в файл, описатель вывода)
    mov cx,text1len	;В CX заносим длину строки text1
    lea dx,text1	;В DX помещаем адрес строки text1
    int 21h	;Прерывание 21h, запись AH=40h на экран BX=1

    mov ah,3Fh	;В AH помещаем значение 3Fh
    xor bx,bx	;Обнуляем регистр BX = 0, (описатель клавиатуры)
    mov cx,15	;В CX заносим длину строки – 15
    lea dx, filename	;В DX помещаем адрес строки filename
    int 21h	;21h, чтение AH=40h с клавиатуры BX=0

    mov si,ax	;В SI копируем значение регистра AX
    sub si,2	;Вычитаем из SI 2
    mov filename[si],0	;В SI-й байт в строке filename пишем 0

    ; вывод на экран предложения ввести key
    mov ah,40h
    mov bx,1
    mov cx,text2len
    mov dx,offset text2
    int 21h

    ; ввод "key" = password
    mov ah,3Fh
    xor bx,bx; bx = 0, описатель клавиатуры
    mov cx,8
    mov dx,offset password
    int 21h

    mov cx,ax	;В CX копируем значение регистра AX
    dec cx	;Уменьшаем содержимое CX на 1
    dec cx	;Уменьшаем содержимое CX на 1
    lea si,password	;В SI помещаем адрес строки password
    xor al,al	;Обнуляем AL

; далее определяем значение шифрования - сумма символов ключа
next:	;Метка next
    add al,[si]	;Прибавляем к AL, содержимое ячейки по адресу SI
    inc si	;Увеличиваем SI на 1
    loop next	;Выполняем цикл с метки next CX раз

    mov key,al	;Копируем в переменную key значение AL

    ; чтение файла
    mov ah,4Eh	;В AH помещаем значение 4Eh
    lea dx,filename	;В регистр DX помещаем адрес filename
    int 21h	;21h, поиск первого файла AH=4Eh

    ; jnc = jump not c
    jnc file_ok	;В случа успеха переходим на метку file_ok

    ; если прыжка не произошло - ошибка, пишем об этом, завершаем программу
    mov ah,9	;В AH помещаем значение 09h
    lea dx,text3	;В регистр DX помещаем адрес text3
    int 21h	;Прерывание 21h, вывод на экран строки AH=9
    ret	;Возврат из программы – ее завершение

file_ok:	;Метка file_ok
    mov ax,3D02h	;В AX помещаем значение 3D02h - Открываем файл для записи
    lea dx,filename	;В регистр DX помещаем адрес filename
    int 21h	;21h, открытие файла AH=3Dh для чтение и записи AL=02h

    xchg bx,ax	;Помещаем в BX дескриптор файла из AX

    mov ah,3Fh	;В AH помещаем значение 3Fh
    mov cx,ds:[9Ah]	;В CX помещаем размер файла
    lea dx,buffer	;В DX помещаем адрес buffer
    int 21h	;21h, чтение из файла AH=3Fh

    mov cx,ds:[9Ah]	;В CX помещаем размер файла
    mov si,offset buffer	;В SI помещаем адрес buffer
    mov al,key 	;В AL помещаем значение переменной key
    call crypt	;Вызываем процедуру crypt

    mov ah,42h	;В AH помещаем значение 42h
    mov al,0	;В AL помещаем значение 00
    xor cx,cx	;Обнуляем регистр CX
    xor dx,dx	;Обнуляем регистр DX
    int 21h	;21h, перемещаем указатель AH=42h от начала AL=0

    mov ah,40h	;В AH помещаем значение 40h
    mov cx,ds:[9Ah]	;В CX помещаем размер файла
    lea dx,buffer	;В DX помещаем адрес буфера buffer
    int 21h	;21h, запись в файл AH=40h

    mov ah,3Eh	;В AH помещаем значение 3Eh
    int 21h	;21h, закрытие файла AH=3Eh
    ret	;Возврат из программы – ее завершение

crypt proc	;Начало процедуры crypt
    next1:	;Метка next1
        xor [si],al	;Сложение по модулю 2 ячейки по адресу SI и значения регистра AL
        inc si	;Увеличиваем SI на 1
        loop next1	;Выполняем цикл с метки next1 CX раз
    ret	;Возврат из процедуры
    crypt endp	;Конец процедуры


    text1 db 0Dh,0Ah,'file name:'	;Запрос имени файла
    text1len = $-text1	;Длина строки text1
    text2 db 0Dh,0Ah, 'key:'	;Запрос пароля
    text2len = $-text2	;Длина строки text2
    text3 db 'file not found',0Dh,0Ah,'$'	;Сообщение об ошибке

    filename db 15 dup(0)	;Буфер для вводимого имени файла
    password db 8 dup(0)	;Буфер для вводимого пароля
    key db 0	;Переменная для ключа шифрования
    buffer:	;Буфер для содержимого файла
end start	;Конец программы

