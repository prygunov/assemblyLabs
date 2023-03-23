.model tiny	;Крошечная модель памяти – COM программа
.code	;Определение единственного сегмента – кода
org 100h	;Смещение регистра IP от начала сегмента кода

start:
find_first:
	mov ah,4Eh 
	lea dx,fmask	; указание маски для поиска
find_first_next:
	int 21h 		; или вызывание 4Eh (поиск и открытие первого) или 4Fh (открытие след)
	jc exit
open:
	mov ax,3D02h 	;открыть описатель файла
	mov dx,9Eh		;указание на ASCIIZ имя файла в DTA по умолчанию 
	int 21h
	jc exit
	
	xchg ax,bx		;читать файл через описатель
	mov ah,3Fh
	mov cx, ds:[9Ah]		;размер берётся с DTA
	lea dx,file_body
	int 21h
	jc exit
	
	lea si,file_body
	mov al,priznak
	cmp al,byte ptr[si+3] ;есть ли 69 в начале
	
	jne find_next
	mov ax,[si+1] 	;читает адрес прыжка 
	add ax,6		;сравниваем сигнатуру с 4 байта
	add si,ax 		;Нашли начало тела вируса
	push si 		;записываем в стек значение начала 
	mov di,offset sign
	mov cx,10		;сигнатура длиной в 10 байт
	sravn: 			;сравнение сигнатуры и байтов по адресу прыжка
		mov al,[si]
		cmp al,[di]
		jnz find_next
		inc si
		inc di
	loop sravn
					;Если сигнатура совпала это вирус! Лечим его
	mov ax, 4200h 	;Указатель на начало файла
	xor cx, cx
	xor dx, dx
	int 21h
	
	mov ah, 40h				;Записываем в файл 
	mov dx,old_bytes_offset ;Байты области памяти по адресу dx
	pop si					;
	add dx,si				;Учитывам что файл записан в после программы
	mov cx, 4				;записываем 4 байта
	int 21h
	
	jc exit
	mov dx, si
	sub dx,offset file_body
	
	xor cx, cx
	mov ax, 4200h	;Указатель на начало файла
	int 21h
	
	jc exit
	mov ah, 40h
	xor cx, cx
	int 21h
	jc exit
find_next:
	mov ah, 3Eh		; Закрыть описатель файла
	int 21h
	mov ah, 4Fh
	jmp find_first_next

exit:
	Ret

    fmask db '*.com', 0 ;Область данных антивируса
    priznak db 69h
    old_bytes_offset dw 13Ah
    sign db 0BBh, 00h, 01h, 8Ah, 86h, 41h, 02h, 8Ah, 0A6h, 42h
    file_body equ $ 	;указываем константу с помощью equ

end start