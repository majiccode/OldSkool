    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;                             TúeúSúkúO
    ;                small BBS advert for South Central
    ;                           code: Frenzy
    ;
    ; i did this in a one night coding session.. the idea was to do it in
    ; less that 2k. i have got this down below 2k but it can go down further.
    ; the fire routine is actually 100x320 but i doubled the y resolution
    ; to make it fill the screen. i think all fire plasma's should fill
    ; the screen :-) the text writer is not a big deal, its just that i check
    ; the colour beneath to see if i should draw it. the frame counting is
    ; done by int 8 and that is reprogrammed to go off at 70hz which is
    ; the frequency of the vga card (i think).
    ;
    ; Paul aka Frenzy - p.adams@wlv.ac.uk
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        .MODEL small
        .386
         IDEAL
         LOCALS
         
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Main code segment for COM file
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGMENT MAIN_CS DWORD PUBLIC 'CODE'
        ASSUME CS:MAIN_CS, DS:MAIN_CS, SS:MAIN_CS
        ORG 100h
Start:  call    Main                    

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; AllocMem
    ;
    ; Output: AX = Segment
    ;
    ; Just allocates 64k of memory
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC AllocMem
        mov     bx,1000h                ; Resize allocated memory
        mov     ah,4Ah                  ;
        int     21h                     ;
        mov     bx,1000h                ; Allocate memory
        mov     ah,48h                  ;
        int     21h                     ;
        jc      AllocError              ; Did error occur?
        push    ax                      ;
        mov     es,ax                   ; Clear allocated memory
        xor     di,di                   ; 
        xor     eax,eax                 ;
        mov     cx,64000 / 4            ;
        repz    stosd                   ;
        pop     ax                      ;
        ret                             ; No, so return!
AllocError:
        lea     dx,[LammerNoMem]        ; Display error message
        mov     ah,9                    ;
        int     21h                     ;
        jmp     QuickExit               ;
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; FreeMem
    ;
    ; Input: AX = Segment
    ;
    ; Just allocates 64k of memory
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC FreeMem
        mov     es,ax
        mov     ah,49h
        int     21h
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Retrace
    ;
    ; Waits for verticle retrace
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Retrace
        mov     dx,3DAh
@@Retr1:in      al,dx
        and     al,8
        jnz     @@Retr1
@@Retr2:in      al,dx
        and     al,8
        jz      @@Retr2
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; DisplayScreen
    ;
    ; Displays the virtual page
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC DisplayScreen
        push    ds
        mov     ax,[ScreenSeg]
        mov     ds,ax
        mov     ax,0A000h
        mov     es,ax
        xor     di,di
        xor     si,si
        mov     cx,64000 / 8
;        repz    movsd
@@l1:   fld     [qword ptr si]
        fstp    [qword ptr es:di]
        add     di,8
        add     si,8
        dec     cx
        jnz     @@l1
        pop     ds
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Randomize: generates the seed
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Randomize
        xor     ah,ah
        int     1ah
        mov     [Seed],dx               ; Get random seed from clock
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ;  Random: generates random number
    ;  Input : cx = range
    ;  Output: cx = random number
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Random
        mov     ax,[Seed]
        add     ax,1234
        xor     al,ah
        rol     ah,1            
        add     ax,4321
        ror     al,2                   
        xor     ah,al
        mov     [Seed],ax
        xor     dx,dx
        div     cx
        mov     cx,dx
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; SetPalette
    ;
    ; Sets the intro's palette. Looks complex huh? :)) Its just to save
    ; having a 768 byte buffer. A prestored palette takes so much space :)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC SetPalette
        mov     dx,3C8h
        mov     al,1
        out     dx,al
        inc     dx
        xor     cl,cl
@@l0:   mov     al,cl
        out     dx,al
        xor     al,al
        out     dx,al
        out     dx,al
        inc     cl
        cmp     cl,31
        jb      @@l0
        xor     cl,cl
@@l1:   mov     al,cl
        shr     al,1
        add     al,32
        out     dx,al
        mov     al,cl
        out     dx,al
        xor     al,al
        out     dx,al
        inc     cl
        cmp     cl,63
        jb      @@l1
        xor     cl,cl
@@l2:   mov     al,63
        out     dx,al
        out     dx,al
        mov     al,cl
        shl     al,1
        out     dx,al
        inc     cl
        cmp     cl,31
        jb      @@l2
        mov     ah,cl
        shl     ah,1
        mov     cx,255-125
@@l3:   mov     al,63
        out     dx,al
        out     dx,al
        mov     al,ah
        out     dx,al
        loop    @@l3
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Grab font from BIOS
    ;
    ; Idea is to grab the 8x8 font from the bios so we don't need to store
    ; a pre-drawn one in our code. 8x8 looks naff but thats the price you
    ; pay for size :)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC GrabFont NEAR
        lea     si,[FontTbl]
        lea     di,[FontData]
        mov     ax,0A000h
        mov     es,ax
@@GrabFont:
        mov     al,[si]
        cmp     al,0FFh
        je      @@Done
        mov     ah,0Ah
        mov     bx,1
        mov     cx,1
        int     10h
        xor     bx,bx
        mov     cx,8
@@CopyFont:
        mov     eax,[es:bx]
        mov     [ds:di],eax
        mov     eax,[es:bx+4]
        mov     [ds:di+4],eax
        add     di,8
        add     bx,320
        loop    @@CopyFont
        xor     bx,bx
        mov     cx,8
        xor     eax,eax
@@ClearFont:
        mov     [es:bx],eax
        mov     [es:bx+4],eax
        add     bx,320
        loop    @@ClearFont
        inc     si
        jmp     @@GrabFont
@@Done: ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; DoFire
    ;
    ; IN: DS -> Source Segment for fire buffer
    ;     ES -> Destination Segment for updated fire buffer
    ;
    ; Updates one frame of the fire plasma
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC DoFire
        mov     eax,6e6e6e6eh                   ; Firstly initalise last
        mov     di,320*198                      ; two lines.
        mov     cx,(320*2)/4                    ; 
        rep     stosd
        mov     cx,50                           ; Use 50 hot spots for fire
        mov     si,320*199+2                    ;
@@MakeBottomRow:                                ;
        push    cx                              ; This generates the bottom
        mov     cx,320-4                        ; row.
        call    Random                          ;
        add     cx,2                            ;
        mov     di,si                           ;
        add     di,cx                           ;
        mov     ax,0FFFFh                       ;
        mov     [es:di-321],ax                  ;    
        mov     [es:di-1],ax                    ;    
        mov     [es:di-319],al                  ;    
        mov     [es:di+1],al                    ;    
        add     si,2                            ;    
        pop     cx                              ;    
        loop    @@MakeBottomRow                 ; 
        mov     di,320*101                      ; The normal fire loop that
        xor     bx,bx                           ; averages the pixels and
        xor     ax,ax                           ; plots the averaged pixel
        mov     cx,320*98                       ; above the one your doing.
@@AverageLoop:                                  ;
        mov     bl,[es:di-320]                  ;
        mov     al,[es:di+320]                  ;
        add     bx,ax                           ;
        mov     al,[es:di+1]                    ;
        add     bx,ax                           ;
        mov     al,[es:di-1]                    ;
        add     bx,ax                           ;
        shr     bx,2                            ; Better to average 4 pixels
        jnz     @@AboveLimit                    ; so we can shr
        inc     bx                              ;
@@AboveLimit:                                   ;
        dec     bx                              ;
        mov     [es:di-320],bl                  ;
        inc     di                              ;
        loop    @@AverageLoop                   ; 
        push    ds                              ; This doubles up each 
        mov     ax,[ScreenSeg]                  ; scan line so the fire can
        mov     es,ax                           ; fill the screen and still
        mov     ax,[FireSeg]                    ; remain fairly fast. 
        mov     ds,ax                           ; 
        mov     di,320*4                        ;
        mov     si,320*100                      ;
        mov     cx,98                           ;
@@DoubleLoop:                                   ;
        push    cx                              ;
        mov     cx,320 / 4                      ;
        repz    movsd                           ;
        mov     cx,320 / 4                      ;
        sub     si,320                          ;
        repz    movsd                           ;
        pop     cx                              ;
        loop    @@DoubleLoop                    ;
        pop     ds                              ;
        ret                                     ;
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; CreateText
    ;
    ; Draws up the text in the text buffer ready for masking on the screen
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC CreateText
        lea     si,[TextMessages]
        add     si,[PagePtr]
        mov     ax,[TextSeg]
        mov     es,ax
        xor     di,di

        mov     cx,12
@@DrawTextY:
        push    cx
        mov     cx,30
@@DrawTextX:
        mov     al,[ds:si]
        cmp     al,0FFh
        je      @@DoneDraw
        xor     bx,bx
@@ScanChar:
        mov     ah,[FontTbl + bx]
        cmp     ah,0FFh
        je      @@DoneDraw
        cmp     ah,al
        je      @@FoundChar
        inc     bx
        jmp     @@ScanChar
@@FoundChar:
        push    si
        lea     si,[FontData]
        shl     bx,6                     ; bx = offset into FontData
        xor     bp,bp
        push    cx
        mov     cx,8
@@DrawChar:
        mov     eax,[ds:si + bx]
        mov     [es:di+bp],eax
        mov     eax,[ds:si + bx + 4]
        mov     [es:di+bp+4],eax
        add     bp,320
        add     bx,8
        loop    @@DrawChar
        pop     cx
        pop     si
        add     di,8
        inc     si
        loop    @@DrawTextX
        pop     cx
        add     di,910h
        loop    @@DrawTextY
        ret
@@DoneDraw:
        mov     [PagePtr],0
        pop     cx
        ret        
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Interrupt 8 Handler for frame sync
    ;
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Interrupt8 FAR
        push    eax
        pushf
        inc     [cs:Frame]
        mov     al,20h
        out     20h,al
        popf
        pop     eax
        iret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; SetInt8
    ;
    ; Sets the new interrupt 8 handler
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC SetInt8
        mov     ax,3508h
        int     21h
        mov     [word ptr cs:OldInt8+2],es
        mov     [word ptr cs:OldInt8],bx
        lea     dx,[Interrupt8]
        mov     ax,2508h
        int     21h
        mov     dx,17000        ; 70Hz
        cli
	mov	al,036h
	out	43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	sti
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; ResetInt8
    ;
    ; Resets the old interrupt 8 handler
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC ResetInt8
        push    ds
        mov     ax,[word ptr cs:OldInt8+2]
        mov     ds,ax
        mov     dx,[word ptr cs:OldInt8]
        mov     ax,2508h
        int     21h
        pop     ds
        xor     dx,dx
        cli
	mov	al,036h
	out	43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	sti
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; DrawText
    ;
    ; Masks the text over the flames
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC DrawText
        cmp     [Fade],0
        je      @@FadeIn
        cmp     [Fade],1
        je      @@FadeOut
        jmp     @@StartDraw
@@FadeIn:
        add     [VisableColour],2
        cmp     [VisableColour],250
        jb      @@StartDraw
        mov     [Fade],2
        jmp     @@StartDraw
@@FadeOut:
        sub     [VisableColour],2
        cmp     [VisableColour],0
        ja      @@StartDraw
        mov     [Fade],2
        mov     [Frame],0
        add     [PagePtr],30*12
@@StartDraw:
        push    ds
        mov     ax,[TextSeg]
        mov     es,ax
        mov     ax,[ScreenSeg]
        mov     ds,ax
        xor     si,si
        mov     di,320*30+30
        mov     cx,12*8
@@l1:   push    cx
        mov     cx,30*8
@@l2:   mov     al,[es:si]
        or      al,al
        jz      @@DontDraw
        mov     ah,[ds:di]
        cmp     ah,[cs:VisableColour]
        ja      @@DontDraw
        shr     ah,1
        or      ah,0111b
        mov     [ds:di],ah
@@DontDraw:
        inc     si
        inc     di
        loop    @@l2
        add     di,50h
        add     si,50h
        pop     cx
        loop    @@l1
        pop     ds
        ret
ENDP
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Main Body Of Program
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC Main
        lea     di,[ZeroData]           ;
        mov     cx,0FFFFh               ;
        sub     cx,di                   ;
        inc     cx                      ;
        xor     ax,ax                   ;
        repz    stosb                   ; Make Zero Data
                                        ;
        call    Randomize               ; Initalise PRNG
        call    AllocMem                ; Allocate us some memory
        mov     [ScreenSeg],ax          ;
        call    AllocMem                ;
        mov     [FireSeg],ax            ;
        call    AllocMem                ;
        mov     [TextSeg],ax            ;
        mov     ax,13h                  ; Set VGA mode to 320x200x256
        int     10h                     ;
        call    GrabFont                ; Grabs BIOS font
        call    SetPalette              ; Set VGA palette
        call    SetInt8                 ; Setup Frame Syncing
        mov     [Frame],0               ;
        mov     [VisableColour],0       ;
        mov     [Fade],2
@@MAINLOOP:                             ; Here's where the loop starts
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        mov     ax,[FireSeg]            ;
        mov     es,ax                   ;
        call    DoFire                  ; Do a frame of the fire

        cmp     [Frame],300
        ja      @@FadeOut
        cmp     [Frame],100
        ja      @@FadeIn
        jmp     @@DrawStuff
@@FadeIn:
        mov     [Fade],0
        call    CreateText
        jmp     @@DrawStuff
@@FadeOut:
        mov     [Fade],1

@@DrawStuff:
        call    DrawText
        call    DisplayScreen           
        call    Retrace

        in      al,60h                  ; Get keyboard status
        cmp     al,1                    ; did someone hit the ESC key?
        jne     @@MAINLOOP              ;
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        xor     ax,ax                   ; Clear keyboard buffer
        int     16h                     ;
        call    ResetInt8               ;
        mov     ax,[ScreenSeg]          ; Free allocated memory
        call    FreeMem                 ;
        mov     ax,[FireSeg]            ;
        call    FreeMem                 ;
        mov     ax,[TextSeg]            ;
        call    FreeMem                 ;
        mov     ax,3                    ; Set mode back to 80x25
        int     10h                     ;
QuickExit:                              ;
        mov     ah,4Ch                  ; Exit back to DOS
        int     21h                     ;
ENDP

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; Main Data Area. Note: All ZERO (uninitalised data) must go at the
    ; end so it can be removed after assembly.
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LammerNoMem     db      'no memory$'
                         
FontTbl         db      ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                db      'abcdefghijklmnopqrstuvwxyz'
                db      '0123456789@;:#~,.<>/?\|!'
                db      '`œ$%^&*()-_=+ÉÍ»ºÈ¼',0FFh

; Here are the text pages that will be displayed. You can have as many as
; you like. There are some things you should know. The size must be 30x12
; and the only chars you can use are show above in the FontTbl. Also, dont
; remove the DB 0FFh at the end of the text pages as you will kill your
; machine.. :)
;              
TextMessages:
                db      'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
                db      'º****************************º'  
                db      'º*       SOUTH CENTRAL      *º'    
                db      'º*           TESKO          *º'
                db      'º****************************º'
                db      'º----------------------------º'
                db      'º      Code By : Frenzy      º'
                db      'º             for            º'
                db      'º        South Central       º'
                db      'º    Node1: ####-###-###     º'
                db      'º----------------------------º'
                db      'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

                db      'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
                db      'º Greets fly out to:-        º'  
                db      'º                            º'    
                db      'º   Everyone on #coders      º'
                db      'º   and #warez-uk            º'
                db      'º                            º'
                db      'º   all guys in TeSkO        º'
                db      'º                            º'
                db      'º   all others I know in     º'
                db      'º   da club...               º'
                db      'º                            º'
                db      'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

                db      'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
                db      'º                            º'  
                db      'º                            º'    
                db      'º                            º'
                db      'º                            º'
                db      'º     insert more stuff      º'
                db      'º           here :)          º'
                db      'º                            º'
                db      'º                            º'
                db      'º                            º'
                db      'º                            º'
                db      'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

                db      0FFh    ; <- Must not be removed!!!!!!!

                ZERODATA:
OldInt8         dd      0
Frame           dd      0
PagePtr         dw      0
FireSeg         dw      0
ScreenSeg       dw      0                       ; Virtual Screen
TextSeg         dw      0
Seed            dw      0                       ; Seed for PRNG
FontData        db      256 dup(8*8 dup(0))     ; Holds font data
Fade            db      0
VisableColour   db      0
ENDS
END START
