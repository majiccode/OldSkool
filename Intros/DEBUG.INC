컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Simple runtime debugging for your programs. This routine will make sure 
; that if any invalid opcodes occur of divide overflows etc then the address
; at which they occur is displayed along with any registers. It will also
; exit cleanly restoring the correct video mode and restore any allocated
; memory if used.
;
; InstallDebugger - Installs the debugger
;  RemoveDebugger - Removes the debugger
;
; (c)1995 Paul Adams, Matrix Design
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OldInt6         dd      0               ; Invalid opcode
OldInt0         dd      0               ; divide by zero
OldInt4         dd      0               ; divide overflow?
OldInt21        dd      0               ; Allocated Memory
CrashMsg        db      13,10,13,10,13,10,13,10,13,10
                db      '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴',13,10
                db      ' An error has occured during the running of this program. Please report this',13,10
                db      ' error with details on what you did and all the information shown below:-',13,10,13,10,'$'
InvalidOpMsg    db      ' Invalid OpCode encountered at address $'
DivideZMsg      db      ' Divide by Zero encountered at address $'
DivideOMsg      db      ' Divide Overflow encountered at address $' 
CrashAddress    db      'xxxx:xxxxh',13,10,13,10,'$'
Registers       db      ' AX = '
vAXr            db      'xxxx'
                db      ' BX = '
vBXr            db      'xxxx'
                db      ' CX = '
vCXr            db      'xxxx'
                db      ' DX = '
vDXr            db      'xxxx'
                db      13,10
                db      ' DS = '
vDSr            db      'xxxx'
                db      ' ES = '
vESr            db      'xxxx'
                db      ' SS = '
vSSr            db      'xxxx'
                db      ' FS = '
vFSr            db      'xxxx'
                db      13,10
                db      ' SP = '
vSPr            db      'xxxx'
                db      ' BP = '
vBPr            db      'xxxx'
                db      ' DI = '
vDIr            db      'xxxx'
                db      ' SI = '
vSIr            db      'xxxx'
                db      13,10
                db      ' FLAGS = '
vFlagsr         db      '           ',13,10
                db      '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴',13,10
                db      13,10,13,10,13,10,13,10,13,10,13,10,13,10,'$'
DebugInstalled  db      0
MemoryHeap      dw      10 dup(0)
HeapPointer     dw      0
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Debugger routine
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Debugger        PROC    NEAR
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    fs
                push    di
                push    si
                push    bp
                pushf

                mov     ax,3
                int     10h
                mov     ax,cs
                mov     ds,ax
                lea     dx,CrashMsg
                mov     ah,9
                int     21h
                lea     dx,InvalidOpMsg
                mov     ah,9
                int     21h
                mov     bp,sp

DisplayDBGInfo: lea     di,CrashAddress
                add     bp,22
                mov     cx,4
                add     bp,3
@@ConvertToText:mov     al,[bp]
                xor     ah,ah
                push    ax
                shl     ax,4
                xor     ah,ah
                shr     ax,4
                cmp     al,9
                ja      @@Letter1
                add     al,48
                jmp     @@HighNibble
@@Letter1:      sub     al,0ah
                add     al,65
@@HighNibble:   mov     cs:[di+1],al
                pop     ax
                shr     ax,4
                cmp     al,9
                ja      @@Letter2
                add     al,48
                jmp     @@DoneConvert
@@Letter2:      sub     al,0ah
                add     al,65
@@DoneConvert:  mov     cs:[di],al

                inc     di
                inc     di
                dec     bp
                cmp     cx,3
                jne     @@NoColon
                inc     di
@@NoColon:
                loop    @@ConvertToText

                lea     dx,CrashAddress
                mov     ah,9
                int     21h
                popf
                pop     bp
                pop     si
                pop     di
                pop     fs
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                push    ax
                mov     ax,cs
                mov     ds,ax
                pop     ax
                lea     si,vAXr
                call    @@ConvertReg
                mov     ax,bx
                lea     si,vBXr
                call    @@ConvertReg
                mov     ax,cx
                lea     si,vCXr
                call    @@ConvertReg
                mov     ax,dx
                lea     si,vDXr
                call    @@ConvertReg
                mov     ax,es
                lea     si,vESr
                call    @@ConvertReg
                mov     ax,ds
                lea     si,vDSr
                call    @@ConvertReg
                mov     ax,FS
                lea     si,vFSr
                call    @@ConvertReg
                mov     ax,di
                lea     si,vDIr
                call    @@ConvertReg
                mov     ax,SI
                lea     si,vSIr
                call    @@ConvertReg
                mov     ax,bp
                lea     si,vBPr
                call    @@ConvertReg
                mov     ax,sp
                lea     si,vSPr
                call    @@ConvertReg
                mov     ax,SS
                lea     si,vSSr
                call    @@ConvertReg

                lea     dx,Registers
                mov     ah,9
                int     21h


                ; Free any allocated memory if used
                ;mov     cs:[DebugFreeMem],1
                ;mov     ax,cs:[MemoryHeap]
                ;or      ax,ax
                ;jz      @@NoMemUsed
                ;mov     cx,cs:[HeapPointer]
@@FreeMem:      ;mov     bp,cx
                ;dec     bp
                ;shl     bp,1
                ;mov     ax,cs:[MemoryHeap+bp]
                ;push    cx
                ;mov     es,ax
                ;mov     ah,49h
                ;int     21h
                ;pop     cx
                ;jc      @@NoMemUsed
                ;loop    @@FreeMem
@@NoMemUsed:
                ;mov     cs:[DebugFreeMem],0

                mov     al,20h
                out     20h,al

                mov     ah,4ch
                int     21h
                iret

; Coverts contents of registers to ascii string
; AX    = Register contents
; DS:SI = Place to store ascii string
@@ConvertReg:   push    ax
                xchg    al,ah
                xor     ah,ah
                shr     ax,4    ; Get high nibble
                cmp     ax,9
                ja      @@GotLetter
                add     al,48
                jmp     @@StoreChar1
@@GotLetter:    sub     al,0ah
                add     al,65
@@StoreChar1:   mov     ds:[si],al
                pop     ax
                push    ax
                xchg    al,ah
                xor     ah,ah
                shl     ax,4
                xor     ah,ah
                shr     ax,4
                cmp     ax,9
                ja      @@GotLetter2
                add     al,48
                jmp     @@StoreChar2
@@GotLetter2:   sub     al,0ah
                add     al,65
@@StoreChar2:   mov     ds:[si+1],al
                pop     ax
                push    ax
                xor     ah,ah
                shr     ax,4    ; Get high nibble
                cmp     ax,9
                ja      @@GotLetter3
                add     al,48
                jmp     @@StoreChar3
@@GotLetter3:   sub     al,0ah
                add     al,65
@@StoreChar3:   mov     ds:[si+2],al
                pop     ax
                xor     ah,ah
                shl     ax,4
                xor     ah,ah
                shr     ax,4
                cmp     ax,9
                ja      @@GotLetter4
                add     al,48
                jmp     @@StoreChar4
@@GotLetter4:   sub     al,0ah
                add     al,65
@@StoreChar4:   mov     ds:[si+3],al
                ret
Debugger        ENDP

Debugger0       PROC    NEAR
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    fs
                push    di
                push    si
                push    bp
                pushf
                mov     ax,3
                int     10h
                mov     ax,cs
                mov     ds,ax
                lea     dx,CrashMsg
                mov     ah,9
                int     21h
                lea     dx,DivideZMsg
                mov     ah,9
                int     21h
                mov     bp,sp
                call    DisplayDBGInfo
Debugger0       ENDP

Debugger4       PROC    NEAR
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    fs
                push    di
                push    si
                push    bp
                pushf
                mov     ax,3
                int     10h
                mov     ax,cs
                mov     ds,ax
                lea     dx,CrashMsg
                mov     ah,9
                int     21h
                lea     dx,DivideOMsg
                mov     ah,9
                int     21h
                mov     bp,sp
                call    DisplayDBGInfo
Debugger4       ENDP

DebugFreeMem    db      0
Debugger21      PROC    NEAR
                cmp     ah,48h
                jne     @@NoAlloc
                push    cs
                call    cs:OldInt21
                push    bx
                mov     bx,cs:[HeapPointer]
                shl     bx,1
                mov     cs:[MemoryHeap+bx],ax
                inc     cs:[HeapPointer]
                pop     bx
                iret
@@NoAlloc:      cmp     ah,49h
                je      @@FreeIt
@@NoAlloc2:     jmp     cs:OldInt21
                iret
@@FreeIt:       cmp     cs:[DebugFreeMem],1
                je      @@NoAlloc2
                dec     cs:[HeapPointer]
                jmp     @@NoAlloc2
Debugger21      ENDP


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; InstallDebugger, Installs the debugger so it is active!
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InstallDebugger PROC    NEAR
                push    ds
                push    es
                cmp     cs:[DebugInstalled],1
                je      @@AlreadyThere
                mov     cs:[DebugInstalled],1
                mov     ax,3506h
                int     21h
                mov     word ptr cs:[OldInt6+2],es
                mov     word ptr cs:[OldInt6],bx
                mov     ax,cs
                mov     ds,ax
                lea     dx,Debugger
                mov     ax,2506h
                int     21h
                mov     ax,3500h
                int     21h
                mov     word ptr cs:[OldInt0+2],es
                mov     word ptr cs:[OldInt0],bx
                mov     ax,cs
                mov     ds,ax
                lea     dx,Debugger0
                mov     ax,2500h
                int     21h
                mov     ax,3504h
                int     21h
                mov     word ptr cs:[OldInt4+2],es
                mov     word ptr cs:[OldInt4],bx
                mov     ax,cs
                mov     ds,ax
                lea     dx,Debugger4
                mov     ax,2504h
                int     21h
                ;mov     ax,3521h
                ;int     21h
                ;mov     word ptr cs:[OldInt21+2],es
                ;mov     word ptr cs:[OldInt21],bx
                ;mov     ax,cs
                ;mov     ds,ax
                ;lea     dx,Debugger21
                ;mov     ax,2521h
                ;int     21h
@@AlreadyThere: pop     es
                pop     ds
                ret
InstallDebugger ENDP

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; RemoveDebugger, de-activates debugger
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RemoveDebugger  PROC    NEAR
                cmp     cs:[DebugInstalled],1
                jne     @@NotThere
                push    ds
                mov     ax,2506h
                mov     bx,word ptr cs:[OldInt6+2]
                mov     ds,bx
                mov     dx,word ptr cs:[OldInt6]
                int     21h
                mov     ax,2500h
                mov     bx,word ptr cs:[OldInt0+2]
                mov     ds,bx
                mov     dx,word ptr cs:[OldInt0]
                int     21h
                mov     ax,2504h
                mov     bx,word ptr cs:[OldInt4+2]
                mov     ds,bx
                mov     dx,word ptr cs:[OldInt4]
                int     21h
                ;mov     ax,2521h
                ;mov     bx,word ptr cs:[OldInt21+2]
                ;mov     ds,bx
                ;mov     dx,word ptr cs:[OldInt21]
                ;int     21h
                pop     ds
                mov     cs:[DebugInstalled],0
@@NotThere:     ret
RemoveDebugger  ENDP

db              'Code Monitor v1 (c)1995 Paul Adams, Matrix Design'
