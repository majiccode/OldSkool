;
; Small HACK type intro.
;
; code: Paul
;
;


        .MODEL small
        .386
         IDEAL
         LOCALS

SEGMENT MAIN_CS DWORD PUBLIC 'CODE'
        ASSUME CS:MAIN_CS, DS:MAIN_CS, SS:MAIN_CS
        ORG     100h

Start:  mov     di,offset ZeroData          
        mov     cx,di                        
        neg     cx                              
        xor     ax,ax                         
        repz    stosb                         
        mov     ah,2                         
        int     1Ah
        mov     dx,2595h
        mov     [Seed],dx     
        call    AllocMem            
        mov     [ScreenSeg],es
        call    AllocMem                
        mov     [HexCharsSeg],es
        call    AllocMem                
        mov     [TextSeg],es

        mov     di,offset RandomNumbers
        mov     cx,15
@@makernd1:
        push    cx
        mov     cx,15
        call    Random
        mov     [MaxCols],cl
        mov     cx,320
@@makernd2:
        push    cx
        movzx   cx,[MaxCols]
        inc     cx
        call    Random
        mov     [di],cl
        inc     di
        pop     cx
        loop    @@makernd2
        pop     cx
        loop    @@makernd1
        push    es
        pop     gs
        mov     [WaitTime],10
        mov     [HexDataPtrHead],19*14*2
        mov     [HexDataPtrTail],0
        mov     [HexDataPtrMax],20*14*2
        mov     ax,offset HexData
        add     [HexDataPtrMax],ax
        call    InitTimer
        mov     ax,13h       
        int     10h                     
        mov     dx,3C8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     si,offset WhitePalette
        mov     cx,768
        mov     al,63
@@pal:  out     dx,al
        mov     [si],al
        inc     si
        loop    @@pal
        call    GrabFont
        mov     di,offset PaletteData
        mov     si,offset WhitePalette
        mov     cx,15
        call    SetupFade
@@FadeInLoop:   
        call    FadePalette
        jc      @@MAINLOOPa
        call    CreateStatic
        call    CreateHexDump
        call    DoneTextBit        
        jmp     @@FadeInLoop
@@MAINLOOPa:
        mov     [byte ptr nopper],90h          
MAINLOOP:
        call    CreateStatic    
        call    CreateHexDump
        call    FadePalette
        jnc     DoneTextBit
        mov     ax,[WaitTime]
        cmp     [Frame],ax
        jl      DoneTextBit
        mov     [Frame],0
        mov     bx,[CurrentMessage]
        mov     si,[Messages + bx]
        cmp     si,0FFFFh
        je      @@Action
        call    WriteText
        add     [CurrentMessage],2
        jmp     DoneTextBit
@@Action:
        add     [CurrentMessage],4
        add     bx,2
        mov     ax,[Messages + bx]
        cmp     ax,0FFFFh
        je      @@Repeat
        mov     [WaitTime],ax
        mov     [Frame],0
        jmp     DoneTextBit
@@Repeat:
        mov     [CurrentMessage],0
DoneTextBit:
        push    ds
        push    0A000h
        pop     es
        mov     ax,[HexCharsSeg]
        mov     fs,ax
        mov     ax,[ScreenSeg]
        mov     ds,ax
        mov     di,320*10+10                    
        mov     cx,8                         
@@top:  mov     eax,0F0F0F0F0h              
        mov     ebx,0D0D0D0D0h                 
        add     eax,[di]                     
        add     ebx,[di+320]                
        mov     [di],eax                    
        mov     [di+320],ebx                 
        mov     eax,0F0F0F0F0h              
        mov     ebx,0D0D0D0D0h               
        add     eax,[di+(320*180)+270]       
        add     ebx,[di+(320*181)+270]      
        mov     [di+(320*180)+270],eax      
        mov     [di+(320*181)+270],ebx       
        add     di,4                       
        dec     cx                          
        jnz     @@top                       
        mov     di,320*10+10                  
        mov     cx,32                       
@@side: mov     ax,0F0D0h                 
        mov     bx,0D0F0h                   
        add     ax,[di]                       
        mov     [di],ax                         
        add     bx,[di+(320*(180-32))+300]    
        mov     [di+(320*(180-32))+300],bx      
        add     di,320                          
        dec     cx                              
        jnz     @@side                         
        mov     di,321
        mov     cx,(64000 - 642)/4
@@l1:   mov     eax,[fs:di]                  
        and     eax,0F0F0F0F0h                 
        shr     eax,2                        
        add     [di],eax                        
        mov     eax,[gs:di]                    
        add     [di],eax                      
        add     di,4                        
        dec     cx                           
        jnz     @@l1                       
        xor     di,di                           
        xor     si,si                        
        mov     cx,64000 / 8
@@l2:   fld     [qword ptr si]
        fstp    [qword ptr es:di]
        add     si,8
        add     di,8
        dec     cx
        jnz     @@l2
        pop     ds            
nopper: ret
        mov     dx,3DAh
@@retr: in      al,dx
        and     al,8
        jnz     @@retr
        in      al,60h                         
        cmp     al,1                        
        jne     MAINLOOP                     
        xor     ax,ax                         
        int     16h
        call    DeInitTimer                     
        mov     ax,[ScreenSeg]        
        call    FreeMem                 
        mov     ax,[HexCharsSeg]
        call    FreeMem
        mov     ax,[TextSeg]
        call    FreeMem
        mov     ax,3                 
        int     10h                     
QuickExit:                              
        mov     dx,offset EndMsg
        mov     ah,9
        int     21h
        push    0B800h
        pop     es
        mov     di,1
        mov     al,3
        mov     cx,80
@@a1:   mov     [es:di],al
        add     di,2
        loop    @@a1
        mov     ah,4Ch          
        int     21h  

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
AllocMem:
        mov     bx,1000h                
        mov     ah,4Ah   
        int     21h    
        mov     bx,1000h                
        mov     ah,48h                          
        int     21h
        mov     es,ax
        xor     di,di                           
        xor     eax,eax                         
        mov     cx,64000 / 4                    
        repz    stosd                        
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FreeMem:mov     es,ax                           
        mov     ah,49h                          
        int     21h                           
        ret                               

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Random: mov     ax,[Seed]
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

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GrabFont:
        push    0A000h
        pop     es
        mov     si,offset FontTbl
        mov     di,offset FontData
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
@@l1:   push    cx
        mov     cx,8
@@l2:   mov     al,[es:bx]      
        or      al,al
        jz      @@black
        add     al,63-16
@@black:mov     [es:bx],al
        inc     bx
        loop    @@l2
        add     bx,320-8
        pop     cx
        loop    @@l1
        xor     bx,bx
        mov     cx,8
@@blur: push    cx                      
        mov     cx,8                    
@@b1:   mov     al,[es:bx]             
        shr     al,1
        mov     dl,[es:bx-320]
        shr     dl,3
        add     al,dl
        mov     dl,[es:bx+1]
        shr     dl,3
        add     al,dl
        mov     dl,[es:bx-1]
        shr     dl,3
        add     al,dl
        mov     dl,[es:bx+320]
        shr     dl,3
        add     al,dl
        mov     [di],al
        inc     bx
        inc     di
        loop    @@b1
        add     bx,320-8
        pop     cx
        loop    @@blur
        inc     si
        jmp     @@GrabFont
@@done: ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CreateStatic:
        mov     ax,[ScreenSeg]
        mov     es,ax
        xor     di,di
        mov     si,offset RandomNumbers
        mov     cx,200
@@l1:   push    cx
        mov     cx,14
        call    Random
        shl     cx,1
        mov     bx,cx
        shl     bx,8
        shl     cx,6
        add     bx,cx
        mov     cx,320 
        call    Random
        add     bx,cx
        mov     cx,320 / 4
@@l2:   mov     eax,[si + bx]
        mov     [es:di],eax
        add     di,4
        add     bx,4
        dec     cx
        jnz     @@l2
        pop     cx
        dec     cx
        jnz     @@l1
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CreateHexDump:
        xor     [clock],1
        cmp     [clock],1
        je      @@ok2
        mov     ax,[HexCharsSeg]
        mov     es,ax
        mov     di,offset HexData
        add     di,[HexDataPtrHead]
        mov     cx,14
@@makeline:
        push    cx
        mov     cx,[NumHexChars]
        call    Random
        movzx   bx,cl
        inc     bx
        shl     bx,6
        mov     [di],bx
        add     di,2
        pop     cx
        dec     cx
        jnz     @@makeline
        mov     si,offset HexData
        add     si,[HexDataPtrTail]
        mov     di,60
        mov     cx,20
@@l1:   push    cx
        mov     cx,14
@@l2:   mov     [RightStrip],cx
        push    cx
        mov     bx,[si]
        add     si,2
        cmp     si,[HexDataPtrMax]
        jle     @@NotMax
        mov     si,offset HexData
@@NotMax:
        push    di
        mov     cx,8
@@drawchar:
        mov     eax,[dword ptr FontData + bx]
        mov     [dword ptr es:di],eax
        cmp     [RightStrip],3
        ja      @@SkipRight1
        mov     [dword ptr es:di+120],eax
@@SkipRight1:
        mov     eax,[dword ptr FontData + bx + 4]
        mov     [dword ptr es:di+4],eax
        cmp     [RightStrip],3
        ja      @@SkipRight2
        mov     [dword ptr es:di+120+4],eax
@@SkipRight2:
        add     di,320
        add     bx,8
        dec     cx
        jnz     @@drawchar
        pop     di
        add     di,10
        pop     cx
        dec     cx
        jnz     @@l2
        add     di,(10*320)-(14*10)
        pop     cx
        dec     cx
        jnz     @@l1
        mov     ax,offset HexData              
        mov     bx,[HexDataPtrMax]             
        sub     bx,ax
        add     [HexDataPtrHead],14*2
        cmp     [HexDataPtrHead],bx
        jb      @@ok1
        mov     [HexDataPtrHead],0
@@ok1:  add     [HexDataPtrTail],14*2
        cmp     [HexDataPtrTail],bx
        jb      @@ok2
        mov     [HexDataPtrTail],0
@@ok2:  ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetupFade:
        push    cx
        push    si
        mov     cx,768
        xor     bx,bx
        xor     ax,ax
@@copypal:
        mov     ah,[si]
        mov     [word ptr FadePal + bx],ax
        add     bx,2
        inc     si
        dec     cx
        jnz     @@copypal
        pop     si
        pop     cx
        mov     [word ptr FadeSteps],cx
        xor     bp,bp
@@makedeltas:
        xor     ax,ax
        mov     ah,[di]
        sub     ah,[si]
        cwd
        idiv    cx
        mov     [word ptr ds:FadeDeltas+bp],ax
        add     bp,2
        inc     di
        inc     si
        cmp     bp,768*2
        jl      @@makedeltas
        mov     [FadeFrame],1
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetupFade2:
        mov     [FadeSteps],cx
        mov     cx,768
        xor     bx,bx
        xor     ax,ax
@@copypal:
        mov     ah,[si]
        mov     [word ptr FadePal + bx],ax
        add     bx,2
        inc     si
        dec     cx
        jnz     @@copypal
        mov     [FadeFrame],1
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FadePalette:
        xor     [clock2],1
        cmp     [clock2],1
        je      @@skip
        mov     ax,[FadeFrame]
        cmp     ax,[FadeSteps]
        jle     @@DoFade
        stc
        ret
@@DoFade:
        mov     si,offset FadePal
        mov     cx,768
        xor     bx,bx
        mov     dx,3C8h
        xor     al,al
        out     dx,al
        inc     dx
@@l1:   mov     ax,[si]
        add     ax,[FadeDeltas + bx]
        mov     [si],ax
        xchg    al,ah
        out     dx,al
        add     bx,2
        add     si,2
        dec     cx
        jnz     @@l1
        inc     [FadeFrame]
@@skip: clc
        ret        

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WriteText:
        mov     ax,[TextSeg]
        mov     es,ax
        mov     al,[si]
        cmp     al,0FFh
        jne     @@CarryOn
        ret
@@CarryOn:
        cmp     al,0
        je      @@FlashWhite
        cmp     al,1
        je      @@ClearText
        jmp     @@donemode
@@FlashWhite:
        push    si
        mov     di,offset PaletteData
        mov     si,offset WhitePalette
        mov     cx,15
        call    SetupFade2
        pop     si
        jmp     @@donemode
@@ClearText:
        push    si
        mov     di,offset PaletteData
        mov     si,offset WhitePalette
        mov     cx,15
        call    SetupFade2
        pop     si
        mov     cx,64000 / 4
        xor     di,di
        xor     eax,eax
        repz    stosd
@@donemode:
        inc     si
        mov     ax,[si]
        mov     [x],ax
        mov     [x2],ax
        add     si,2
        mov     ax,[si]
        mov     [y],ax
        add     si,2
        movsx   eax,[word ptr ds:si]
        mov     [xsize],eax
        mov     [xsize2],0
        add     si,2
        movsx   eax,[word ptr ds:si]
        mov     [ysize],eax
        add     si,2
        mov     al,[si]
        mov     [colour],al
        inc     si              ; si->text to display
@@showstring:
        mov     al,[si]
        or      al,al
        jz      @@endstring
        xor     bx,bx
@@findchar:
        mov     ah,[FontTbl + bx]
        cmp     ah,al
        je      @@foundchar
        inc     bx
        jmp     @@findchar
@@foundchar:
        shl     bx,6            ; bx -> offset of char in FontData
        push    si
        mov     si,offset FontData
        add     si,bx
        mov     di,offset ZoomBuffer
        add     di,[x2]
        mov     cx,8
@@drawy:mov     eax,[si]
        mov     [di],eax
        mov     eax,[si+4]
        mov     [di+4],eax
        add     di,320
        add     si,8
        dec     cx
        jnz     @@drawy
        add     [x2],8
        add     [xsize2],8
        pop     si
        inc     si
        jmp     @@showstring
@@endstring:
        inc     si
        push    si
        mov     eax,[xsize2]
        shl     eax,8
        xor     edx,edx
        mov     ecx,[xsize]
        idiv    ecx
        mov     [ddx],eax
        mov     eax,8*256
        xor     edx,edx
        mov     ecx,[ysize]
        idiv    ecx
        mov     [ddy],eax
        mov     si,offset ZoomBuffer
        add     si,[x]
        mov     di,[y]
        mov     ax,di
        shl     ax,8
        shl     di,6
        add     di,ax
        add     di,[x]
        xor     ebx,ebx
        xor     edx,edx
        mov     ecx,[ysize]
@@scaley:
        push    ecx
        mov     ecx,[xsize]
        push    di
@@scalex:
        mov     eax,edx
        shr     eax,8
        mov     ebp,eax
        shl     ebp,6
        shl     eax,8
        add     eax,ebp
        mov     ebp,ebx
        shr     ebp,8
        add     ebp,eax
        mov     al,[ds:si + bp]
        test    al,al
        jz      @@noadd
        add     al,[colour]
        mov     [es:di],al
@@noadd:inc     di
        add     ebx,[ddx]
        dec     ecx
        jnz     @@scalex
        mov     eax,[xsize]
        pop     di
        add     di,320
        xor     ebx,ebx
        add     edx,[ddy]
        pop     ecx
        dec     ecx
        jnz     @@scaley
        pop     si
        jmp     WriteText
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InitTimer:
        xor     ax,ax
        mov     fs,ax
        mov     eax,[fs:8*4]
        mov     [OldInt8],eax
        mov     ax,cs
        shl     eax,16
        mov     ax,OFFSET Int8
        mov     dx,17000              
        jmp     blah
DeInitTimer:
        mov     eax,[OldInt8]
        xor     dx,dx
        mov     fs,dx
blah:   cli
        mov     [fs:8*4],eax
        mov     al,036h
        out     43h,al
        mov     al,dl
        out     40h,al
        mov     al,dh
        out     40h,al
        sti
        ret

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Int8:   push    ax
        mov     al,20h
        out     20h,al
        inc     [Frame]
        pop     ax
        iret

; ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; º°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°MAIN DATA°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°º
; ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

FontTbl         db      ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                db      'abcdefghijklmnopqrstuvwxyz'
                db      '0123456789@:,./?\!'
                db      'œ%&*()-=+',0FFh
NumHexChars     dw      ($-FontTbl)-3

include         'PALETTE.INC'

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; This is the script for text displaying..
    ;
    ; a 0FFFFh followed by a number is the delay time between the next
    ; message.. The rest is simple :)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Messages        dw      0FFFFh
                dw      1
                dw      offset msg_tripwire
                dw      offset msg_a
                dw      offset msg_production
                dw      offset msg_text1
                dw      0FFFFh
                dw      20
                dw      0FFFFh
                dw      1
                dw      offset msg_text2
                dw      offset msg_text3
                dw      offset msg_text4
                dw      offset msg_text5
                dw      offset msg_text6
                dw      offset msg_text7
                dw      offset msg_text8
                dw      0FFFFh
                dw      20 
                dw      offset msg_text9
                dw      0FFFFh
                dw      1
                dw      offset msg_text10
                dw      offset msg_text11
                dw      offset msg_text12
                dw      0FFFFh
                dw      20
                dw      0FFFFh
                dw      1
                dw      offset msg_text13
                dw      offset msg_text14
                dw      offset msg_text15
                dw      offset msg_text16
                dw      offset msg_text17
                dw      offset msg_text18
                dw      0FFFFh
                dw      20
                dw      0FFFFh
                dw      0FFFFh

    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    ; How the hell does this work? Well, cuz i did this code in a short
    ; space of time this is hardly ideal. However, it works like this:-
    ;
    ; msg_mytext  db   0 or 1      (0=clear screen/flash, 1=flash)
    ;             dw   x,y         (coordinates of text message)
    ;             dw   xsize,ysize (scaled sized..)
    ;             db   0 or 63     (0=white, 63=red)
    ;             db   'this is the text!!',0
    ;
    ; Each char is an 8x8 bitmap. So, if your message contains two chars the
    ; size of the bitmap will be 16x8. Now, scale it up twice as much put
    ; 32x16 in the scaled size.
    ;
    ; now, do the same or follow it with a 0FFh for no more text..
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
msg_a           db      0
                dw      310-90,52
                dw      8,8
                db      0   
                db      'a',0
                db      0FFh
msg_tripwire    db      1
                dw      310-80,10       
                dw      80,55      
                db      63
                db      'FRENZY',0
                db      0FFh
msg_production  db      0
                dw      310-80,60
                dw      77,8
                db      0
                db      'production',0
                db      0FFh
msg_text1       db      0
                dw      50,90
                dw      26*8,16
                db      0
                db      '!Da Best UK C0DER ArOunD!',0
                db      0FFh
msg_text2       db      1
                dw      15,20
                dw      38*8-10,16
                db      0
                db      'If you would like to contact me',0
                db      0FFh
msg_text3       db      0
                dw      60,20+17
                dw      26*8-10,16
                db      0
                db      'Then simply EMAIL me at:',0
                db      0FFh
msg_text4       db      0
                dw      90,37+17
                dw      17*8-10,16
                db      0
                db      'p.adams@wlv.ac.uk',0
                db      0FFh
msg_text5       db      0
                dw      60,20+17
                dw      26*8-10,16
                db      63
                db      '            EMAIL me    ',0
                db      0FFh
msg_text6       db      0
                dw      90,37+17
                dw      17*8-10,16
                db      63
                db      'p.adams@wlv.ac.uk',0
                db      0FFh
msg_text7       db      0
                dw      60,100
                dw      26*8-10,16
                db      0
                db      'however, if your lame....',0
                db      0FFh

msg_text8       db      0
                dw      90,120
                dw      17*8-10,16
                db      63
                db      'DONT BOTHER!!! :)',0
                db      0FFh

msg_text9       db      1
                dw      15,20
                dw      37*8,16
                db      0
                db      'Always look out for productions by..',0
                db      0FFh
msg_text10      db      0
                dw      30,90
                dw      33*8,32
                db      0
                db      ' par ',0
                db      0FFh
msg_text11      db      0
                dw      30,90
                dw      33*8,32
                db      63
                db      'S   C',0
                db      0FFh
msg_text12      db      0
                dw      275,90+32
                dw      20,8
                db      0
                db      'TM',0
                db      0FFh
msg_text13      db      1
                dw      15,20
                dw      34*8,16
                db      63
                db      'If your interested in any these..',0
                db      0FFh
msg_text14      db      0
                dw      15,60
                dw      7*20,10
                db      0
                db      '* Assembly Language',0
                db      0FFh
msg_text15      db      0
                dw      15,60-12
                dw      7*15,10
                db      0
                db      '* Watcom C/C++',0
                db      0FFh
msg_text16      db      0
                dw      15,60+12
                dw      7*16,10
                db      0
                db      '* DEMOS, INTROS',0
                db      0FFh
msg_text17      db      0
                dw      15,60+12+12
                dw      7*23,10
                db      0
                db      '* Realtime 3D Graphics',0
                db      0FFh
msg_text18      db      0
                dw      15,170
                dw      7*38,10
                db      63
                db      'We are always happy to hear from you..',0
                db      0FFh

EndMsg          db      'Code by Frenzy / SparC - EMAIL: p.adams@wlv.ac.uk$'

                ZERODATA:
ScreenSeg       dw      0                 
HexCharsSeg     dw      0
TextSeg         dw      0
Seed            dw      0
FadeFrame       dw      0
FadeSteps       dw      0
FadeDeltas      dw      768 dup(0)
FadePal         dw      768 dup(0)
WhitePalette    db      768 dup(0)
FontData        db      256 dup(8*8 dup(0))    
RightStrip      dw      0
MaxCols         db      0
ZoomBuffer      db      8*320 dup(0)
CurrentMessage  dw      0
Frame           dw      0
WaitTime        dw      0
OldInt8         dd      0
ddx             dd      0
ddy             dd      0
x               dw      0
x2              dw      0
y               dw      0
xsize           dd      0
xsize2          dd      0
ysize           dd      0
colour          db      0
clock           db      0
clock2          db      0
HexDataPtrHead  dw      0
HexDataPtrTail  dw      0
HexDataPtrMax   dw      0
HexData         dw      14*20 dup(0)
HexDataEnd:
RandomNumbers   db      320*30 dup(0)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENDS
END START
