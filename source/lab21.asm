.model tiny               ; Модель памяти, используемая для COM
.code                     ; Начало сегмента кода
org 100h
start: ;
mov si,offset _end ;в SI смещение метки _end, ее адрес
lodsw ;в AX слово по адресу DS:SI,
SI=SI+2
xchg ax,cx ;помещаем в CX значение AX
push si ;сохраняем в стек значение SI
decrypt: ;метка decrypt
xor byte ptr[si],0AAh ;сложение по модулю 2
inc si ;увеличиваем SI на 1
loop decrypt ;цикл с метки decrypt CX раз
jmp si ;прыгаем по адресу SI, в lab23
_end: ;метка _end
filesize dw 0 ;размер шифруемого файла

end start