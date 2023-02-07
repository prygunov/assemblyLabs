.model small
.stack 100h
.data
qst db 13, 10, 'I am alive! What the season is it now?', 13, 10, '[1] - Spring', 13, 10, '[2] - Summer', 13, 10, '[3] - Autumn', 13, 10, '[4] - Winter', 13, 10, '>> ', '$'
ans3 db '3'
ans4 db '4'
ans1 db '1'
ans2 db '2'
winterMsg db 13, 10, 'That is too hot for winter!', 13, 10,'$'
summerMsg db 13, 10, 'That is too cold for summer!', 13, 10,'$'
springMsg db 13, 10, 'Yap! That is what I need.', 13, 10,'$'
autumnMsg db 13, 10, 'Yak! I hate this time of year.', 13, 10,'$'
uexp db 13, 10, 'Unexcepted input', 13, 10, '$'

.code
start:
mov ax, @data
mov ds, ax

repeat:
    ; print question
    mov dx, offset qst
    mov ah, 09h
    int 21h

    ; input / writing answer to al
    mov ah, 1
    int 21h

    ; compare al with everything
    cmp al, ans1 ; if true z = 1
    jz spring ; jump if z == 1
    cmp al, ans2
    jz summer
    cmp al, ans3
    jz autumn
    cmp al, ans4
    jz winter
    ; if we come here, we got unexpected input
    mov dx, offset uexp
    mov ah, 09h
    int 21h
    jmp repeat

winter:
    mov dx, offset winterMsg
    jmp exit

summer:
    mov dx, offset summerMsg
    jmp exit

spring:
    mov dx, offset springMsg
    jmp exit

autumn:
    mov dx, offset autumnMsg

exit:
    ;print dx
    mov ah, 09h
    int 21h

    ; exit
    mov ah, 4ch
    int 21h

end start