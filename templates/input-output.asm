.model tiny
.code
org 100h
start:

    ; ввод строки с клавиатуры, может пригодится для выбора файла
    mov ah, 0ah ; 0ah - ввод строки в буфер https://prygunov.github.io/assembly/real/dos/int21/fa.htm
    mov dx, offset maxlen
    int 21h

    mov dl, 10
    mov ah, 02h ; 02h - написание символа в консоль, символ 10 - перевод на новую строку
    int 21h ; написание такого символа необходимо, так как после ввода строки каретка сама не сдвигается на новую строку

    mov al, len ; в len сейчас длина введенной строки
    cbw ; расширение регистра al до слова ax - https://prygunov.github.io/assembly/manuals/16.html
    mov si, ax
    mov msg+si, '$' ; помещение в конец $, так как по умолчанию там его нет
    ; символ $ в буфере говорит о конце строки для функции 9h

    ; вывод строки на экран
    mov ah, 09h ; https://prygunov.github.io/assembly/real/dos/int21/f9.htm
    mov dx, offset msg
    int 21h
    ret ; команда возврата

    ; определение строки
    maxlen db 20 ;max number of characters allowed (20).
    len db 0 ;number of characters entered by user.
    msg db 20 dup(?) ;characters entered by user.
end start