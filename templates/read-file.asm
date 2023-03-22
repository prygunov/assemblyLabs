.model tiny
.code
org 100h
start:

    mov dx, offset file; адрес строки с именем файла
    mov al,0; режим открытия - для чтения
    mov ah,3dh; функция "Открыть файл" https://prygunov.github.io/assembly/real/dos/int21/f3d.htm
    int 21h; функция устанавливает в флаг CF=1 если произошла ошибка, в ax уйдет ее код, если все хорошо CF=0
    jc terminate; если произошла ошибка - прыгаем на метку terminate
    mov bx,ax

    mov ah, 3fh; функция чтения файла,
    mov cx, 99; число читаемых байт
    mov dx, offset buf; буфер, куда будем записывать
    int 21h
    jс terminate; в случае ошибки


    MOV SI, offset buf
print:
    mov al, [SI]
    mov ah,0eh
    int 10h; использование прерывания не от DOS, а от BIOS https://prygunov.github.io/assembly/real/ints/int10.htm
    INC SI
    CMP BYTE PTR [SI], 0  ;CMP [SI], 0
    JNE print; печатаем посимвольно

terminate:

    mov ax, 4Ch ; завершение программы
    int 21h

    ; к слову - если до этого момента не будет завершения программы, код дальше будет исполнятся непредсказуемо
    file db "text",0 ;
    buf db 99 dup(0)
    counter db 0

end start