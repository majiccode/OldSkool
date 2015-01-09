;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Starfield intro by TRIPWIRE
;
; Assemble using TASM 2.x or above!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		.MODEL  large
                 LOCALS
                .386
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Data for MAINSEG
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAINSEGD        SEGMENT USE16 PARA PUBLIC 'DATA'
		ORG     0000h   

TextBuffer      dw      0B800h                  ; Text video buffer address
GFXBuffer       dw      0A000h                  ; Graphics video buffer address
; *** Startfield varibles ***
XOrigin         dw      160                     ; X origin on screen
YOrigin         dw      100                     ; Y origin on screen

MaxZ            dw      480                     ; Leave this alone
NumStars        dw      300                     ; Number of stars on screen
StarPos         dw      300 dup(0,0,0,0)        ; Buffer for stars
StarPos2        dw      300 dup(0,0)            ; X,Y,Z,StarPos
StarPos2Pointer dw      0
WarpSpeed       dw      6

; *** Font Varibles ***

BackdropSeg     dw      0
FontPosY        dw      320*130                 ; Position to start scroll
FontHeight      dw      25                      ; Height of font
FontWidth       dw      31                      ; Width of font
FontSeg         dw      0                       ; Segment address of font
ScrollPointer   dw      0                       ; Pointer into scroll message
FontSlice       dw      0                       ; Current slice of char
CurrentOffset   dw      0                       ; Current char offset
CorrectWidth    dw      0
ScrollBuffer    db      320*27 dup(0)
SinusPointer    dw      360
ScrollSpeed     dw      0
FontPos2         dw      90
SmallTextPointer dw     0


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
include         FONT.INC
include         LOGO1.INC
include         ENDMSG.INC

; *** Scrolling Message ***
include         TEXT.INC


MAINSEGD        ENDS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Mod Player Segment
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PLAYERSEG       SEGMENT USE16 PARA PUBLIC 'DATA'
                ORG     0000h   
include         PLAYER.DAT
PLAYERSEG       ENDS

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Main code segment
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAINSEG         SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME  CS:MAINSEG, DS:MAINSEGD, SS:STACKSEG

Start:          call    Main                    ; Start of program
ScreenSeg       dw      0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MOD Player calls 
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
include         PLAY.INC
include         THEDRAW.INC

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
                mov     ax,cs:[ScreenSeg]       ;
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
                jnz     DontDrawStar2           ; No, so don't draw star
                mov     ax,ds:[si+bp+4]         ; Get Z coordinate
                mov     cx,30                   ; Divide by 30
                xor     dx,dx                   ;
                idiv    cx                      ;
                add     ax,239                  ; Add 239 to get star colour
                mov     es:[di],al              ; Write star
                ; Place star positions and colour in new array
                ;push    bx
                ;push    si
                ;lea     si,StarPos2
                ;mov     bx,[StarPos2Pointer]
                ;mov     ds:[si+bx],di
                ;xor     ah,ah
                ;mov     ds:[si+bx+2],ax
                ;pop     si
                ;pop     bx
                ;add     [StarPos2Pointer],4
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
                jmp     DontDrawStar2
DisplayStars    ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Erase stars and calculate next star positions!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EraseStars      PROC    NEAR
		xor     bx,bx
                mov     ax,cs:[ScreenSeg]
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
                sub     ax,[WarpSpeed]
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
                mov     ax,cs:[ScreenSeg]
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
; Print Char on screen in small font
;
; Call: AX = X
;       BX = Y
;       CL = Char to print
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintChar       PROC    NEAR
                push    ds
                push    es
                push    di
                push    si
                push    ax
                mov     ax,MAINSEGD
                mov     ds,ax
                mov     ax,[FontSeg]
                mov     es,ax
                pop     ax
                lea     si,CharSet2
                xor     bp,bp
GetOffset:      mov     dl,ds:[si+bp]
                cmp     dl,cl
                je      @@GotChar
                inc     bp
                jmp     GetOffset
@@GotChar:      lea     si,Char2SetOffset
                shl     bp,1
                mov     dx,ds:[si+bp]
                mov     si,dx
                push    ax
                mov     ax,[FontSeg]
                mov     ds,ax
                mov     ax,cs:[ScreenSeg]
                mov     es,ax
                pop     ax
                mov     cx,320
                xchg    ax,bx
                mul     cx
                add     ax,bx
                mov     di,ax

                mov     cx,9
DispChar:       push    cx
                mov     cx,7
                repz    movsb
                sub     di,7
                sub     si,7
                add     di,320
                add     si,320
                pop     cx
                loop    DispChar
                pop     si
                pop     di
                pop     es
                pop     ds
                ret
PrintChar       ENDP
MsgCounter      dw      0
MsgLength       dw      0
GotLength       db      0
DisplayMsg      PROC    NEAR
                push    ds
                push    ax
                push    bx
                mov     ax,MAINSEGD
                mov     ds,ax
                lea     di,SmallText
                mov     bx,[SmallTextPointer]
                mov     al,ds:[di+bx]
                cmp     al,0
                je      ResetMsg
                cmp     al,1
                je      NextMsg
                mov     cl,al
                push    cx
                mov     ax,bx
                sub     ax,cs:[MsgLength]
                mov     cx,8
                mul     cx
                mov     bx,[FontPos2]
                pop     cx
                call    PrintChar
                inc     [SmallTextPointer]
SkipPrintSmall: 
                pop     bx
                pop     ax
                pop     ds
                ret
NextMsg:        mov     cs:[MsgLength],bx
                inc     cs:[MsgCounter]
                cmp     cs:[MsgCounter],6
                je      ShowNextMsg
                jmp     SkipPrintSmall
ShowNextMsg:    mov     cs:[MsgCounter],0
                inc     [SmallTextPointer]
                jmp     SkipPrintSmall
ResetMsg:       mov     cs:[SmallTextPointer],0
                mov     cs:[MsgLength],0
                jmp     SkipPrintSmall
DisplayMsg      ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Font scrolling routine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;GetChar:        mov     ax,MAINSEGD
;                mov     ds,ax
;                mov     bx,[ScrollPointer]
;                lea     di,ScrollText
;                mov     al,[di+bx]
;                cmp     al,255
;                je      EndScrollText
;                cmp     al,10
;                jb      SpeedChange
;GetChar2:       lea     di,CharSet
;                xor     bx,bx
;ScanCharLoop:   mov     ah,[di+bx]
;                cmp     ah,0
;                je      NoChar
;                cmp     ah,al
;                je      FoundChar
;                inc     bx
;                jmp     ScanCharLoop
;NoChar:         mov     al,' '
;                jmp     GetChar2
;EndScrollText:  mov     [ScrollPointer],0
;                mov     [FontClip],0
;                jmp     GetChar
;SpeedChange:    xor     ah,ah
;                mov     [ScrollSpeed],ax
;EndDelay:       inc     [ScrollPointer]
;                mov     [FontClip],0
;                jmp     GetChar
;FoundChar:      lea     di,CharSetWidth
;                shl     bx,1
;                mov     ax,[di+bx]
;                mov     [CurrentWidth],ax
;                lea     di,CharSetOffset
;                mov     ax,[di+bx]
;                mov     [FontOffset],ax
;                ret
;
;WriteChar:      mov     ax,MAINSEGD
;                mov     es,ax
;                mov     ds,ax
;                lea     di,ScrollImage
;                mov     ax,[FontSeg]
;                mov     ds,ax
;                add     di,320
;                mov     ax,es:[ScrollSpeed]
;                shl     ax,2
;                sub     di,ax
;                mov     si,es:[FontOffset]
;                add     si,es:[FontClip]
;                mov     cx,es:[FontHeight]
;WriteChar1:     push    cx
;                mov     cx,es:[ScrollSpeed]
;                cmp     cx,1
;                ja      MoveWord
;                repz    movsb
;                jmp     DoneMove
;MoveWord:       shr     cx,1
;                repz    movsw
;DoneMove:
;                sub     si,es:[ScrollSpeed]
;                sub     di,es:[ScrollSpeed]
;                add     si,320
;                add     di,320
;                pop     cx
;                loop    WriteChar1
;                mov     ax,es:[ScrollSpeed]
;                add     es:[FontClip],ax
;                call    ShiftLeft
;                ret
;CorrectWidth    dw      0
;
;ShiftLeft:      mov     ax,MAINSEGD
;                mov     es,ax
;                mov     ds,ax
;                lea     di,ScrollImage
;                mov     si,di
;                add     si,[ScrollSpeed]
;                xor     dx,dx
;                mov     ax,320/4
;                mov     cx,ax
;                dec     cx
;                mov     [CorrectWidth],cx
;                mov     cx,[FontHeight]
;m2:             push    cx
;                mov     cx,[CorrectWidth]
;                repz    movsd
;                add     di,4
;                add     si,4 
;                pop     cx
;                loop    m2
;                ret

;NewYPos         dw      0
;
;DisplayText:    mov     ax,MAINSEGD
;                mov     ds,ax
;                lea     si,ScrollImage
;                mov     cs:[NewYPos],si
;                mov     ax,[GFXBuffer]
;                mov     es,ax
;                xor     dx,dx
;                mov     bx,0
;
;DisplayLoop:    mov     si,cs:[NewYPos]
;                push    bx
;                shl     bx,1
;                mov     ax,[YValues+bx]
;                pop     bx
;                mov     cx,320
;                mul     cx
;                mov     di,[FontPosY]
;                add     di,ax
;                add     di,bx
;
;                mov     cx,[FontHeight]
;
;CopyLoop:       mov     al,ds:[si]
;                mov     ah,al
;                mov     es:[di],ax
;                mov     es:[di+320],ax
;                add     di,320*2
;                add     si,320
;                loop    CopyLoop
;
;                inc     cs:[NewYPos]
;                inc     bx
;                inc     bx
;                cmp     bx,320
;                jb      DisplayLoop
;                ret
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Sinus Scroller Routine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Scroller        PROC    NEAR
                mov     ax,MAINSEGD             ;
                mov     ds,ax                   ;
                cmp     [FontSlice],0           ;
                jne     ProcessChar             ;
NewChar:        mov     bx,[ScrollPointer]      ; Get index into scrolltext
                lea     di,ScrollText           ; DI points to start of text
                mov     al,ds:[di+bx]           ; Get Char to scroll
                cmp     al,255                  ;
                je      ResetScrollPointer      ;
                cmp     al,10                   ;
                jb      ScrollerSpeed           ;
                lea     si,CharSet              ; 
                xor     bx,bx                   ;
GetChar:        mov     ah,ds:[si+bx]           ;
                cmp     ah,al                   ;
                je      GotChar                 ;
                inc     bx                      ;
                and     ah,ah                   ;
                jz      BadChar                 ;
                jmp     GetChar                 ;
ResetScrollPointer:                             ;
                mov     [ScrollPointer],0       ; Reset to start of text
                jmp     NewChar                 ; Start again
UpDatePointer:  inc     [ScrollPointer]         ; Point to next char
                jmp     NewChar                 ; Start again
ScrollerSpeed:  xor     ah,ah                   ;
                mov     [ScrollSpeed],ax        ;
                inc     [ScrollPointer]         ;
                jmp     NewChar                 ;
BadChar:        xor     bx,bx                   ;
GotChar:        shl     bx,1                    ; Make into index
                mov     ax,[CharSetOffset+bx]   ; Character offset in memory
                mov     [CurrentOffset],ax      ; Save character offset
                mov     [FontSlice],1           ; Point to slice 1 of char
ProcessChar:    cmp     [FontSlice],32
                ja      UpdatePointer
                mov     si,[CurrentOffset]
                mov     ax,[FontSlice]
                dec     ax
                add     si,ax
                lea     di,ScrollBuffer
                add     di,320
                add     di,320
                mov     ax,[ScrollSpeed]
                shl     ax,2
                sub     di,ax
                mov     cx,[FontHeight]
                mov     bx,[ScrollSpeed]
                mov     ax,[FontSeg]
                push    ds
                mov     ds,ax
                mov     ax,MAINSEGD
                mov     es,ax
                cld

DrawSlice1:     push    cx
                mov     cx,bx
DrawSlice:      repz    movsb
                sub     di,bx
                sub     si,bx
                add     di,320
                add     si,320
                pop     cx
                dec     cx
                jnz     DrawSlice1
                pop     ds
                cmp     bx,0
                jne     NextSlice
                mov     bx,1
NextSlice:      add     [FontSlice],bx

                ; Shift scroll buffer to the left
                mov     ax,ds
                mov     es,ax
                lea     di,ScrollBuffer
                add     di,320
                mov     si,di
                add     si,[ScrollSpeed]
		xor     dx,dx
                mov     cx,320/4-1
		mov     [CorrectWidth],cx
		mov     cx,[FontHeight]
ShiftLeft:      push    cx
		mov     cx,[CorrectWidth]
		repz    movsd
		add     di,4
		add     si,4 
		pop     cx
                dec     cx
                jnz     ShiftLeft
                ret
Scroller        ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Display scroll text over background. No MASK!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DisplayScroll   PROC    NEAR
                mov     ax,MAINSEGD
                mov     ds,ax
                mov     ax,cs:[ScreenSeg]
                mov     es,ax
                xor     bx,bx

                mov     bp,[SinusPointer]

DoDisplay:      cmp     bp,-1
                je      WrapSinus
                cmp     bp,-2
                je      WrapSinus

DoDisplay2:     cmp     bp,-2
                je      WrapSinus2

GetSinus:       shl     bp,1
                mov     di,[YValues+bp]
                shr     bp,1
                add     di,[FontPosY]
                add     di,bx
                lea     si,ScrollBuffer
                push    bx
                shr     bx,1
                add     si,bx
                pop     bx
                mov     cx,27
DisplaySlice:   mov     al,ds:[si]
                ;cmp     al,0
                ;je      SkipSl
                mov     ah,al
                mov     es:[di],ax
SkipSl:         mov     es:[di+320],ax
                add     di,320
                add     di,320
                add     si,320
                dec     cx
                jnz     DisplaySlice
                inc     bp
                cmp     bp,360
                ja      NewBP
                jmp     OldBP
NewBP:          mov     bp,0
OldBP:          inc     bx
                inc     bx
                cmp     bx,319
                ja      EndDisplayScroll
                jmp     DoDisplay2
WrapSinus:      mov     bp,360
                mov     [SinusPointer],bp
                jmp     GetSinus
WrapSinus2:     mov     bp,360
                jmp     GetSinus
EndDisplayScroll:
                dec     [SinusPointer]
                ;dec     [SinusPointer]

                ret
DisplayScroll   ENDP

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
; Fade out screen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FadeOut         PROC    NEAR
                mov     ax,MAINSEGD
                mov     ds,ax
                mov     es,ax
DoFade:         xor     bx,bx
                xor     ax,ax
                mov     cx,255*3
                lea     si,PaletteData
                lea     di,PaletteData
GrabColour:     lodsb
                and     al,al
                jz      DoneColour
                dec     al
WriteColour:    stosb
                loop    GrabColour
                call    Retrace

                mov     cx,255
                lea     si,PaletteData
                mov     dx,3c8h
                mov     al,0
                out     dx,al
                inc     dx
SetPal:         repz    outsb
                mov     cx,8000h
                loop    $
                jmp     DoFade

DoneColour:     inc     bx
                cmp     bx,255*3
                jne     WriteColour
                ret
FadeOut         ENDP
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
                mov     ax,[ScreenSeg]
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
		call    AllocMem                ; Allocate 64k for font
                mov     [ScreenSeg],ax          ; Store segment address
                call    InitMOD
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

                mov     ax,cs:[ScreenSeg]
                mov     es,ax
                xor     edi,edi
                xor     eax,eax
                mov     cx,64000 / 4
                repz    stosd

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

                push    ds
                call    PlayMOD
                pop     ds

;ÄScroll Logo up screen over starfieldÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                mov     bp,200
ScrollUpLoop:   
                push    bp

                pop     bp
                push    bp
                mov     ax,bp
                mov     cx,320
                mul     cx
                mov     di,ax
                xor     si,si
                mov     ax,cs:[ScreenSeg]
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

		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars

                push    ds
                push    es
                mov     ax,cs:[ScreenSeg]
                mov     ds,ax
                xor     si,si
                xor     di,di
                mov     ax,0A000h
                mov     es,ax
                mov     cx,64000 / 4
                repz    movsd
                pop     es
                pop     ds

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
		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		mov     [ScrollPointer],0
		mov     [ScrollSpeed],1
ScrollLoop:     
                call    DisplayMsg
		call    CheckExit
		jc      ExitScroll

                call    Scroller
                call    DisplayScroll
		mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars

                push    ds
                push    es
                mov     ax,cs:[ScreenSeg]
                mov     ds,ax
                xor     si,si
                xor     di,di
                mov     ax,0A000h
                mov     es,ax
                mov     cx,64000 / 4
                repz    movsd
                pop     es
                pop     ds

                call    Retrace

                mov     ax,MAINSEGD
		mov     ds,ax
		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars
		jmp     ScrollLoop
ExitScroll:     call    StopMOD
                call    FadeOut
                call    Shutdown

Main            ENDP
MAINSEG         ENDS


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Stack segemt, reserved 1025bytes for stack
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STACKSEG        SEGMENT USE16 PARA STACK 'STACK'
                db      1024 dup('S')
TopOfStack      db      0                       ; Used to calculate prog size
STACKSEG        ENDS

		END     START
