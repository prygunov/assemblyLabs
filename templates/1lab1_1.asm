; программа с условиями

model small ; собирается как exe
.stack 100h
.data
Question db 'Kakoe seychas vremya sutok? (U/V)',13,10,'$'  ;это всё одна строчка, перенеслась на следующую строку!!
MesUtro db 13,10,'Dobroe utro!',13,10,'$'
MesVecher db 13,10,'Dobriy vecher!',13,10,'$'
Anyway db 13,10,'Vvedite simvol "U" ili "V"!',13,10,'$'

.code
start:
	mov ax,@data	;установка в ds адреса сегмента данных
	mov ds,ax
RepeatEnter:
	mov ah,09h	;функция DOS вывода сообщения на экран
	mov dx, offset Question
	int 21h
	xor ah,ah	;очистка регистра Ah
	mov ah,1	;функция DOS ввода символа с клавиатуры
	int 21h
	cmp al, 'U'
	jz UUtro	;если Al равно ‘U’ – переход на метку UUtro
	cmp al, 'V'
	jz VVecher	;если Al равно ‘V’ – переход на метку VVecher
	mov ah,09h	;функция DOS вывода сообщения на экран
	mov dx,offset Anyway
	int 21h
	jmp RepeatEnter   ;если Al не равно ни ‘U’ ни ‘V’, то переход на метку RepeatEnter
UUtro:
	mov dx,offset MesUtro		;запись смещения MesUtro в dx
	jmp ShowMes
VVecher:
	mov dx,offset MesVecher	;запись смещения MesVecher в dx
ShowMes:
	mov ah,09h	;функция DOS вывода сообщения на экран
	int 21h
	mov ax,4C00h	;функция DOS выхода из программы
	int 21h	;вызов DOS. Останов программы
end start	;метка завершения программы
