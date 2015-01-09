컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Starfield intro.
;
; Optimization: I have used shifts for alot of maths.
;
; Coded by Tripwire in 1995!
;
; The sound routines were done by Future Crew.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		.MODEL  large
		 LOCALS
		.386

BORDERS=1       ;set to 1 for visible border-timings

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Data for MAINSEG
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MAINSEGD        SEGMENT USE16 PARA PUBLIC 'DATA'

TextBuffer      dw      0B800h                  ; Text video buffer address
GFXBuffer       dw      0A000h                  ; Graphics video buffer address

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
XOrigin         dw      160                     ; X origin on screen
YOrigin         dw      100                     ; Y origin on screen

MaxZ            dw      480                     ; Leave this alone
NumStars        dw      800                    ; Number of stars on screen
StarPos         dw      800 dup(0,0,0,0)        ; Buffer for stars
StarPos2        dw      800 dup(0,0)            ; X,Y,Z,StarPos
StarPos2Pointer dw      0
WarpSpeed       dw      6
_320Table       dw      200 dup(0)
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

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
ScreenPos       dw      0

LogoSeg         dw      0
FireSeg         dw      0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
include         SINUS1.INC
include         PALETTE.INC
include         TEXT.INC
include         FONT.INC
include         LOGO1.INC
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Error2          db      'This intro requires a VGA card!$'
Error3          db      'DOS version is too low!$'
Error4          db      'Memory Allocation Error!$'
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_musiccnt      dw      0
a_chdelaycnt    db      9 dup(0)
a_chdelay       db      9 dup(0)

a_inst_table    LABEL BYTE
                db      20h+0,20h+1,20h+2,20h+8,20h+9,20h+10,20h+16,20h+17,20h+18
NTB             equ     8192 ;+1024*1 8192
a_note_table    LABEL WORD
                dw      NTB+363,NTB+385,NTB+408,NTB+432,NTB+458,NTB+485
                dw      NTB+514,NTB+544,NTB+577,NTB+611,NTB+647,NTB+868
                dw      0 

music_channels  equ     8
music_speed     equ     8
music_instruments       LABEL BYTE
                dw      OFFSET ains6
                dw      OFFSET ains2
                dw      OFFSET ains4
                dw      OFFSET ains3
                dw      OFFSET ains3
                dw      OFFSET ains1
                dw      OFFSET ains1
                dw      OFFSET ains4
ains1           LABEL BYTE
                db      65,194,6,0,35,242,240,240,1,0,4
ains2           LABEL BYTE
                db      145,64,135,128,243,111,35,3,1,1,2
ains3           LABEL BYTE
                db      225,33,17,128,17,19,34,34,0,0,12
ains4           LABEL BYTE
                db      97,33,27,0,98,132,86,85,0,0,14
ains6           LABEL BYTE
                db      145,64,135,136,243,111,35,3,1,1,2
music_patterns  LABEL BYTE
ach0            dw      OFFSET ach0d,OFFSET ach0dr
ach1            dw      OFFSET ach1d,OFFSET ach1dr
ach2            dw      OFFSET ach2d,OFFSET ach2dr
ach3            dw      OFFSET ach3d,OFFSET ach3d
ach4            dw      OFFSET ach4d,OFFSET ach4d
ach5            dw      OFFSET ach5d,OFFSET ach5d
ach6            dw      OFFSET ach6d,OFFSET ach6d
ach7            dw      OFFSET ach7d,OFFSET ach7d
ach0d           LABEL BYTE
                db      081h
ach0dr          LABEL BYTE
                db      057h,050h,050h,055h,057h,050h,055h,057h
                db      050h,055h,057h,050h,055h,057h,050h,055h
                db      0
ach1d           LABEL BYTE
                db      081h
ach1dr          LABEL BYTE
                db      050h,055h,057h,050h,055h,057h,050h,055h
                db      057h,050h,055h,057h,050h,055h,057h,050h
                db      0
ach2d           LABEL BYTE
                db      0C0h,050h,084h
                db      030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
                db      030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
ach2dr          LABEL BYTE
                db      030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
                db      025h,015h,025h,015h,028h,018h,02Ah,01Ah
                db      0
ach3d           LABEL BYTE
                db      0A0h,050h,040h,0C0h,040h,088h,040h,040h
                db      03Ah,042h,090h,045h,088h,040h,042h,040h
                db      047h,090h,04Ah,088h,045h,098h,040h
                db      0
ach4d           LABEL BYTE
                db      0A0h,050h,030h,0C0h,047h,088h,047h,043h
                db      042h,045h,047h,045h,048h,047h,047h,050h
                db      052h,084h,050h,04Ah,088h,050h,098h,045h
                db      0
ach5d           LABEL BYTE
                db      0C0h,020h,0A0h,010h,010h,090h,010h,02Ah
                db      025h,088h,028h,02Ah,090h,010h,02Ah,025h
                db      088h,028h,02Ah
                db      0
ach6d           LABEL BYTE
                db      0C0h,020h,0A0h,020h,020h,090h,020h,01Ah
                db      015h,088h,018h,01Ah,090h,020h,01Ah,015h
                db      088h,018h,01Ah
                db      0
ach7d           LABEL BYTE
                db      0C0h,00Ch,0FEh,050h,090h,00Ch,081h,04Ah
                db      050h,084h,052h,055h,086h,04Ah,081h,050h
                db      04Ah,086h,050h,082h,055h,098h,045h
                db      0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MAINSEGD        ENDS

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Main code segment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MAINSEG         SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME  CS:MAINSEG, DS:MAINSEGD, SS:STACKSEG

Start:          call    Main                    ; Start of program
ScreenSeg       dw      0A000h
FrameCount      dw      0

include         DEBUG.INC
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Simple Adlib Player taken from SPACE PORT INTRO BY FC!
;
; Notes: This doesn't just read raw data to output to adlib like the one
;        used in the last starport intro. This player really does have 
;        note & instrument data it reads and processes!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetBorder       MACRO   Col
                IF      BORDERS
                push    ax
                push    dx
                mov     dx,3dah
                in      al,dx
                mov     dx,3c0h
                mov     al,11h+32
                out     dx,al
                mov     al,Col
                out     dx,al
                pop     dx
                pop     ax
                ENDIF
                ENDM

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Output data to Adlib
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_lodsboutaw03: ;size optimization related entry (instrument loading)
                call    a_lodsboutaw
                add     ah,3
a_lodsboutaw: ;size optimization related entry (instrument loading)
                lodsb
a_outaw	PROC NEAR ;ah=reg,al=data
                push    ax
                push    cx
                xchg    al,ah
                mov     dx,388h
                out     dx,al
                mov     cx,7
                call    a_wait
                mov     dx,389h
                mov     al,ah
                out     dx,al
                mov     cx,30
                call    a_wait
                pop     cx
                pop     ax
                ret
a_wait:         in      al,dx
                loop    a_wait
                ret
a_outaw         ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Load instrument to Adlib
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_loadinstrument PROC NEAR
                ;bx=channel, ds:si=offset to instrument data
                mov     ah,ds:a_inst_table[bx]
                mov     cx,4
@@1:            call    a_lodsboutaw03
                add     ah,20h-3
                loop    @@1
                add     ah,40h
                call    a_lodsboutaw03
                mov     ah,bl
                add     ah,0c0h
                jmp     a_lodsboutaw
a_loadinstrument ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Set note on/off
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_playnote      PROC NEAR
                ;bx=channel, ax=data
                push    bx
                xchg    ah,bl
                add     ah,0a0h
                call    a_outaw
                mov     al,bl
                add     ah,010h
                pop     bx
                jmp     a_outaw
a_playnote      ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Initalise/clear/shutup Adlib
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_init          PROC NEAR
                mov     ax,0800h          ; Set FM music mode
                call    a_outaw
                mov     ax,0bd00h         ; AM Depth / Vibrato Depth / Rhythm
                call    a_outaw
                mov     bp,9              ; 9 Channels
                xor     bx,bx
                mov     di,OFFSET music_instruments
@@1:            mov     si,ds:[di]
                add     di,2
                call    a_loadinstrument
                xor     ax,ax             ; Slience channel by playing
                call    a_playnote        ; nothing
                inc     bx
                dec     bp
                jnz     @@1 
                ret
a_init          ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Advance music one row
; (Plays part of song! Call this is a loop to play entire song)
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
a_dorow         PROC NEAR
                cli
                mov     ax,MAINSEGD
                mov     ds,ax
                mov     es,ax
                sub     ds:a_musiccnt,1
                jnc     @@0
                mov     ds:a_musiccnt,music_speed
                mov     cx,music_channels
                mov     di,OFFSET music_patterns
                xor     bx,bx
@@1:            sub     ds:a_chdelaycnt[bx],1
                jns     @@2
                mov     si,ds:[di] 
                xor     ax,ax
                call    a_playnote
@@4:            lodsb 
                or      al,al
                jz      @@7
                jns     @@6
                sub     al,81h
                mov     ds:a_chdelay[bx],al
                lodsb
@@6:            mov     dl,al
                and     ax,15
                mov     bp,ax
                add     bp,bp
                mov     ax,ds:a_note_table[bp]
                shr     dl,2
                and     dl,not 3
                add     ah,dl
                call    a_playnote
                mov     al,ds:a_chdelay[bx]
                mov     ds:a_chdelaycnt[bx],al
                mov     ds:[di],si
@@2:            add     di,4
                inc     bx
                loop    @@1
@@0:            sti
                ret
@@7:            mov     si,ds:[di+2]
                jmp     @@4
a_dorow         ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Check for a 386 processor or above.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Check hardware
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Allocate Memory, Return segment address in AX.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Free Allocated Memory. AX contains segment to free!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FreeMem         PROC    NEAR
		mov     es,ax                   ; Get segment to free
		mov     ah,49h                  ; Free allocated memory
		int     21h                     ;
		ret                             ; Return to caller
FreeMem         ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Decompress, decompresses image pointed to by DS:SI to ES:DI where BX is the
;             size in bytes
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Random Number Generator!
;   Call:  AX Random number range 0-AX
; Return:  AX = Random Number!
;
; Remember to call Randomize once in program!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Random          PROC    NEAR
                push    cx
                push    si
                push    di
                push    dx
                push    bx
                mov     cx,ax          ; save limit
                mov     ax,word ptr cs:[RandSeed+2]
                mov     bx,word ptr cs:[RandSeed]
                mov     si,ax
                mov     di,bx
                mov     dl,ah
                mov     ah,al
                mov     al,bh
                mov     bh,bl
                xor     bl,bl
                rcr     dl,1
                rcr     ax,1
                rcr     bx,1
                add     bx,di
                adc     ax,si
                add     bx,62e9h
                adc     ax,3619h
                mov     word ptr cs:[RandSeed],bx
                mov     word ptr cs:[RandSeed+2],ax
                xor     dx,dx
                div     cx
                mov     ax,dx                  ; return modulus
                pop     bx
                pop     dx
                pop     di
                pop     si
                pop     cx
		ret
Random          ENDP
RandSeed        dd      0

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Call Randomize at start of program to seed RND Gen.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Randomize       PROC    NEAR
                mov     ah,2Ch
                int     21h
                mov     word ptr cs:[RandSeed],cx
                mov     word ptr cs:[RandSeed+2],dx
		ret
Randomize       ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Initalise Starfield
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InitaliseStars  PROC    NEAR
		mov     ax,MAINSEGD
		mov     ds,ax
		mov     cx,[NumStars]
		lea     si,StarPos
		xor     bx,bx
GenStar:        push    cx
		push    bx
		mov     ax,320
		call    Random
		pop     bx
		cmp     ax,160
		jb      NegX
		sub     ax,160
		mov     ds:[si+bx],ax
		jmp     GetY
NegX:           neg     ax
		mov     ds:[si+bx],ax
GetY:           push    bx
		mov     ax,200
		call    Random
		pop     bx
		cmp     ax,100
		jbe     NegY
		sub     ax,100
		mov     ds:[si+bx+2],ax
		jmp     EndY
NegY:           neg     ax
		mov     ds:[si+bx+2],ax
EndY:
		push    bx
		mov     ax,[MaxZ]
		call    Random
		add     ax,100
		pop     bx
		mov     ds:[si+bx+4],ax
		pop     cx
		add     bx,8
		loop    GenStar
		ret
InitaliseStars  ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Display Stars.              Optimized 12/6/95!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DisplayStars    PROC    NEAR
		xor     bp,bp                   ; Init index
		mov     ax,cs:[ScreenSeg]       ;
		mov     es,ax                   ;
DisplaySLoop:   mov     bx,ds:[si+bp+4]         ; Get Z coordinate of star
                and     bx,bx                   ; Is Z=0
                jz      DontDrawStar            ; Yes, so dont display star
		mov     ax,ds:[si+bp+2]         ; Get Y coordinate of star
		movsx   dx,ah                   ; Extend sign into DX 
		shl     ax,8                    ; AX*256
                idiv    bx                      ; DX:AX / CX 
		add     ax,[YOrigin]            ; Add origin to new Y
		mov     di,ax                   ; Store new Y
		cmp     di,200                  ; Was star in range?
		jae     DontDrawStar            ; No, so don't draw star
                mov     dx,di
                mov     dh,dl
                xor     dl,dl
                shl     di,6
                add     di,dx
		mov     ax,ds:[si+bp]           ; Get X coordinate of star
		movsx   dx,ah                   ; Extend sign into DX
		shl     ax,8                    ; AX*256
                idiv    bx                      ; DX:AX / CX
		add     ax,[XOrigin]            ; Add origin to new X
		cmp     ax,320                  ; Was it in range?
		jae     DontDrawStar            ; No, so don't draw star
		add     di,ax                   ; DI now contains address
		mov     ds:[si+bp+6],di         ; Store address of star
		mov     al,es:[di]              ; Get pixel at star address
                or      al,al                   ; is it black (colour 0)
		jnz     DontDrawStar2           ; No, so don't draw star
		mov     ax,ds:[si+bp+4]         ; Get Z coordinate
                shr     ax,5
		add     ax,239                  ; Add 239 to get star colour
		mov     es:[di],al              ; Write star
DontDrawStar2:  add     bp,8
                dec     cx
                jnz     DisplaySLoop
		ret

; If a star has a Z value of 0 or its X and Y are outside screen boundary
; then create a new star.

DontDrawStar:   mov     ax,320
                call    Random
                cmp     ax,160
                jbe     NegX2
                sub     ax,160
                mov     ds:[si+bp],ax
                jmp     GetY2
NegX2:          neg     ax
                mov     ds:[si+bp],ax
GetY2:          mov     ax,200
                call    Random
                cmp     ax,100
                jbe     NegY2
                sub     ax,100
                mov     ds:[si+bp+2],ax
                jmp     GetZ2
NegY2:          neg     ax
                mov     ds:[si+bp+2],ax
GetZ2:          mov     ax,[MaxZ]
                mov     ds:[si+bp+4],ax
                jmp     DontDrawStar2
DisplayStars    ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Erase stars and calculate next star positions!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
EraseStars      PROC    NEAR
		xor     bx,bx
		mov     ax,cs:[ScreenSeg]
		mov     es,ax
EraseSLoop:     mov     ax,ds:[si+bx+4]
		cmp     ax,4
		jb      SkipDecZ
		mov     ax,ds:[si+bx+4]
		sub     ax,[WarpSpeed]
		mov     ds:[si+bx+4],ax
SkipDecZ:       mov     di,ds:[si+bx+6] 
		mov     al,es:[di]
		cmp     al,239
		jb      DontEraseStar
DoEraseStar:    xor     al,al
		mov     es:[di],al
		jmp     ERS
DontEraseStar:  or      al,al
                jz      DoEraseStar
ERS:            add     bx,8
                dec     cx
                jnz     EraseSLoop
		ret
EraseStars      ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Print Char on screen in small font
;
; Call: AX = X
;       BX = Y
;       CL = Char to print
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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
                mov     di,bx
                mov     bh,bl
                xor     bl,bl
                shl     di,6
                add     di,bx

                add     di,ax

		mov     cx,9
DispChar:       add     di,cs:[InsideChar]
                add     si,cs:[InsideChar]
                dec     di
                dec     si
                movsb
                sub     di,cs:[InsideChar]
                sub     si,cs:[InsideChar]
		add     di,320
		add     si,320
		loop    DispChar
		pop     si
		pop     di
		pop     es
		pop     ds
		inc     cs:[InsideChar]
		cmp     cs:[InsideChar],7
		ja      ResetInside
		ret
ResetInside:    mov     cs:[InsideChar],0
		ret
PrintChar       ENDP
MsgCounter      dw      0
MsgLength       dw      0
GotLength       db      0
InsideChar      dw      0
DisplayMsg      PROC    NEAR
                cmp     cs:[Int8Counter],1
		ja      DisplayMsg2
		ret
DisplayMsg2:    xor     eax,eax
		mov     cs:[Int8Counter],eax
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
                shl     ax,3
		mov     bx,[FontPos2]
		pop     cx
		call    PrintChar
		cmp     cs:[InsideChar],1
		jae     SkipPrintSmall
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Sinus Scroller Routine
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Scroller        PROC    NEAR
		mov     ax,MAINSEGD             ;
		mov     ds,ax                   ;
		cmp     [FontSlice],0           ;
		jne     ProcessChar             ;
NewChar:        mov     bx,[ScrollPointer]      ; Get index into scrolltext
		lea     di,ScrollText           ; DI points to start of text
		mov     al,ds:[di+bx]           ; Get Char to scroll
                cmp     al,255                  ; Is it a wrap around signal?
		je      ResetScrollPointer      ;
                cmp     al,10                   ; Is it the scroll speed?
		jb      ScrollerSpeed           ;
		lea     si,CharSet              ; 
		xor     bx,bx                   ;
GetChar:        mov     ah,ds:[si+bx]           ; Check for valid char
		cmp     ah,al                   ;
		je      GotChar                 ;
		inc     bx                      ;
                and     ah,ah                   ; Did we get a valid char?
		jz      BadChar                 ;
		jmp     GetChar                 ;
ResetScrollPointer:                             ;
		mov     [ScrollPointer],0       ; Reset to start of text
		jmp     NewChar                 ; Start again
UpDatePointer:  inc     [ScrollPointer]         ; Point to next char
		jmp     NewChar                 ; Start again
ScrollerSpeed:  xor     ah,ah                   ;
		cmp     ax,9
		je      ToggleDir
		mov     [ScrollSpeed],ax        ;
		inc     [ScrollPointer]         ;
		jmp     NewChar                 ;
ToggleDir:      xor     [ScreenPos],1           ;
		inc     [ScrollPointer]
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Display scroll text over background. No MASK!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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
DisplaySlice:   lodsb
                dec     si
		mov     ah,al
                stosw
                dec     di
                dec     di
                add     di,320
                stosw
                dec     di
                dec     di
		add     di,320
		add     si,320
		dec     cx
		jnz     DisplaySlice
		inc     bp
		cmp     bp,360
                jb      OldBP
NewBP:          xor     bp,bp
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
		ret
DisplayScroll   ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Screen retrace
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Retrace         PROC    NEAR
                cli
		mov     dx,3dah
Sync:           in      al,dx
		and     al,8
		jnz     Sync                                
Retr:           in      al,dx
		and     al,8
		jz      Retr
                sti
		ret
Retrace         ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; New interrupt 8 handler to generate a counter which should count roughly
; the same speed on all speeds of computers
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Int8Counter     dd      0
MusicCounter    dd      0
OldInt8         dd      0
Int8            PROC    FAR
                cli
                push    eax
                push    ebx
                push    ecx
                push    edx
                push    es
                push    ds
                push    si
                push    di
                push    ebp
                pushf

                inc     cs:[Int8Counter]
                ;inc     cs:[MusicCounter]
                ;cmp     cs:[MusicCounter],70 ;80
                ;jb      SkipMPlay
                ;call    A_dorow
SkipMplay:
		MOV     AL,20H       ;inform processor : interrupt finished.
		OUT     20H,AL
		popf
                pop     ebp
                pop     di
                pop     si
                pop     ds
                pop     es
                pop     edx
                pop     ecx
                pop     ebx
		pop     eax
                sti
		iret
Int8            ENDP
Int8On          PROC    NEAR
		push    ds
		mov     ax,3508h
		int     21h
		mov     word ptr cs:[OldInt8+2],es
		mov     word ptr cs:[OldInt8],bx
		mov     ax,cs
		mov     ds,ax
		lea     dx,Int8
		mov     ax,2508h
		int     21h
		pop     ds
		cli
		mov     cs:[Int8Counter],0

		; Set frequency back to default 100
		mov     al,00110110b
		out     43h,al
		jmp     $+2
                mov     cx,11931
		mov     al,cl
		out     40h,al
		jmp     $+2
		mov     al,ch
		out     40h,al
		jmp     $+2
		sti

		ret
Int8On          ENDP
Int8Off         PROC    NEAR
		push    ds
		mov     ax,word ptr cs:[OldInt8+2]
		mov     ds,ax
		mov     dx,word ptr cs:[OldInt8]
		mov     ax,2508h
		int     21h
		pop     ds

		; Set frequency back to default 18.2
		cli
		mov     al,00110110b
		out     43h,al
		jmp     $+2
		mov     al,0
		out     40h,al
		jmp     $+2
		out     40h,al
		jmp     $+2
		sti
		ret
Int8Off         ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Sets VGA colour palette
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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
                mov     cs:[Red],12      ;12
                mov     cs:[Green],32    ;32
                mov     cs:[Blue],62     ;62
SetPEL3:        mov     al,cs:[Red]
		out     dx,al
		mov     al,cs:[Green]
		out     dx,al
		mov     al,cs:[Blue]
		out     dx,al
                sub     cs:[Blue],3
		loop    SetPEL3
		ret
SetPalette      ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Screen flash
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Flash           PROC    NEAR
                xor     bl,bl
		mov     cx,62
@@FlashLoop:    xor     al,al
                mov     dx,3c8h
                out     dx,al
                inc     dx
                mov     al,bl
                out     dx,al
                out     dx,al
                out     dx,al
                inc     bl
                mov     dx,3dah
@@Sync:         in      al,dx
                and     al,8
                jz      @@Sync
                push    cx
                mov     cx,0ffffh
                loop    $
                pop     cx
                loop    @@FlashLoop
		mov     cx,62
@@FlashLoop2:   xor     al,al
                mov     dx,3c8h
                out     dx,al
                inc     dx
                mov     al,bl
                out     dx,al
                out     dx,al
                out     dx,al
                dec     bl
                mov     dx,3dah
@@Sync2:        in      al,dx
                and     al,8
                jz      @@Sync2
                push    cx
                mov     cx,0ffffh
                loop    $
                pop     cx
                loop    @@FlashLoop2
		ret
Flash           ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Fade out screen
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Check for user exit
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Shutdown, cleans up computer and exits cleanly!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ShutDown        PROC    NEAR
		mov     ax,3
		int     10h
		mov     ax,[FontSeg]
		call    FreeMem
                mov     ax,[ScreenSeg]
                call    FreeMem
                mov     ax,[FireSeg]
                call    FreeMem
		mov     ax,MAINSEGD
                call    RemoveDebugger
		mov     ah,4ch
		int     21h
ShutDown        ENDP


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Display the virtual screen
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DisplayVirtual  PROC    NEAR                
		push    ds
		push    es
                push    cx
		mov     ax,cs:[ScreenSeg]
		mov     ds,ax
		xor     si,si
		xor     di,di
		mov     ax,0A000h
		mov     es,ax
                mov     cx,64000 / 4
@@DV:           mov     eax,ds:[si]
                mov     es:[di],eax
                add     si,4
                add     di,4
                dec     cx
                jnz     @@DV
                pop     cx
		pop     es
		pop     ds
		ret
DisplayVirtual  ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Main body of program, execution starts here.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Main            PROC
                call    Check386                ; Check for 386 or above CPU
                mov     cl,4                    ; Amount to shift
                mov     ax,ss                   ; Get stack segment
                mov     ds,ax                   ; Setup DS
                lea     dx,TopOfStack           ; Get offset of top of stack
                shr     dx,cl                   ;
                add     ax,dx                   ; SS+DX = 20bit address
                mov     bx,ax                   ;
                mov     ax,MAINSEG              ; Get main code segment
                mov     ds,ax                   ; Setup DS
                lea     dx,Start                ; Get offset of start of prog
                shr     dx,cl
                add     ax,dx                   ; CS+DX = 20bit address
                sub     bx,ax                   ; Get difference
                add     bx,20h                  ; Add size of PSP
                mov     ah,4ah                  ;
                int     21h                     ;
                mov     ax,MAINSEGD             ;
                mov     ds,ax                   ;
                call    InstallDebugger
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
                xor     bx,bx
                xor     bp,bp
                mov     cx,200
@@Make320Table: mov     ax,bx
                imul    ax,320
                mov     [ds:_320Table+bp],ax
                add     bp,2
                inc     bx
                loop    @@Make320Table

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
                mov     dx,3C2h
                mov     al,0E3h
                out     dx,al

                setborder 5

		call    Int8On
		call    Flash
		call    SetPalette

		call    AllocMem
		mov     [LogoSeg],ax
		mov     bx,[Logo1DataSize]      ;
		lea     si,Logo1Data            ;
		mov     es,ax                   ;
		xor     di,di                   ;
		call    Decompress              ; Decompress font data


                ;call    a_init                  ; Initalise Adlib

;훁croll Logo up screen over starfield컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		mov     bp,200
ScrollUpLoop:   
		push    bp

		pop     bp
		push    bp

                mov     di,bp
                mov     dx,bp
                mov     dh,dl
                xor     dl,dl
                shl     di,6
                add     di,dx
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

                call    Retrace
                call    DisplayVirtual

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
                mov     [FireSeg],ax
		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars

                mov     ax,[FireSeg]
                mov     es,ax
                xor     di,di
                xor     eax,eax
                mov     cx,64000 / 4
                repz    stosd


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

		mov     [ScrollPointer],0
		mov     [ScrollSpeed],1
                mov     cs:[FrameCount],0

ScrollLoop:     ;mov     dx,3c8h
                ;mov     al,0
                ;out     dx,al
                ;inc     dx
                ;mov     al,63
                ;out     dx,al
                ;out     dx,al
                ;out     dx,al

		call    CheckExit
		jc      ExitScroll
		call    DisplayMsg

		call    Scroller
		call    DisplayScroll

		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars
                call    Retrace
                call    DisplayVirtual

		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars

                ;mov     dx,3c8h
                ;mov     al,0
                ;out     dx,al
                ;inc     dx
                ;mov     al,63
                ;out     dx,al
                ;mov     al,0
                ;out     dx,al
                ;out     dx,al

		call    DisplayMsg

		call    Scroller
		call    DisplayScroll

		lea     si,StarPos
		mov     cx,[NumStars]
		call    DisplayStars
                call    Retrace
                call    DisplayVirtual

		lea     si,StarPos
		mov     cx,[NumStars]
		call    EraseStars

		jmp     ScrollLoop

ExitScroll:     ;call    a_init                  ; De-Initalise adlib
                call    Int8Off
		call    FadeOut
		call    Shutdown

Main            ENDP
MAINSEG         ENDS


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Stack segemt, reserved 1025bytes for stack
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STACKSEG        SEGMENT USE16 PARA STACK 'STACK'
		db      1024 dup('S')
TopOfStack      db      0                       ; Used to calculate prog size
STACKSEG        ENDS

		END     START
