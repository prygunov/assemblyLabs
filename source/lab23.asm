.model tiny
.code
org 100h

start:
    call _next

_next:
    pop cx ?
    pop si
    mov di,offset start
    push di
    sub cx,si
    rep movsb
    ret

end start