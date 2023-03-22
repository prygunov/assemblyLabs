.model tiny               ; Модель памяти, используемая для COM
.code                     ; Начало сегмента кода
org  100h                 ; Начальное значение счетчика - 100h
start:
    mov ah,9
    mov dx,offset text
    int 21h
    ret
    text db 'Hello',0dh,0ah,'$'
_end:              ; Конец программы
end start