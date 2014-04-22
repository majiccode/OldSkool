; 32bit Protected Mode code!
;
; fake hi-colour plasma
;
; this is actually faking hi-colour on a 256 colour display using an xmode
; which has a high verticle resolution.
;
; works like persistance of vision. stand far back and your eye will mix
; the colours even though I only plot red's, green's and blue's on each
; scan line.
;
; code: Paul


        .386
        .MODEL FLAT 
        .STACK 1000h
        .CODE

             

QuitMsg         db      'HI-COLOUR PLASMA, (c)1996 Frenzy',13,10
                db      '컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴',13,10
                db      'Email: p.adams@wlv.ac.uk',13,10,13,10,'$'

baseaddress     dd      0
videoaddress    dd      0

include         SIN.INC      
include         COS.INC
include         PALETTE.INC             ; didnt need to precal pal but...

pos1            db      0
pos2            db      0
pos3            db      0
pos4            db      0
p1              db      0
p2              db      0
p3              db      0
p4              db      0
x               dd      0
y               dd      0
colour          db      0
                PROGRAM_START:

Main            PROC
                mov     ax,0EE02h       ; uhh?? this is a DOS32 thingy
                int     31h
                mov     [baseaddress],ebx
                mov     edi,0A0000h
                sub     edi,[baseaddress]
                mov     [videoaddress],edi      
                컴컴


           ;     mov     ax,13h          ; jump into 320x200x256
           ;     int     10h
            ;    mov     dx,3C4h         ; prepare for xmode change over!
            ;    mov     ax,0F02h        
            ;    out     dx,ax           
            ;    mov     dx,3C4h    
            ;    mov     ax,0604h     
            ;    out     dx,ax           
            ;    mov     dx,3D4h         
            ;    mov     ax,0014h        
            ;    out     dx,ax           
            ;    mov     dx,3D4h       
            ;    mov     ax,0E317h       
            ;    out     dx,ax           ; we are in xmode 320x200x256 4-planes!
             ;   mov     dx,3D4h         
            ;    mov     al,9            
            ;    out     dx,al           
            ;    inc     dx              
            ;    in      al,dx           
            ;    and     al,01110000b    
            ;    out     dx,al           ; now we have 320x400x256 4-planes!!
                mov     ax,13h
                int     10h
                mov     dx,3C4h
                mov     ax,0604h
                out     dx,ax
                mov     dl,0D4h
                mov     ax,0014h
                out     dx,ax
                mov     ax,0E317h
                out     dx,ax
                mov     ax,0009h
                out     dx,ax
                mov     dl,0C4h
                mov     ax,0F02h        ; all planes enabled!!!
                out     dx,ax

           ;
           ; video mode setting code...  uncomment if you want to use 
           ; 320x600 at 50hz! Comment out the 320x400 code above first..
           ;     include 320600-1.256
                컴컴
                mov     edi,[videoaddress]
                xor     eax,eax         
                mov     ecx,64000 / 4   
                repz    stosd         
                컴컴
                lea     esi,PaletteData ; Sets the palette       
                mov     dx,3C8h        
                xor     al,al        
                out     dx,al           
                inc     dx
                mov     ecx,768
@@SetPalLoop:   lodsb
                out     dx,al
                loop    @@SetPalLoop    ; had problems with repz outsb on
                                        ; some crappy VLB cards.

                xor     eax,eax         ; zap registers!
                xor     ebx,ebx               
                xor     ecx,ecx
                xor     edx,edx
@@PLASMALOOP:
                mov     al,[pos1]          
                mov     [p1],al         ; p1=pos1
                mov     al,[pos2]
                mov     [p2],al         ; p2=pos2
                mov     al,[pos3]
                mov     [p3],al         ; p3=pos3
                mov     al,[pos4]
                mov     [p4],al         ; p4=pos4
                mov     [y],0           ; holds y position on screen
@@YLoop:        mov     [x],0           ; holds x position on screen
@@XLoop:        mov     edi,[y]         ;
                lea     edi,[edi+edi*4] ;
                shl     edi,4           ; 
                lea     edi,[edi+edi*2] ;
                add     edi,[x]         ; edi=Y*240 + x
                add     edi,[videoaddress]

                ; at this point edi-> pixel position (x,y)

                mov     al,[p1]
                mov     al,[COSTABLE + eax]  
                mov     bl,[p2]
                add     al,[COSTABLE + ebx]  
                mov     bl,[p3]
                add     al,[COSTABLE + ebx]     
                mov     bl,[p4]
                add     al,[COSTABLE + ebx]     

                ; here, AL = Red component!

                xor     edx,edx            
                mov     bl,[p2]
                add     bl,al
                mov     bl,[SINTABLE + ebx]    
                mov     dl,[p1]
                add     dl,[p2]
                add     bl,[SINTABLE + edx]
                mov     dl,al
                add     dl,[p3]
                add     bl,[SINTABLE + edx]    
                mov     dl,[p4]
                sub     dl,al
                add     bl,[SINTABLE + edx]     

                ; here, BL = Green component!

                xor     ecx,ecx            
                mov     dl,al
                add     dl,bl
                mov     dl,[SINTABLE + edx]     
                mov     cl,al
                sub     cl,bl
                add     dl,[COSTABLE + ecx]   
                mov     ecx,[x]                 
                sub     ecx,[y]
                and     ecx,255               
                add     dl,[SINTABLE + ecx]   
                mov     ecx,[x]
                add     ecx,[y]
                and     ecx,255               
                add     dl,[COSTABLE + ecx]  

                ; here, DL = Blue component!
                ; edi = pixel position at coordinates x,y

                mov     [edi],al        ; plot red
               ; or      bl,63
                add     bl,64            
                mov     [edi+80],bl     ; plot green below it
               ; or      dl,127
                add     dl,128            
                mov     [edi+160],dl    ; plot blue below green

                add     [p1],1          ; update plasma positions
                add     [p2],2

                inc     [x]             ; next pixel along..
                cmp     [x],80          ; done complete scan line?
                jl      @@XLoop         ; nope, so do again..
                mov     al,[pos3]       ; update plasma positions..
                mov     [p1],al
                mov     al,[pos4]
                mov     [p2],al
                add     [p3],1
                add     [p4],1
                inc     [y]
                cmp     [y],134         ;Y counter.. Change depending on
                                        ;video mode. 134 in 320x400 (400/3)
                                        ;200 in 320x600 (600/3) etc..
                jl      @@YLoop
                add     [pos1],1        ; update master plasma positions
                mov     al,[pos3]
                add     al,2
                mov     [pos2],al
                mov     al,[pos1]
                inc     al
                mov     [pos3],al
                mov     al,[pos2]
                inc     al
                mov     [pos4],al

                ; sync this to the retrace to stop jery plasma movement..
                mov     dx,3DAh
@@Retr:         in      al,dx
                test    al,8          
                jz      @@Retr

                ; get key from keyboard port..
                in      al,60h
                cmp     al,1            ; escape pressed?
                jne     @@PLASMALOOP    ; nope, so do another frame 'o plasma
                컴컴
                mov     ax,3          
                int     10h

                mov     edx,Offset QuitMsg   
                mov     ah,9
                int     21h
                mov     ax,4C00h      
                int     21h
Main            ENDP

MUSIC_DATA:


                END     PROGRAM_START

