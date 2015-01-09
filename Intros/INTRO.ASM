;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Starfield intro by TRIPWIRE
;
; Assemble using TASM 2.x or above!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		.MODEL  large

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Data for MAINSEG
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAINSEGD        SEGMENT PARA PUBLIC 'DATA'
		.8086
		ORG     0000h   

TextBuffer      dw      0B800h                  ; Text video buffer address
GFXBuffer       dw      0A000h                  ; Graphics video buffer address

; *** Startfield varibles ***
include         SINCOS.INC                      ; Include sin and cos tables
XOrigin         dw      160                     ; X origin on screen
YOrigin         dw      100                     ; Y origin on screen
PreAddX         dw      0
PreAddY         dw      0
PreAddZ         dw      0

MaxZ            dw      480                     ; Leave this alone
NumStars        dw      700                     ; Number of stars on screen
StarPos         dw      700 dup(0,0,0,0)        ; Buffer for stars
StarPos2        dw      700 dup(0,0)            ; X,Y,Z,StarPos
StarPos2Pointer dw      0

; *** Font Varibles ***
BackdropSeg     dw      0
ScrollPointer   dw      0
ScrollSpeed     dw      0
SmoothMode      db      0
FontClip        dw      0
FontOffset      dw      0
CurrentWidth    dw      0
CharSetWidth    dw      15,30,31,31,31,31,31,31,31,11,31,31,31,31,31,31,31,31,31
		dw      31,31,31,31,31,31,31,31,11,11,11,27,16,16,29,11,11,11
		dw      32,29,15,29,29,29,29,29,29,29,29,29             
FontHeight      dw      24
FontPosY        dw      320*130 ;130
CharSet         db      ' abcdefghijklmnopqrstuvwxyz.!,*()-:`"?0123456789',0
CharSet2        db      ' abcdefghijklmnopqrstuvwxyz.!?',0
CharSetOffset   dw      320*170+180
		dw      320*0+0,320*0+32,320*0+(32*2),320*0+(32*3) 
		dw      320*0+(32*4),320*0+(32*5),320*0+(32*6),320*0+(32*7) 
		dw      320*0+(32*8),320*0+(32*8)+12 ;A-J
		dw      320*26+(32*0),320*26+(32*1),320*26+(32*2),320*26+(32*3) 
		dw      320*26+(32*4),320*26+(32*5),320*26+(32*6),320*26+(32*7) 
		dw      320*26+(32*8)
		dw      320*52+(32*0),320*52+(32*1),320*52+(32*2),320*52+(32*3)
		dw      320*52+(32*4),320*52+(32*5),320*52+(32*6) ; Z
		dw      320*78+(12*0),320*78+(12*1),320*78+(12*2)
		dw      320*78+(12*3),320*78+(12*3)+27,320*78+(12*3)+28+16 ;)
		dw      320*78+(12*3)+28+17+17,320*78+(12*3)+28+17+17+30
		dw      320*78+(12*3)+28+17+17+30+12
		dw      320*78+(12*3)+28+17+17+30+12+12
		dw      320*78+(12*3)+28+17+17+30+12+12+13 ; 0
		dw      320*104+(29*0),320*104+(29*1),320*104+(29*1)+16
		dw      320*104+17+(29*2),320*104+18+(29*3),320*104+19+(29*4)           
		dw      320*104+20+(29*5),320*104+21+(29*6),320*104+22+(29*7)           
		dw      320*104+23+(29*8)
FontSeg         dw      0
LogoSeg         dw      0
Coder           db      '                             ÄÍ CODE BY TRIPWIRE ÍÄ                                $'
BlankOut        db      '     $'               

; *** Sinus Data ***
include         SINUS1.INC

; *** Palette Data ***
include         PALETTE.INC

; *** Error Messages ***
Error2          db      'This intro requires a VGA card!$'
Error3          db      'DOS version is too low!$'
Error4          db      'Memory Allocation Error!$'

; *** Compressed font data ***
include         FONTA.INC
include         LOGO1.INC
include         ENDMSG.INC
; *** Scrolling Message ***
include         TEXT.INC

; *** Buffer for scrolling image ***
ScrollImage     db      320*30 dup(0)

Msg             db      'ABCDEFG',255
MAINSEGD        ENDS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Mod Player Segment
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PLAYERSEG       SEGMENT PARA PUBLIC 'DATA'
                .8086
                ORG     0000h   
;include         PLAYER.DAT
PLAYERSEG       ENDS

PDATA           SEGMENT USE16 PARA PUBLIC 'PDATA'

include         driver.inc               ; driver include file
MusicOffset     equ $-PDATA              ; Offset for the music
include         song.inc                 ; the music!

PDATA           ENDS

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Main code segment
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAINSEG         SEGMENT PARA PUBLIC 'CODE'
		ASSUME  CS:MAINSEG, DS:MAINSEGD, SS:STACKSEG
		.386                            ; Enable 386 instructions
Start:          call    Main                    ; Start of program 

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MOD Player calls 
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;include         PLAY.INC
include         THEDRAW.INC

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Player          dd      0
MusicDriver     PROC    NEAR
MusicPatch      label   byte
                nop
                call    dword ptr cs:[Player]
                ret
MusicDriver     ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlayMusic       PROC    NEAR
                push    ds
                push    si
                mov     ax,PDATA
                mov     ds,ax
                mov     word ptr cs:[Player+2],ax
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
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Check for a 386 processor or above.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_386Error       db      'Sorry, you need at least a 386 to run this program!',13,10,'$'
Check386        PROC    NEAR
		push    ds                      ;
		mov     ax,cs                   ;
		mov     ds,ax                   ;
		pushf                           ; Check for a 386 or above
		pop     ax                      ;
		or      ah,40h                  ;
		push    ax                      ;
		popf                            ;
		pushf                           ;
		pop     ax                      ;
		and     ah,40h                  ;
		jnz     Got386Plus              ;
		lea     dx,_386Error            ;
		mov     ah,9                    ;
		int     21h                     ;
		mov     ah,4ch                  ;
		int     21h                     ;
Got386Plus:     pop     ds
		ret
Check386        ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Check hardware
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CheckHardware   PROC    NEAR
		xor     ax,ax                   ; Check for a VGA card
		mov     ah,1ah                  ;
		int     10h                     ;
		cmp     al,1ah                  ;
		je      FoundVGA                ;
		lea     dx,Error2               ;
		mov     ah,9                    ;
		int     21h                     ;
		mov     ah,4ch                  ;
		int     21h                     ;
FoundVGA:       mov     ah,33h                  ; Check DOS version is ok
		mov     al,6                    ;
		int     21h                     ;
		cmp     bl,3                    ;
		jnb     DOSOk                   ;
		lea     dx,Error3               ;
		mov     ah,9                    ;
		int     21h                     ;
		mov     ah,4ch                  ;
		int     21h                     ;
DOSOk:          ret                             ;
CheckHardware   ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Allocate Memory, Return segment address in AX.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AllocMem        PROC    NEAR
		mov     bx,1000h                ; Allocate memory
		mov     ah,48h                  ;
		int     21h                     ;
		jc      AllocError              ; Did error occur?
		ret                             ; No, so return!
AllocError:     mov     ax,3                    ; Clear screen
		int     10h                     ;
		lea     dx,Error4               ; Display error message
		mov     ah,9                    ;
		int     21h                     ;
		mov     ah,4ch                  ; Exit to DOS
		int     21h                     ;
AllocMem        ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Free Allocated Memory. AX contains segment to free!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FreeMem         PROC    NEAR
		mov     es,ax                   ; Get segment to free
		mov     ah,49h                  ; Free allocated memory
		int     21h                     ;
		ret                             ; Return to caller
FreeMem         ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Decompress, decompresses image pointed to by DS:SI to ES:DI where BX is the
;             size in bytes
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Decompress      PROC    NEAR
Decompressit:   cmp     bx,0                    ;
		je      FinishDecomp            ;
		mov     al,ds:[si]              ;
		dec     bx                      ;
		cmp     al,128                  ;
		jb      GetPixel1               ;
		sub     al,128                  ;
		inc     si                      ;
		mov     ah,ds:[si]              ;
		dec     bx                      ;
		mov     ch,0                    ;
		mov     cl,al                   ;
		inc     cx                      ;
GetPixel2:      mov     es:[di],ah              ;
		inc     di                      ;
		loop    GetPixel2               ;
		inc     si                      ;
		cmp     bx,0                    ;
		je      FinishDecomp            ;
		jmp     Decompressit            ;
GetPixel1:      mov     es:[di],al              ;
		inc     di                      ;
		inc     si                      ;
		cmp     bx,0                    ;
		je      FinishDecomp            ;
		jmp     Decompressit            ;
FinishDecomp:   ret                             ;
Decompress      ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Random Number Generator!
;   Call:  AX Random number range 0-AX
; Return:  AX = Random Number!
;
; Remember to call Randomize once in program!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Random          PROC    NEAR
		push    ax
		call    Rnd2
		pop     ax
		mov     bx,ax
		xor     ax,ax
		or      bx,bx
		jz      RndEnd
		xchg    ax,dx
		div     bx
		xchg    ax,dx
RndEnd:         ret     
Rnd2:           mov     ax,cs:[Data_3]
		mov     bx,cs:[Data_4]
		mov     cx,ax
		mul     cs:[data_29]
		shl     cx,1
		shl     cx,1
		shl     cx,1
		add     ch,cl
		add     dx,cx
		add     dx,bx
		shl     bx,1
		shl     bx,1
		add     dx,bx
		add     dh,bl
		mov     cl,5
		shl     bx,cl
		add     dh,bl
		add     ax,1
		adc     dx,0
		mov     cs:[Data_3],ax
		mov     cs:[Data_4],dx
		ret
Random          ENDP
Data_29         dw      8405h
Data_3          dw      0
Data_4          dw      0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Call Randomize at start of program to seed RND Gen.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Randomize       PROC    NEAR
		mov     ah,2Ch
		int     21h                     
		mov     cs:[Data_3],cx
		mov     cs:[Data_4],dx
		ret
Randomize       ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Initalise Starfield
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InitaliseStars  PROC    NEAR
		mov     ax,MAINSEGD
		mov     ds,ax
		mov     cx,[NumStars]
		lea     si,StarPos
		xor     bx,bx
GenStar:        push    cx
		push    si
		push    bx
		mov     ax,320
		call    Random
		pop     bx
		pop     si
		cmp     ax,160
		jb      NegX
		sub     ax,160
		mov     ds:[si+bx],ax
		jmp     GetY
NegX:           neg     ax
		mov     ds:[si+bx],ax
GetY:           push    si
		push    bx
		mov     ax,200
		call    Random
		pop     bx
		pop     si
		cmp     ax,100
		jbe     NegY
		sub     ax,100
		mov     ds:[si+bx+2],ax
		jmp     EndY
NegY:           neg     ax
		mov     ds:[si+bx+2],ax
EndY:
		push    si
		push    bx
		mov     ax,[MaxZ]
		call    Random
		add     ax,100
		pop     bx
		pop     si
		mov     ds:[si+bx+4],ax
		pop     cx
		add     bx,8
		loop    GenStar
		ret
InitaliseStars  ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Display Stars
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DisplayStars    PROC    NEAR
                xor     bp,bp                   ; Init index
                mov     ax,0A000h               ;
                mov     es,ax                   ;
                mov     [StarPos2Pointer],0     ;
DisplaySLoop:   push    cx                      ;
                mov     cx,ds:[si+bp+4]         ; Get Z coordinate of star
                and     cx,cx                   ; Is Z=0
                jz      DontDrawStar            ; Yes, so dont display star
                mov     ax,ds:[si+bp+2]         ; Get Y coordinate of star
                movsx   dx,ah                   ; Extend sign into DX 
                shl     ax,8                    ; AX*256
                idiv    cx                      ; DX:AX / CX 
                add     ax,[YOrigin]            ; Add origin to new Y
                mov     di,ax                   ; Store new Y
                cmp     di,200                  ; Was star in range?
                jae     DontDrawStar            ; No, so don't draw star
                imul    di,320                  ; Make part of address
                mov     ax,ds:[si+bp]           ; Get X coordinate of star
                movsx   dx,ah                   ; Extend sign into DX
                shl     ax,8                    ; AX*256
                idiv    cx                      ; DX:AX / CX
                add     ax,[XOrigin]            ; Add origin to new X
                cmp     ax,320                  ; Was it in range?
                jae     DontDrawStar            ; No, so don't draw star
                add     di,ax                   ; DI now contains address
                mov     ds:[si+bp+6],di         ; Store address of star
                mov     al,es:[di]              ; Get pixel at star address
                and     al,al                   ; is it black (colour 0)
                jnz     DontDrawStar3           ; No, so don't draw star
                mov     ax,ds:[si+bp+4]         ; Get Z coordinate
                mov     cx,30                   ; Divide by 30
                xor     dx,dx                   ;
                idiv    cx                      ;
                add     ax,239                  ; Add 239 to get star colour
                mov     es:[di],al              ; Write star
                ; Place star positions and colour in new array
                push    bx
                push    si
                lea     si,StarPos2
                mov     bx,[StarPos2Pointer]
                mov     ds:[si+bx],di
                xor     ah,ah
                mov     ds:[si+bx+2],ax
                pop     si
                pop     bx
                add     [StarPos2Pointer],4
DontDrawStar2:  add     bp,8
		pop     cx
		loop    DisplaySLoop
		ret
DontDrawStar3:  push    bx
                push    si
                lea     si,StarPos2
                mov     bx,[StarPos2Pointer]
                mov     di,0
                mov     ax,0
                mov     ds:[si+bx],di
                mov     ds:[si+bx+2],ax
                pop     si
                pop     bx
                add     [StarPos2Pointer],4
                jmp     DontDrawStar2
DontDrawStar:   push    si
		lea     si,StarPos
		push    si
		push    bp
		mov     ax,320
		call    Random
		pop     bp
		pop     si
		cmp     ax,160
		jbe     NegX2
		sub     ax,160
		mov     ds:[si+bp],ax
		jmp     GetY2
NegX2:          neg     ax
		mov     ds:[si+bp],ax
GetY2:          push    si
		push    bp
		mov     ax,200
		call    Random
		pop     bp
		pop     si
		cmp     ax,100
		jbe     NegY2
		sub     ax,100
		mov     ds:[si+bp+2],ax
		jmp     GetZ2
NegY2:          neg     ax
		mov     ds:[si+bp+2],ax
GetZ2:          push    si
		push    bp
		mov     ax,400
		call    Random
		pop     bp
		pop     si
		mov     ax,[MaxZ]
		mov     ds:[si+bp+4],ax
		pop     si
                jmp     DontDrawStar3
DisplayStars    ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Erase stars and calculate next star positions!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EraseStars      PROC    NEAR
		xor     bx,bx
		mov     ax,0A000h
		mov     es,ax
EraseSLoop:     push    cx
		mov     di,ds:[si+bx+6] 
		mov     al,es:[di]
                cmp     al,239
                jb      DontEraseStar
DoEraseStar:    mov     al,0
		mov     es:[di],al
                jmp     ERS
DontEraseStar:  cmp     al,0
                je      DoEraseStar
ERS:            add     bx,8
		pop     cx
		loop    EraseSLoop

		mov     cx,[NumStars]
		xor     bx,bx
		lea     si,StarPos
DecZLoop:       mov     ax,ds:[si+bx+4]
		cmp     ax,4
		jb      SkipDecZ
		mov     ax,ds:[si+bx+4]
		sub     ax,4
		mov     ds:[si+bx+4],ax
SkipDecZ:       add     bx,8
		loop    DecZLoop
		ret
EraseStars      ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Display stars again using pre-calculated positions
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DisplayStars2   PROC    NEAR
                xor     bp,bp
                mov     ax,MAINSEGD
                mov     ds,ax
                mov     ax,0A000h
                mov     es,ax
                lea     si,StarPos2
                mov     cx,[NumStars]
DS2:            mov     di,ds:[si+bp]
                mov     al,es:[di]
                cmp     al,0
                jne     SkipDS2
                mov     ax,ds:[si+bp+2]
                cmp     al,0
                je      SkipDS2
                mov     es:[di],al
SkipDS2:        add     bp,4
                loop    DS2
                ret
DisplayStars2   ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Font scrolling routine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GetChar:        mov     ax,MAINSEGD
		mov     ds,ax
		mov     bx,[ScrollPointer]
		lea     di,ScrollText
		mov     al,[di+bx]
		cmp     al,255
		je      EndScrollText
		cmp     al,10
		jb      SpeedChange
GetChar2:       lea     di,CharSet
		xor     bx,bx
ScanCharLoop:   mov     ah,[di+bx]
		cmp     ah,0
		je      NoChar
		cmp     ah,al
		je      FoundChar
		inc     bx
		jmp     ScanCharLoop
NoChar:         mov     al,' '
		jmp     GetChar2
EndScrollText:  mov     [ScrollPointer],0
		mov     [FontClip],0
		jmp     GetChar
SpeedChange:    xor     ah,ah
		mov     [ScrollSpeed],ax
EndDelay:       inc     [ScrollPointer]
		mov     [FontClip],0
		jmp     GetChar
FoundChar:      lea     di,CharSetWidth
		shl     bx,1
		mov     ax,[di+bx]
		mov     [CurrentWidth],ax
		lea     di,CharSetOffset
		mov     ax,[di+bx]
		mov     [FontOffset],ax
		ret

WriteChar:      mov     ax,MAINSEGD
		mov     es,ax
		mov     ds,ax
		lea     di,ScrollImage
		mov     ax,[FontSeg]
		mov     ds,ax
		add     di,320
		mov     ax,es:[ScrollSpeed]
		shl     ax,2
		sub     di,ax
		mov     si,es:[FontOffset]
		add     si,es:[FontClip]
		mov     cx,es:[FontHeight]
WriteChar1:     push    cx
		mov     cx,es:[ScrollSpeed]
		cmp     cx,1
		ja      MoveWord
		repz    movsb
		jmp     DoneMove
MoveWord:       shr     cx,1
		repz    movsw
DoneMove:
		sub     si,es:[ScrollSpeed]
		sub     di,es:[ScrollSpeed]
		add     si,320
		add     di,320
		pop     cx
		loop    WriteChar1
		mov     ax,es:[ScrollSpeed]
		add     es:[FontClip],ax
		call    ShiftLeft
		ret
CorrectWidth    dw      0

ShiftLeft:      mov     ax,MAINSEGD
		mov     es,ax
		mov     ds,ax
		lea     di,ScrollImage
		mov     si,di
		add     si,[ScrollSpeed]
		xor     dx,dx
                mov     ax,320/4
		mov     cx,ax
		dec     cx
		mov     [CorrectWidth],cx
		mov     cx,[FontHeight]
m2:             push    cx
		mov     cx,[CorrectWidth]
		repz    movsd
		add     di,4
		add     si,4 
		pop     cx
		loop    m2
		ret

NewYPos         dw      0

DisplayText:    mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,ScrollImage
                mov     cs:[NewYPos],si
		mov     ax,[GFXBuffer]
		mov     es,ax
                xor     dx,dx
		mov     bx,0

DisplayLoop:    mov     si,cs:[NewYPos]
                push    bx
                shl     bx,1
                mov     ax,[YValues+bx]
                pop     bx
                mov     cx,320
                mul     cx
		mov     di,[FontPosY]
                add     di,ax
                add     di,bx

		mov     cx,[FontHeight]

CopyLoop:       mov     al,ds:[si]
                mov     es:[di],al
                add     di,320
		add     si,320
		loop    CopyLoop

                inc     cs:[NewYPos]
                inc     bx
		cmp     bx,320
		jb      DisplayLoop
		ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Screen retrace
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Retrace         PROC    NEAR
		mov     dx,3dah
Sync:           in      al,dx
                and     al,8
                jnz     Sync                                
Retr:           in      al,dx
		and     al,8
		jz      Retr
		ret
Retrace         ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Sets VGA colour palette
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Red             db      0
Green           db      0
Blue            db      0
SetPalette      PROC    NEAR
		mov     ax,MAINSEGD
		mov     ds,ax
		mov     es,ax
		mov     cx,255                
		lea     si,PaletteData        
		mov     dx,3c8h               
		mov     al,0                  
		out     dx,al                 
		inc     dx                    
SetPEL:         lodsb                         
		out     dx,al                 
		lodsb                         
		out     dx,al                 
		lodsb                         
		out     dx,al                 
		loop    SetPEL                
		; Set Starfield palette
		mov     dx,3c8h
		mov     al,239
		out     dx,al
		inc     dx
		mov     cx,16
		mov     al,63
SetPEL2:        out     dx,al
		out     dx,al
		out     dx,al
		sub     al,4
		loop    SetPEL2
		; Set font palette
		mov     al,7
		mov     dx,3c8h
		out     dx,al
		inc     dx
		mov     cx,26-7
		mov     cs:[Red],62
		mov     cs:[Green],0
		mov     cs:[Blue],0
SetPEL3:        mov     al,cs:[Red]
		out     dx,al
		mov     al,cs:[Green]
		out     dx,al
		mov     al,cs:[Blue]
		out     dx,al
		sub     cs:[Red],3
		loop    SetPEL3
		ret
SetPalette      ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Screen flash
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Shade           db      0
flash:          mov     al,0
                mov     cx,62
flash1:         push    cx
                mov     cx,255
flash2:         mov     dx,3c8h
                out     dx,al
                push    ax
                inc     dx
                mov     al,cs:[Shade]
                out     dx,al
                out     dx,al
                out     dx,al
                pop     ax
                inc     al
                loop    flash2
                mov     al,0
                inc     cs:[Shade]
                push    dx
                push    ax
                call    retrace
                pop     ax
                pop     dx
                pop     cx
                loop    flash1
                mov     al,0
                mov     cx,62
flash3:         push    cx
                mov     cx,255
flash4:         mov     dx,3c8h
                out     dx,al
                push    ax
                inc     dx
                mov     al,cs:[Shade]
                out     dx,al
                out     dx,al
                out     dx,al
                pop     ax
                inc     al
                loop    flash4
                mov     al,0
                dec     cs:[Shade]
                push    dx
                push    ax
                call    retrace
                pop     ax
                pop     dx
                pop     cx
                loop    flash3
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Check for user exit
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CheckExit:      push    ax
                clc
                pushf
                in      al,60h
                cmp     al,9ch
                jae     NoExit
                popf
                pop     ax
		stc
		ret
NoExit:         popf
                pop     ax
		ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Shutdown, cleans up computer and exits cleanly!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ShutDown        PROC    NEAR
		mov     ax,3
		int     10h
		mov     ax,[FontSeg]
		call    FreeMem
                mov     ax,MAINSEGD
                mov     ds,ax
                lea     si,ImageData
                mov     ax,[TextBuffer]
                mov     es,ax
                xor     di,di
                mov     cx,ImageData_Length
                call    Uncrunch
                mov     ah,2
                mov     bh,0
                mov     dh,0
                mov     dl,0
                int     10h
                lea     dx,BlankOut
                mov     ah,9
                int     21h
                mov     ah,2
                mov     bh,0
                mov     dh,21
                mov     dl,0
                int     10h
                lea     dx,Coder
                mov     ah,9
                int     21h
                mov     ah,2
                mov     bh,0
                mov     dh,23
                mov     dl,0
                int     10h
		mov     ah,4ch
		int     21h
ShutDown        ENDP

Toogle          PROC    NEAR
                push    dx
                push    ax
                mov     dx,3c4h
                mov     al,1
                out     dx,al
                inc     dx
                in      al,dx
                xor     al,00100000b
                out     dx,al
                pop     ax
                pop     dx
                ret
Toogle          ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Main body of program, execution starts here.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Main            PROC
		call    Check386                
		mov     ax,ss                   
		mov     ds,ax                   
		mov     cl,4                    
		lea     dx,TopOfStack           
		shl     ax,cl                   
		add     ax,dx                   
		mov     bx,ax                   
		mov     ax,MAINSEG              
		mov     ds,ax                   
		lea     dx,Start                
		shl     ax,cl                   
		add     ax,dx                   
		sub     bx,ax                  
		shr     bx,cl
		add     bx,20h                 
		xor     ax,ax                   
		mov     ah,4ah                  
		int     21h                     
		mov     ax,MAINSEGD             
		mov     ds,ax                   

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		call    CheckHardware           ; Check for correct hardware
                call    Randomize
		call    AllocMem                ; Allocate 64k for font
		mov     [FontSeg],ax            ; Store segment address
		mov     bx,[FontDataSize]       ;
		lea     si,FontData             ;
		mov     ax,[FontSeg]            ;
		mov     es,ax                   ;
		xor     di,di                   ;
		call    Decompress              ; Decompress font data
                push    ds
                push    es
                call    PlayMusic
                pop     es
                pop     ds
                ;call    InitMOD
                call    InitaliseStars
                mov     cx,10
InitLoop:       push    cx
                mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
                call    DisplayStars
		mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
                call    EraseStars
                pop     cx
                loop    InitLoop
                mov     ax,13h                  ; Set VGA mode to 320x200
		int     10h
                call    Flash
		call    SetPalette

                call    AllocMem
                mov     [LogoSeg],ax
                mov     bx,[Logo1DataSize]      ;
                lea     si,Logo1Data            ;
		mov     es,ax                   ;
		xor     di,di                   ;
		call    Decompress              ; Decompress font data

;ÄScroll Logo up screen over starfieldÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                mov     bp,200
ScrollUpLoop:   
                push    bp
		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars

                pop     bp
                push    bp
                mov     ax,bp
                mov     cx,320
                mul     cx
                mov     di,ax
                xor     si,si
                mov     ax,0A000h
                mov     es,ax

                mov     ax,320/4
                cmp     bp,130
                jbe     ScrollLimit
ContinueScroll: mov     cx,bp
                sub     cx,200
                neg     cx
                inc     cx
                mul     cx
                mov     cx,ax
                push    ds
                mov     ax,[LogoSeg]
                mov     ds,ax
                repz    movsd
                pop     ds
                call    DisplayStars2
                call    Retrace
                lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars
                pop     bp
                dec     bp
                cmp     bp,1
                ja      ScrollUpLoop
                jmp     EndScrollUp
ScrollLimit:    mov     bp,130
                jmp     ContinueScroll
EndScrollUp:
		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars

                mov     ax,[LogoSeg]
                call    FreeMem
                push    ds
                ;call    PlayMOD
                pop     ds
		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov     [ScrollPointer],0
		mov     [ScrollSpeed],1
		mov     [FontClip],0
ScrollLoop:
		call    CheckExit
		jc      ExitScroll
		call    GetChar
DisplayChar:    
                call    CheckExit
                jc      ExitScroll
                call    WriteChar
		mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars
                call    DisplayText
                call    DisplayStars2

                call    Retrace
		mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars
ContinueDisp:   mov     ax,MAINSEGD
		mov     ds,ax
		mov     ax,[CurrentWidth]
		inc     ax
		cmp     [FontClip],ax
		jb      DisplayChar
		mov     [FontClip],0
		inc     [ScrollPointer]
		jmp     ScrollLoop
ExitScroll:     ;call    StopMOD
                call    StopMusic
		call    Shutdown

Main            ENDP
	       .8086
MAINSEG         ENDS


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Stack segemt, reserved 1025bytes for stack
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STACKSEG        SEGMENT PARA STACK 'STACK'
		.8086
                db      1024 dup('S')
TopOfStack      db      0                       ; Used to calculate prog size
STACKSEG        ENDS

		END     START
