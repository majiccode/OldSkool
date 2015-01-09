
PDATA           SEGMENT USE16 PARA PUBLIC 'PDATA'

include         driver.inc               ; driver include file
MusicOffset     equ $-PDATA              ; Offset for the music
include         song.inc                 ; the music!

PDATA           ENDS


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Player          dd      0
MusicDriver     PROC    NEAR
MusicPatch      label
                nop
                call    dword ptr cs:[Player]
                ret
MusicDriver     ENDP
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OldInt1c        dd      0
NewInt1c        PROC    NEAR
                push    ax
                push    si
                mov     ah, 3                   ; Update music
                call    MusicDriver
                pop     si
                pop     ax
                pushf
                call    dword ptr [oldint1c]
                iret
NewInt1c        ENDP
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PlayMusic       PROC    NEAR
                push    ds
                push    si
                mov     ax,PDATA
                mov     ds,ax
                mov     cs:[Player+2],ax
                mov     ah,6
                call    MusicDriver

                jnc     @@InitializedOk        ; card was there, it's ok

                mov     byte ptr cs:[MusicPatch],0C3h

@@InitializedOk:
                mov     ah,0                  ; funciton 0, init music
                mov     bx,PDATA              ; segment of MUSIC
                mov     cx,MusicOffset        ; offset of MUSIC
                call    MusicDriver

                mov     ah, 2                 ; Not sure what this one does, but it's required
                mov     bx, 0
                call    MusicDriver

                mov     ax,PDATA
                mov     ds,ax
                mov     bx,MusicOffset
                cmp     word ptr [bx],0434ah  ; "JC"
                jne     _old_vers
                mov     bx,MusicOffset+8
                jmp     _init_loc1

_old_vers:      mov     bx,MusicOffset+1

_init_loc1:     mov     al,byte ptr [bx]
                xor     ah, ah
                pop     ds

                mov     bx,ax                  ; Figure out 1193180/cycles to get
                mov     ax,34DCh               ; proper divisor for timer
                mov     dx,12h
                div     bx

                mov     al,00110110b           ; Set timer interrupt 0 to the
                out     43h,al                 ; divisor
                out     40h,al
                mov     al,ah
                out     40h,al

                mov     ax,351ch
                int     21h
                mov     word ptr cs:[oldint1c],bx
                mov     word ptr cs:[oldint1c+2],es

                mov     ax,seg newint1c
                mov     ds,ax
                mov     dx,offset newint1c
                mov     ax,251ch
                int     21h
                pop     si
                pop     ds
                ret
PlayMusic       ENDP
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StopMusic       PROC    NEAR
                push    ds
                mov     ax,word ptr cs:[oldint1c+2]
                mov     ds,ax
                mov     dx,word ptr cs:[oldint1c]
                mov     ax,251ch
                int     21h

                mov     ah, 2
                mov     bx, 0
                call    MusicDriver

                mov     al, 00110110b
                out     43h, al
                mov     ax, 65535
                out     40h, al
                mov     al, ah
                out     40h, al
                pop     ds
                ret
StopMusic       ENDP
