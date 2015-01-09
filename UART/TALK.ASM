;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; UART Test Program
;
;
; (c)1995 Matrix Design, Paul Adams
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


                call    Start

; *** Registers ***
RxD             dw      3f8h
TxD             dw      3f8h
IeR             dw      3f9h
IiR             dw      3fah
LcR             dw      3fbh
McR             dw      3fch
LsR             dw      3fdh

Bauds           db      96,48,24,12,6,1         ;

Connect         db      2

; Screen And Colour Varibles
VideoBuffer     dw      0B800h
ScreenWidth     dw      80
ScreenHeight    dw      24
TextColour      db      11

WaitMsg         db      ' Waiting for other Computer ',0
FoundMsg        db      '                            ',0
BaudRate        db      '115200',0
Parity          db      'Even',0
ByeMsg          db      ' Test Program by Paul Adams',13,10,13,10,'$'
OutX            dw      0
OutY            dw      0
InX             dw      0
InY             dw      0
;----------------------------------------------------------------------------
; Print String Function 
;
; Call: AX=X, BX=Y, CL=ForeColour, CH=BackColour DS:DX = String
;----------------------------------------------------------------------------
X               dw      0
Y               dw      0
TextAddr        dw      0
TextAddr2       dw      0       
ForeColour      db      0
BackColour      db      0
Print:          mov     cl,cs:b[TextColour]
                mov     ch,0
                mov     ds,cs
                mov     es,cs:w[VideoBuffer]
                push    dx
                mov     di,dx
                mov     cs:w[X],ax
                mov     cs:w[Y],bx
                mov     cs:b[ForeColour],cl
                mov     cs:b[BackColour],ch
                mov     ax,cs:w[Y]
                mov     cx,160
                mul     cx
                mov     bx,cs:w[X]
                shl     bx,1
                add     ax,bx
                mov     si,ax
                mov     cs:w[TextAddr],si
                mov     cs:w[TextAddr2],si
Print1:         mov     al,ds:[di]
                cmp     al,0
                je      SetColour
                cmp     al,13
                je      Return
                mov     es:[si],al                               
                inc     si
                inc     si
                inc     di
                jmp     Print1
Return:         inc     di
                mov     ax,cs:w[TextAddr]
                mov     cx,cs:w[ScreenWidth]
                shl     cx,1
                add     ax,cx
                mov     si,ax
                mov     cs:w[TextAddr],si
                jmp     Print1
SetColour:      pop     dx
                mov     di,dx
                mov     si,cs:w[TextAddr2]
                inc     si
                mov     cs:w[TextAddr],si
                mov     al,cs:b[BackColour]
                mov     ah,0
                mov     cx,16
                mul     cx
                mov     ah,al
                add     ah,cs:b[ForeColour]
SetColourLoop:  mov     al,ds:[di]
                cmp     al,0
                je      EndPrint
                cmp     al,13
                je      Return2
                mov     es:[si],ah
                inc     si
                inc     si
                inc     di
                jmp     SetColourLoop
EndPrint:       ret
Return2:        inc     di
                mov     dx,cs:w[TextAddr]
                mov     cx,cs:w[ScreenWidth]                
                shl     cx,1
                add     dx,cx
                mov     si,dx
                mov     cs:w[TextAddr],si
                jmp     SetColourLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Set cursor Position
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetCursor:      mov     dh,bl
                mov     dl,al
                mov     ah,2
                mov     bh,0
                int     10h
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write char to screen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WriteChar:      mov     ah,0ah
                mov     bh,0
                mov     bl,cs:b[TextColour]
                mov     cx,1
                int     10h
                ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Initalise the UART
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
OldInt          dd      0
IntHandler:     push    ax
                push    bx
                push    cx
                push    dx

                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     cs:OldInt
                iret
InitUART:
                mov     ds,cs
                mov     ax,350ch
                int     21h
                mov     cs:w[OldInt],bx
                mov     cs:w[OldInt+2],es
                mov     ax,250ch
                mov     ds,cs
                lea     dx,IntHandler
                int     21h

                mov     dx,cs:w[LcR]    ; Line Control Register
                mov     al,1bh          ; 8e1
                out     dx,al
                mov     dx,cs:w[McR]    ; Modem Control Register
                in      al,dx
                or      al,8
                out     dx,al
                mov     dx,cs:w[IeR]
                mov     al,3
                out     dx,al
                in      al,21h
                and     al,24
                out     dx,al
                sti
                ret                     ;

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Set BAUD rate
; Call: AL - 1 = 1200  4 = 9600         
;            2 = 2400  5 = 19200         
;            3 = 4800  6 = 115200       
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetBAUD:        mov     bx,ax
                mov     dx,cs:w[LcR]    ; Line Control Register
                in      al,dx           ; Get control byte
                push    ax
                or      al,128          ; Turn on bit 7, sets DLAB
                out     dx,al
                mov     dx,cs:w[TxD]
                xor     bh,bh
                dec     bx
                mov     al,cs:b[Bauds+bx]
                out     dx,al
                add     dx,3
                pop     ax
                out     dx,al
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Transmitts a single character to other computer
; Call: AL - Char to send
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Transmit:       push    ax              ;
NotEmpty:       mov     dx,cs:w[LsR]    ; Line status register
                in      al,dx           ; Get status
                and     al,32           ; Any char?
                jz      NotEmpty        ; Yes, So try again
                pop     ax              ;
                mov     dx,cs:w[TxD]    ;
                out     dx,al           ; Send character
                ret                     ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Transmitts a block of data to other computer
; Call: DS:SI - point to block of data
;       CX    - contains number of bytes to send
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TransmitBlock:  push    ax
                push    dx
                cld                     ; Make sure we go in right direction
BlockSend:      lodsb
                mov     dx,cs:w[LsR]    ; Line Status Register
                push    ax
BlockWait:      in      al,dx           ; Get Status
                and     al,32           ; Have we sent a char yet?
                jz      BlockWait       ; No, So keep on waiting
                mov     dx,cs:w[TxD]    ; 
                pop     ax              ;
                out     dx,al           ; Send byte 
                loop    BlockSend       ; Do again until all bytes sent
                pop     dx
                pop     ax
                ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Receives a character from other computer
; Return: AL  - Char received
;         CF  - Set if no char is present
; ErrorStatus - Flag contains Error number
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Receive:        mov     dx,cs:w[LsR]    ; Line Status Register
                in      al,dx           ; Get status
                mov     bl,al
                and     al,1fh          ; Any data in receive buffer? or Errors
                jz      NoCharWaiting   ; No, so skip it!
                and     bl,30           ; Any errors occur?
                jnz     RErrors         ;
                mov     dx,cs:w[RxD]    ;
                in      al,dx           ; Get char waiting
                clc                     ;
                ret                     ;
NoCharWaiting:  stc                     ; Set carry to signal no char
                ret                     ;
RErrors:        ret

ReceiveBlock:   
RBlock:         push    cx
                call    Receive
                pop     cx
                jc      RBlock
                dec     cx
                push    cx
                mov     ah,02h
                mov     dl,al
                int     21h
                pop     cx
                loop    RBlock
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Sync computers by making sure they are both ready
; Return:  CF set if no one their!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SyncProgress    db      0
SyncCOMMS:      cmp     cs:b[SyncProgress],1
                je      SyncAgain
                mov     cs:b[SyncProgress],1
                mov     al,cs:b[Connect] ; Send connect signal to other
                call    Transmit         ; computer
SyncAgain:      mov     ah,1
                int     16h
                jnz     EndSync
                call    Receive          ; See if other computer is their
                cmp     al,cs:b[Connect]
                jne     SyncAgain
                mov     cs:b[SyncProgress],0
FlushPort:      call    Receive
                jnc     FlushPort
                clc
                ret
EndSync:        stc
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Display screen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DisplayScreen:  mov     cx,cs:w[ImageData_Length]
                mov     es,0b800h
                xor     di,di
                mov     ds,cs
                lea     si,IMAGEDATA
                call    Uncrunch
                mov     ds,cs
                lea     dx,BaudRate
                mov     ax,9
                mov     bx,23
                call    Print
                mov     ds,cs
                lea     dx,Parity
                mov     ax,25
                mov     bx,23
                call    Print
                mov     ax,5
                mov     bx,13
                call    SetCursor
                ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Handle output a char to other computer and onto screen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExitTerminal:   mov     al,ah
                call    Transmit
                call    QuickExit
OutDelete:      mov     al,ah
                call    Transmit
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                mov     al,' '
                call    WriteChar
                cmp     cs:w[OutX],6
                jb      SkipODMove
                dec     cs:w[OutX]
SkipODMove:     ret
OutputChar:     mov     ax,0
                int     16h
                cmp     ah,1ch               ; Enter?
                je      OutNextLine
                cmp     ah,1                 ; ESC?
                je      ExitTerminal
                cmp     ah,0eh               ; Backspace?
                je      OutDelete
                jmp     DoOutput
OutNextLine:    mov     al,ah
                call    Transmit
                mov     cs:w[OutX],5
                inc     cs:w[OutY]
                cmp     cs:w[OutY],10
                ja      OutSup2
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                ret      
OutSup2:        mov     ah,6
                mov     al,1
                mov     bh,15
                mov     ch,3
                mov     cl,5
                mov     dh,10
                mov     dl,75
                int     10h
                dec     cs:w[OutY]
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                ret                
DoOutput:       push    ax
                call    Transmit
                pop     ax
                cmp     cs:w[OutY],10
                ja      OutSup
                inc     cs:w[OutX]
                cmp     cs:w[OutX],75
                ja      OutNewLine
                push    ax
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret
OutNewLine:     mov     cs:w[OutX],5
                inc     cs:w[OutY]
                cmp     cs:w[OutY],10
                ja      OutSUp
                push    ax
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret
OutSUp:         push    ax
                mov     ah,6
                mov     al,1
                mov     bh,15
                mov     ch,3
                mov     cl,5
                mov     dh,10
                mov     dl,75
                int     10h
                dec     cs:w[OutY]
                mov     ax,cs:w[OutX]
                mov     bx,cs:w[OutY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Input char
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExitTerminal2:  call    QuickExit
InDelete:       mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                mov     al,' '
                call    WriteChar
                cmp     cs:w[InX],6
                jb      SkipIDMove
                dec     cs:w[InX]
SkipIDMove:     ret

InputChar:      cmp     al,1ch               ; Enter?
                je      InNextLine
                cmp     al,1                 ; ESC?
                je      ExitTerminal2
                cmp     al,0eh               ; Backspace?
                je      InDelete
                jmp     DoInput
InNextLine:     mov     cs:w[InX],5
                inc     cs:w[InY]
                cmp     cs:w[InY],20
                ja      InSup2
                mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                ret      
InSup2:         mov     ah,6
                mov     al,1
                mov     bh,15
                mov     ch,13
                mov     cl,5
                mov     dh,20
                mov     dl,75
                int     10h
                dec     cs:w[InY]
                mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                ret                
Doinput:        cmp     cs:w[InY],20
                ja      InSup
                inc     cs:w[InX]
                cmp     cs:w[InX],75
                ja      InNewLine
                push    ax
                mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret
InNewLine:      mov     cs:w[InX],5
                inc     cs:w[InY]
                cmp     cs:w[InY],20
                ja      InSUp
                push    ax
                mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret
InSUp:          push    ax
                mov     ah,6
                mov     al,1
                mov     bh,15
                mov     ch,13
                mov     cl,5
                mov     dh,20
                mov     dl,75
                int     10h
                dec     cs:w[InY]
                mov     ax,cs:w[InX]
                mov     bx,cs:w[InY]
                call    SetCursor
                pop     ax
                call    WriteChar
                ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Do Terminal
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DoTerminal:     mov     ah,1
                int     16h
                jz      NoChar
                call    OutPutChar

NoChar:         call    Receive
                jc      DoTerminal
                call    InputChar
                jmp     DoTerminal
                ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Start of program. Execution starts here
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Start:          mov     ax,3
                int     10h
                call    InitUART
                mov     al,6
                call    SetBAUD

                               
                call    DisplayScreen

                mov     ax,25
                mov     bx,7
                mov     ds,cs
                lea     dx,WaitMsg
                call    Print

                ;call    SyncCOMMS
                ;jc      QuickExit

                mov     ax,25
                mov     bx,7
                mov     ds,cs
                lea     dx,FoundMsg
                call    Print

                mov     cs:w[OutX],5
                mov     cs:w[OutY],3
                mov     cs:w[InX],5
                mov     cs:w[InY],13
                call    DoTerminal

QuickExit:      mov     ax,3
                int     10h
                mov     ds,cs
                lea     dx,ByeMsg
                mov     ah,9
                int     21h
                mov     ah,4ch
                int     21h
