                call    Start
;----------------------------------------------------------------------------
; Flush Keyboard buffer
;----------------------------------------------------------------------------
FlushBuff:	mov	ah,0bh
		int	21h
		cmp	al,0ffh
		jne	EndFlush
		mov	ah,10h
		int	16h
EndFlush:	ret

Light           db      0
DiscoLights:    inc     cs:b[Light]
                cmp     cs:b[Light],4
                je      ResetLight
                cmp     cs:b[Light],1
                je      NumOn
                cmp     cs:b[Light],2
                je      CapsOn
                mov     al,16
SetLight:       mov     es,0040h
                mov     es:[0017h],al
                ret
NumOn:          mov     al,32
                jmp     SetLight
CapsOn:         mov     al,64
                jmp     Setlight
ResetLight:     mov     cs:b[Light],0
                jmp     DiscoLights

Delay:          mov     cx,10
Delay1:         push    cx
                mov     cx,0ffffh
Delay2:         loop    Delay2
                pop     cx
                loop    Delay1
                ret

Start:
                call    DiscoLights
                call    FlushBuff
                call    Delay
                jmp     Start

                int     20h
