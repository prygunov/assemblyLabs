; программа для вывода на экран

model small ; собирается как exe
.stack 100h
.data
	message db "Hello SamGTU!",'$'
.code
begin:	; метка начала программы
	mov ax,@data	;установка в ds адреса сегмента данных
	mov ds,ax

	mov ah,09h	; функция DOS вывода сообщения
	mov dx,offset message	     ; запись смещения message в dx
	int 21h	;функция DOS вывода сообщения на экран
	mov ax,4c00h	; функция DOS выхода из программы
	int 21h	; Вызов DOS. Останов программы.
end begin	; метка завершения программы