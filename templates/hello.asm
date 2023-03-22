.model small

.stack 100h

.data
msg db  'Cut apples!', 13,'$' ; через запятую перечисляются данные помещаемые в msg
eat db  'Eat', 0Ah,'$'
; 0Dh = 13 = символ возврата каретки в начало
; 0Ah = 10 = символ перевода на новую строку
; все символы - из ASCII
.code
start:
    mov ax, @data ; помещаем в регистр AX смещение для данных
    mov ds, ax ; сразу в ds записать не можем, особенность ассемблера

    ; MOV помещает в регистр значение
    lea dx, msg ; LEA помещает адрес
    ;print dx
    mov ah, 09h ; функция вывода строки до символа "$" https://prygunov.github.io/assembly/real/dos/int21/f9.htm
    int 21h

    lea dx, eat ; вывод второго сообщения, итого в консоли будет "Eat apples!", все из-за 13 символа в первой строке
    int 21h


    ; выход из программы
    mov ah, 4ch ; функция завершения программы
    int 21h

end start