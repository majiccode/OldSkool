;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Uncrunch Screen Data
;
; Call:  DS:SI  Crunched image source pointer.
;        ES:DI  Display address pointer.
;        CX     Length of crunched image source data.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Uncrunch        PROC    NEAR
                push    si                      ;Save registers.
                push    di
                push    ax
                push    bx
                push    cx
                push    dx
                jcxz    DoneUnc

                mov     dx,di                   ;Save X coordinate for later.
                xor     ax,ax                   ;Set Current attributes.
                cld

LoopA:          lodsb                           ;Get next character.
                cmp     al,32                   ;If a control character, jump.
                jc      ForeGround
                stosw                           ;Save letter on screen.
Next:           loop    LoopA
                jmp     DoneUnc


ForeGround:     cmp     al,16                   ;If less than 16, then change the
                jnc     BackGround              ;foreground color.  Otherwise jump.
                and     ah,0f0h                 ;Strip off old foreground.
                or      ah,al
                jmp     Next

BackGround:     cmp     al,24                   ;If less than 24, then change the
                jz      NextLine                ;background color.  If exactly 24,
                jnc     FlashBitToggle          ;then jump down to next line.
                sub     al,16                   ;Otherwise jump to multiple output
                add     al,al                   ;routines.
                add     al,al
                add     al,al
                add     al,al
                and     ah,8fh                  ;Strip off old background.
                or      ah,al
                jmp     Next

NextLine:       add     dx,160                  ;If equal to 24,
                mov     di,dx                   ;then jump down to
                jmp     Next                    ;the next line.

FlashBitToggle: cmp     al,27                   ;Does user want to toggle the blink
                jc      MultiOutput             ;attribute?
                jnz     Next
                xor     ah,128                  ;Done.
                jmp     Next

MultiOutput:    cmp     al,25                   ;Set Z flag if multi-space output.
                mov     bx,cx                   ;Save main counter.
                lodsb                           ;Get count of number of times
                mov     cl,al                   ;to display character.
                mov     al,32
                jz      StartOutput             ;Jump here if displaying spaces.
                lodsb                           ;Otherwise get character to use.
                dec     bx                      ;Adjust main counter.

StartOutput:    xor     ch,ch
                inc     cx
                rep     stosw
                mov     cx,bx
                dec     cx                      ;Adjust main counter.
                loopnz  LoopA                   ;Loop if anything else to do...

DoneUnc:        pop     dx                      ;Restore registers.
                pop     cx
                pop     bx
                pop     ax
                pop     di
                pop     si
                ret
Uncrunch        ENDP
