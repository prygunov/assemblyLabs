         .model tiny               ; Модель памяти, используемая для COM
         .code                     ; Начало сегмента кода
         org  100h                 ; Начальное значение счетчика - 100h
start:   mov  ah, 9                ; Номер функции DOS - в AH
         mov  dx, offset message   ; Адрес строки - в DX
         int  21h                  ; Вызов системной функции DOS
         mov  ax,4C00h
         int  21h                  ; Завершение программы
message  db    "Hello World!", 0Dh, 0Ah, '$' ; Строка для вывода
         end  start                ; Конец программы