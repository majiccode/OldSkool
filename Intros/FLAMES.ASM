.286
JUMPS
ASSUME CS:_Code,DS:_DATA,SS:_Stack
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EXTRN _X_set_mode: FAR
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_Stack Segment Para Stack 'Stack'
    db 2048 dup (?)
_Stack EndS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_Data  Segment Para Public 'Data'
       flames       db 32*64 dup (0)
       new_flames   db 32*64 dup (0)
       x            dw 0
       y            dw 0


_Data  EndS

_Code  Segment Para Public 'Code'

SetBorder Macro color
       mov  dx,03dah            ; Used for speed test
       in   al,dx
       nop
       nop
       nop
       mov  dx,03c0h
       mov  al,11h+32
       out  dx,al
       mov  al,color
       out  dx,al
       EndM

Intro  Proc   Far
       push ds
       xor  ax,ax
       push ax
       ASSUME ds:_DATA
       mov  ax,_DATA
       mov  ds,ax

       mov  ax,0013h
       int  10h

       mov  dx,03c8h		; Set up palette,  black -> red
       xor  al,al
       out  dx,al
       inc  dx
       mov  cx,8
@set_red:
       mov  al,16		; Some stupid comments
       sub  al,cl
       shl  al,3		; Multiply al with 4
       out  dx,al		
       xor  al,al		; Xor al with al
       out  dx,al
       out  dx,al
       loop @set_red		; Loop this 16 times  (nah...no more stupid comments)

       mov  cx,16		; Set red -> yellow 
@set_yellow:
       mov  al,60
       out  dx,al
       mov  al,16
       sub  al,cl
       shl  al,2
       out  dx,al
       xor  al,al
       out  dx,al
       loop @set_yellow

       mov  cx,16		; set yellow -> white
@set_white:
       mov  al,60
       out  dx,al
       out  dx,al
       mov  al,16
       sub  al,cl
       shl  al,2
       out  dx,al
       loop @set_white

       mov  cx,208		; Set remaing colors to white
       mov  al,63
@whithey:
       out  dx,al
       out  dx,al
       out  dx,al
       loop @whithey

@WaitESC:

       SetBorder 200			; Delete the speed test when used in a proggie

       push ds
       pop  es
       cld

       lea  di,flames
       mov  si,di
       add  di,64
       add  si,96
       mov  cx,61*16
       rep  movsw			; Scroll the array 1 step up

       inc  di
       add  di,5
       mov  cx,4
@put_hot_spots:
       push di
       push cx
       push di
       mov  ax,20			; Get a random x value for hotspot
       call random
       pop  di
       add  di,ax
       push di
       mov  ax,190
       call random
       pop  di
       pop  cx
       mov  ah,al
       mov  [di],ax			; Set the hotspot
       pop  di
       loop @put_hot_spots		; Set 4 new hotspots

       mov  word ptr x,1
       mov  word ptr y,1
@scanning_flames:			; Loop for calculate the new flame array
       mov  di,y			; Interpolate the 8 pixels around the location we wanna calculte a new value for
       shl  di,5
       add  di,x
       xor  ax,ax
       xor  bx,bx
       mov  bl,flames[di-33]
       mov  al,flames[di-32]
       add  bx,ax
       mov  al,flames[di-31]
       add  bx,ax
       mov  al,flames[di-1]
       add  bx,ax
       mov  al,flames[di+1]
       add  bx,ax
       mov  al,flames[di+31]
       add  bx,ax
       mov  al,flames[di+33]
       add  bx,ax
       mov  al,flames[di+33]
       add  bx,ax
       shr  bx,3
       mov  new_flames[di],bl		; Save this in the new array
       inc  x
       cmp  word ptr x,32
       jb   @scanning_flames
       mov  word ptr x,1
       inc  y
       cmp  word ptr y,64
       jb   @scanning_flames		; Do it for the whole "map"

       lea  di,flames
       lea  si,new_flames
       mov  cx,64*16
       rep  movsw			; Move new "map" to old "map" array

       mov  ax,0a000h
       mov  es,ax
       lea  si,flames
       mov  di,320*100+100
       mov  bx,60
@plot_it:
       mov  cx,16
       rep  movsw
       add  di,320-32
       dec  bx
       jnz  @plot_it			; Plot the flames

       SetBorder 0			; Delete this speed test


       mov  dx,03dah
@bettan:
       in   al,dx
       test al,8
       je   @bettan
@bettan2:
       in   al,dx
       test al,8
       jne  @bettan2			; Wait for vertical retrace


       in   al,60h
       cmp  al,1
       jne  @WaitESC			; Wait until the user have pressed ESC

       mov  ax,0003h			; Text mode and Leave the program.
       int  10h
       mov  ax,4c00h
       int  21h
Intro  EndP

;--------------------------------------------------------------------------------
; The above program is made by Errand and is released to the public domain.
; Thanks to Jare of Iguana for the information of the "simple" formula for
; flames.
;
; If you find this file interesting then PLEASE send me a postcard 8)
;
; Daniel Sjoberg
; Mogatan 11
; S-566 34 HABO
; SWEDEN
; 
; Phone: (+46) 36 - 46309 CET  (Dont call me at nights 8) )
;
; Greetings goes to:  	Jare (Iguana), Leinad (*Avalanche*), Zax (*Avalanche*), 
;			wReam (CB!), ZigZag (CB!), Patch (*Avalanche*)
;			and the rest nice IRC-folks I know...
;
;
;--------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Author:  Unknown.  The author is the author of the HYPERCUBE Tumble program.
;-------------------------------------------------------------------------------
RandSeed        dd       0

Randomize       Proc
                mov      ah,2Ch
                int      21h
                mov      Word ptr cs:[RandSeed],cx
                mov      Word ptr cs:[RandSeed+2],dx
                ret
Randomize       endP

;-------------------------------------------------------------------------------
; In:  AX - Range
; Out: AX - Value within 0 through AX-1
; Destroys: All ?X and ?I registers
Random          proc
                mov      cx,ax          ; save limit
                mov      ax,Word ptr cs:[RandSeed+2]
                mov      bx,Word ptr cs:[RandSeed]
                mov      si,ax
                mov      di,bx
                mov      dl,ah
                mov      ah,al
                mov      al,bh
                mov      bh,bl
                xor      bl,bl
                rcr      dl,1
                rcr      ax,1
                rcr      bx,1
                add      bx,di
                adc      ax,si
                add      bx,62e9h
                adc      ax,3619h
                mov      word ptr cs:[RandSeed],bx
                mov      word ptr cs:[RandSeed+2],ax
                xor      dx,dx
                div      cx
                mov      ax,dx                  ; return modulus
                ret
Random          EndP

_Code  EndS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

END Intro