    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; RENDER.ASM, rendering routines for 3D engine
    ;            + 3D Projection, matrix Rotation, Dot Product, Sorting
    ; -----------------------------------------------------------------------
    ; Callable from WATCOM C/C++ 32bit
    ;
    ; This code is 100% original and must not be distributed or used without
    ; express permission of the author. 
    ;
    ; (c)1996 Paul Adams aka Frenzy, all rights reserved.
    ; EMAIL: p.adams@wlv.ac.uk
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        .386P
        .MODEL FLAT
         LOCALS
        .CODE

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   ;같같같같같같같같같같같같같FUNCTION DEFINITIONS같같같같같같같같같같같같같�
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        PUBLIC  set3dpal_     
        PUBLIC  set3dpage_      
        PUBLIC  setclipping_    
        PUBLIC  triangle_      
        PUBLIC  gtriangle_   
        PUBLIC  ptriangle_   
        PUBLIC  texturemap256_ 
        PUBLIC  phongtexturemap256_ 
        PUBLIC  motionclear_  
        PUBLIC  dotproduct_ 
        PUBLIC  initmatrix_ 
        PUBLIC  matrotate_  
        PUBLIC  inversematrix_ 
        PUBLIC  quicksort_  

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   ;같같같같같같같같같같같같같같같캢LOBALS같같같같같같같같같같같같같같같같같�
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        db      '3D Engine (c)1996 Paul Adams aka Frenzy'
        align 4
        include         LOOKUPS.INC
        yTOP            dd      0
        yMID            dd      0        
        yBOT            dd      0       
        xTOP            dd      0       
        xMID            dd      0               
        xBOT            dd      0               
        cTOP            dd      0               
        cMID            dd      0               
        cBOT            dd      0               
        tTOP            dd      0               
        tMID            dd      0               
        tBOT            dd      0               
        uTOP            dd      0               
        uMID            dd      0               
        uBOT            dd      0               
        vTOP            dd      0               
        vMID            dd      0               
        vBOT            dd      0
        luTOP           dd      0
        luMID           dd      0
        luBOT           dd      0
        lvTOP           dd      0
        lvMID           dd      0
        lvBOT           dd      0
        basecolour      dd      0
        maxcolours      dd      0
        shadetable      dd      0
        phongtable      dd      0
        vpage           dd      0A0000h    
        colour          dd      0
        resort          dd      0
        sindex          dd      0


        DeltaX1         dd      0          
        DeltaX2         dd      0           
        DeltaT1         dd      0            
        DeltaT2         dd      0        
        DeltaC1         dd      0
        DeltaC2         dd      0
        DeltaU1         dd      0
        DeltaU2         dd      0
        DeltaLu1        dd      0
        DeltaLu2        dd      0
        DeltaV1         dd      0
        DeltaV2         dd      0
        DeltaLv1        dd      0
        DeltaLv2        dd      0
        XValue1         dd      0
        XValue2         dd      0
        TValue1         dd      0
        TValue2         dd      0
        CValue1         dd      0
        CValue2         dd      0
        UValue1         dd      0
        UValue2         dd      0
        VValue1         dd      0
        VValue2         dd      0
        LUValue1        dd      0
        LUValue2        dd      0
        LVValue1        dd      0
        LVValue2        dd      0
        TmpU            dd      0
        TmpV            dd      0
        TmpLU           dd      0
        TmpLV           dd      0
        YCounter        dd      0
        YStart          dd      0
        DeltaU          dd      0
        DeltaV          dd      0
        DeltaLu         dd      0
        DeltaLv         dd      0
        clipx1          dd      0     
        clipy1          dd      0          
        tclipy1         dd      0
        clipx2          dd      0         
        clipy2          dd      0         
        tclipy2         dd      0
        clipz           dd      0          
        zclipping       db      0         

        ; Matrix[0][0] = ((cz * cy) + ((sx * sz) >> 8) * sy) >> 8
        ; Matrix[0][1] = ((cy * -sz) + ((cz * sx) >> 8) * sy) >> 8
        ; Matrix[0][2] = (cx * sy) >> 8;
        ; Matrix[1][0] = (sz * cx) >> 8;
        ; Matrix[1][1] = (cz * cx) >> 8;
        ; Matrix[1][2] = (-sx);
        ; Matrix[2][1] = ((-sy * cz) + ((sz * sx) >> 8) * cy) >> 8;
        ; Matrix[2][2] = ((-sz * -sy) + ((cz * sx) >> 8) * cy) >> 8;
        ; Matrix[2][3] = (cx * cy) >> 8;

        CosX            dd      0       
        CosY            dd      0               
        CosZ            dd      0               
        SinX            dd      0               
        SinY            dd      0               
        SinZ            dd      0               
        Matrix          dd      0, 0, 0        
                        dd      0, 0, 0         
                        dd      0, 0, 0         
        _6mulconst      dd      0, 0, 0, 0      

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: set3dpal
    ;     Call: void set3dpal(*paldata, startcolour, maxcolours, cindex)
    ;   Return: -
    ;    Notes: sets the VGA palette
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
set3dpal_       PROC
                mov     esi,eax
                mov     eax,ecx
                imul    eax,3
                add     esi,eax
                mov     ecx,ebx
                imul    ecx,3
                mov     eax,edx
                mov     dx,3c8h
                out     dx,al
                inc     dx
@@setdac:       mov     al,[esi]
                out     dx,al
                jmp     $+2
                jmp     $+2
                jmp     $+2
                jmp     $+2
                jmp     $+2
                inc     esi
                loop    @@setdac
                ret
set3dpal_       ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: set3dpage
    ;     Call: void set3dpage(char *screenpage)
    ;   Return: -
    ;    Notes: must be called once, to select where all screen writes will
    ;           occur
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
set3dpage_      PROC
                mov     [vpage],eax
                ret
set3dpage_      ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: setclipping
    ;     Call: void setclipping(x1,y1,x2,y2,z)
    ;   Return: -
    ;    Notes: must be called so the polygon routines can clipp.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
setclipping_    PROC
                cmp     eax,0
                jg      @@OnScreen1
                xor     eax,eax
@@OnScreen1:    cmp     eax,319
                jb      @@OnScreen2
                mov     eax,319
@@OnScreen2:    mov     [clipx1],eax
                cmp     edx,0
                jg      @@OnScreen3
                xor     edx,edx
@@OnScreen3:    cmp     edx,199
                jb      @@OnScreen4
                mov     edx,199
@@OnScreen4:    mov     [clipy1],edx
                cmp     ebx,0
                jg      @@OnScreen5
                xor     ebx,ebx
@@OnScreen5:    cmp     ebx,319
                jb      @@OnScreen6
                mov     ebx,319
@@OnScreen6:    mov     [clipx2],ebx
                cmp     ecx,0
                jg      @@OnScreen7
                xor     ecx,ecx
@@OnScreen7:    cmp     ecx,199
                jb      @@OnScreen8
                mov     ecx,199
@@OnScreen8:    mov     [clipy2],ecx
                ret
setclipping_    ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: triangle
    ;     Call: void triangle(x1,y1, x2,y2, x3,y3, colour);
    ;   Return: -
    ;    Notes: This is the most basic triangle routine. Its only ment for
    ;           single colour triangles, so it is used in lambert shading.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
triangle_       PROC
                push    ebp             ; gota make sure we can access the
                mov     ebp,esp         ; arguments on the stack.
                컴컴
                ARG x3:DWORD, y3:DWORD, col:DWORD;
                컴컴
                mov     [xTOP],eax
                mov     eax,edx
                mov     [xMID],ebx
                mov     ebx,ecx
                mov     ecx,[x3]        ;
                mov     [xBOT],ecx      ; xBOT=x3
                mov     ecx,[y3]        ;  ecx=y3
@@yTOP_yMID:    cmp     eax,ebx         ; 
                jg      @@yTOP_yBOT     ; if(yTOP<yMID)
                xchg    eax,ebx         ;   swap yTOP with yMID
                mov     edx,[xTOP]      ;   swap xTOP with xMID
                xchg    edx,[xMID]      ;
                mov     [xTOP],edx      ;
@@yTOP_yBOT:    cmp     eax,ecx         ;
                jg      @@yMID_yBOT     ; if(yTOP<yBOT)
                xchg    eax,ecx         ;   swap yTOP with yBOT
                mov     edx,[xTOP]      ;   swap xTOP with xBOT
                xchg    edx,[xBOT]      ;
                mov     [xTOP],edx      ;
@@yMID_yBOT:    cmp     ebx,ecx         ;
                jg      @@DoneYCompare  ; if(yMID<yBOT)
                xchg    ebx,ecx         ;   swap yMID with yBOT
                mov     edx,[xMID]      ;   swap xMID with xBOT
                xchg    edx,[xBOT]      ;
                mov     [xMID],edx      ;
@@DoneYCompare: mov     [yTOP],eax      ; update yTOP, yMID and yBOT ready
                mov     [yMID],ebx      ; for scan conversion
                mov     [yBOT],ecx      ;
                컴컴
                mov     ecx,[yTOP]      ; Finds out which side the largest
                sub     ecx,[yBOT]      ; edge is.. Either Right or Left
                jz      @@DoneCheck
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                mov     ebx,[yMID]
                sub     ebx,[yBOT]
                imul    ebx
                idiv    ecx
                add     eax,[xBOT]
                mov     ebx,[xMID]
                cmp     eax,ebx
                jl      @@ChangeDirection
@@DoneCheck:    mov     ecx,[yTOP]      ; Calculate Largest Sides Gradient
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16          
                mov     [DeltaX2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     edi,[yBOT]
                mov     [YStart],edi
                lea     edi,[edi+edi * 4]
                shl     edi,6
                add     edi,[vpage]   
@@Side1A:       mov     ecx,[yMID]     
                sub     ecx,[yBOT]
                jz      @@Side2A
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[yMID]
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]     
                mov     [XValue1],eax
@@HLINE_1A:     push    edi
                cmp     [YStart],0
                jl      @@SkipHLINE_1A
                cmp     [YStart],199
                jg      @@SkipHLINE_1A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipClipX1A
                mov     ax,319
@@SkipClipX1A:  mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                jl      @@SkipHLINE_1A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     edx,[col]       
                shl     edx,2           
                mov     eax,[ColourLookup+edx]
                mov     edx,ecx
                shr     ecx,2
                repz    stosd
                mov     ecx,edx
                and     ecx,3
                repz    stosb
@@SkipHLINE_1A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1A
@@Side2A:       mov     ecx,[yTOP]     
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[yTOP]     
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]    
                mov     [XValue1],eax
@@HLINE_2A:     push    edi           
                cmp     [YStart],0
                jl      @@SkipHLINE_2A
                cmp     [YStart],199
                jg      @@SkipHLINE_2A
                mov     eax,[XValue2]   
                cmp     ax,319
                jle     @@SkipClipX2A
                mov     ax,319
@@SkipClipX2A:  mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                jl      @@SkipHLINE_2A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     edx,[col]       
                shl     edx,2           
                mov     eax,[ColourLookup+edx]
                mov     edx,ecx
                shr     ecx,2
                repz    stosd
                mov     ecx,edx
                and     ecx,3
                repz    stosb
@@SkipHLINE_2A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2A
                jmp     @@DoneTriangle
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@@ChangeDirection:
                mov     ecx,[yTOP]     
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16     
                mov     [DeltaX2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax
                mov     edi,[yBOT]
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage] 
@@Side1B:       mov     ecx,[yMID]  
                sub     ecx,[yBOT]
                jz      @@Side2B
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[yMID]    
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]     
                mov     [XValue1],eax
@@HLINE_1B:     push    edi             
                cmp     [YStart],0
                jl      @@SkipHLINE_1B
                cmp     [YStart],199
                jg      @@SkipHLINE_1B
                mov     eax,[XValue1]   
                cmp     ax,319
                jle     @@SkipClipX1B
                mov     ax,319
@@SkipClipX1B:  mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                jl      @@SkipHLINE_1B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     edx,[col]       
                shl     edx,2           
                mov     eax,[ColourLookup+edx]
                mov     edx,ecx
                shr     ecx,2
                repz    stosd
                mov     ecx,edx
                and     ecx,3
                repz    stosb
@@SkipHLINE_1B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1B
@@Side2B:       mov     ecx,[yTOP]      
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[yTOP]     
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
@@HLINE_2B:     push    edi             
                cmp     [YStart],0
                jl      @@SkipHLINE_2B
                cmp     [YStart],199
                jg      @@SkipHLINE_2B
                mov     eax,[XValue1]   
                cmp     ax,319
                jle     @@SkipClipX2B
                mov     ax,319
@@SkipClipX2B:  mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                jl      @@SkipHLINE_2B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     edx,[col]       
                shl     edx,2           
                mov     eax,[ColourLookup+edx]
                mov     edx,ecx
                shr     ecx,2
                repz    stosd
                mov     ecx,edx
                and     ecx,3
                repz    stosb
@@SkipHLINE_2B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2B
@@DoneTriangle: mov     esp,ebp        
                pop     ebp             
                ret                 
triangle_       ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: gtriangle
    ;     Call: void gtriangle(x1,y1, x2,y2, x3,y3, c1,c2,c3);
    ;   Return: -
    ;    Notes: This is for gouraud shading. 
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
gtriangle_      PROC    
                push    ebp             ; gota make sure we can access the
                mov     ebp,esp         ; arguments on the stack.
                컴컴
                ARG x3:DWORD, y3:DWORD, c1:DWORD, c2:DWORD, c3:DWORD; 
                컴컴
                mov     [xTOP],eax
                mov     eax,edx
                mov     [xMID],ebx
                mov     ebx,ecx
                mov     ecx,[x3]        ;
                mov     [xBOT],ecx      ; xBOT=x3
                mov     ecx,[y3]        ;  ecx=y3
                mov     edx,[c1]        ; 
                mov     [cTOP],edx      ; cTOP=c1
                mov     edx,[c2]        ; 
                mov     [cMID],edx      ; cMID=c2
                mov     edx,[c3]        ; 
                mov     [cBOT],edx      ; cTOP=c3
@@yTOP_yMID:    cmp     eax,ebx         ; 
                jg      @@yTOP_yBOT     ; if(yTOP<yMID)
                xchg    eax,ebx         ;   swap yTOP with yMID
                mov     edx,[xTOP]      ;   swap xTOP with xMID
                xchg    edx,[xMID]      ;   swap tTOP with tMID
                mov     [xTOP],edx      ;
                mov     edx,[cTOP]      ;
                xchg    edx,[cMID]      ;
                mov     [cTOP],edx      ;
@@yTOP_yBOT:    cmp     eax,ecx         ;
                jg      @@yMID_yBOT     ; if(yTOP<yBOT)
                xchg    eax,ecx         ;   swap yTOP with yBOT
                mov     edx,[xTOP]      ;   swap xTOP with xBOT
                xchg    edx,[xBOT]      ;   swap tTOP with tBOT
                mov     [xTOP],edx      ;
                mov     edx,[cTOP]      ;
                xchg    edx,[cBOT]      ;
                mov     [cTOP],edx      ;
@@yMID_yBOT:    cmp     ebx,ecx         ;
                jg      @@DoneYCompare  ; if(yMID<yBOT)
                xchg    ebx,ecx         ;   swap yMID with yBOT
                mov     edx,[xMID]      ;   swap xMID with xBOT
                xchg    edx,[xBOT]      ;   swap tMID with tBOT
                mov     [xMID],edx      ;
                mov     edx,[cMID]      ;
                xchg    edx,[cBOT]      ;
                mov     [cMID],edx      ;
@@DoneYCompare: mov     [yTOP],eax      ; update yTOP, yMID and yBOT ready
                mov     [yMID],ebx      ; for scan conversion
                mov     [yBOT],ecx      ;
                컴컴
                mov     ecx,[yTOP]      ; Finds out which side the largest
                sub     ecx,[yBOT]      ; edge is.. Either Right or Left
                jz      @@DoneCheck
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                mov     ebx,[yMID]
                sub     ebx,[yBOT]
                imul    ebx
                idiv    ecx
                add     eax,[xBOT]
                mov     ebx,[xMID]
                cmp     eax,ebx
                jl      @@ChangeDirection
@@DoneCheck:    mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[cTOP]
                sub     eax,[cBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaC2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[cBOT]
                mov     [CValue2],eax  
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1A:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2A
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[cMID]
                sub     eax,[cBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaC1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[cBOT]    
                mov     [CValue1],eax
@@HLINE_1A:     push    edi             
                cmp     [YStart],0
                jl      @@SkipGLINE_1A
                cmp     [YStart],199
                jg      @@SkipGLINE_1A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_1A
                mov     ax,319
@@SkipXClip_1A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipGline_1A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[CValue2]
                sub     eax,[CValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipGline_1A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     edx,[CValue1]
@@GLine_1A:     mov     [edi],dl
                add     edx,eax         
                adc     edx,0     
                inc     edi             
                dec     ecx             
                jnz     @@GLine_1A
@@SkipGline_1A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[CValue2]
                add     eax,[DeltaC2]
                adc     eax,0
                mov     [CValue2],eax
                mov     eax,[CValue1]
                add     eax,[DeltaC1]
                adc     eax,0
                mov     [CValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1A
@@Side2A:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[cTOP]
                sub     eax,[cMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaC1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[cMID]    
                mov     [CValue1],eax
@@HLINE_2A:     push    edi
                cmp     [YStart],0
                jl      @@SkipGLINE_2A
                cmp     [YStart],199
                jg      @@SkipGLINE_2A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_2A
                mov     ax,319
@@SkipXClip_2A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipGline_2A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[CValue2]
                sub     eax,[CValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipGline_2A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     edx,[CValue1]
@@GLine_2A:     mov     [edi],dl 
                add     edx,eax         
                adc     edx,0           
                inc     edi             
                dec     ecx             
                jnz     @@GLine_2A
@@SkipGline_2A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[CValue2]
                add     eax,[DeltaC2]
                adc     eax,0
                mov     [CValue2],eax
                mov     eax,[CValue1]
                add     eax,[DeltaC1]
                adc     eax,0
                mov     [CValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2A
                jmp     @@DoneTriangle
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@@ChangeDirection:
                mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[cTOP]
                sub     eax,[cBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaC2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[cBOT]
                mov     [CValue2],eax  
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1B:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2B
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[cMID]
                sub     eax,[cBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaC1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[cBOT]    
                mov     [CValue1],eax
@@HLINE_1B:     push    edi
                cmp     [YStart],0
                jl      @@SkipGLINE_1B
                cmp     [YStart],199
                jg      @@SkipGLINE_1B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_1B
                mov     ax,319
@@SkipXClip_1B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipGline_1B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[CValue1]
                sub     eax,[CValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipGline_1B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     edx,[CValue2]
@@GLine_1B:     mov     [edi],dl
                add     edx,eax         
                adc     edx,0     
                inc     edi             
                dec     ecx             
                jnz     @@GLine_1B
@@SkipGline_1B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[CValue2]
                add     eax,[DeltaC2]
                adc     eax,0
                mov     [CValue2],eax
                mov     eax,[CValue1]
                add     eax,[DeltaC1]
                adc     eax,0
                mov     [CValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1B
@@Side2B:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[cTOP]
                sub     eax,[cMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaC1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[cMID]    
                mov     [CValue1],eax
@@HLINE_2B:     push    edi            
                cmp     [YStart],0
                jl      @@SkipGLINE_2B
                cmp     [YStart],199
                jg      @@SkipGLINE_2B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_2B
                mov     ax,319
@@SkipXClip_2B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipGline_2B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[CValue1]
                sub     eax,[CValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipGline_2B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     edx,[CValue2]
@@GLine_2B:     mov     [edi],dl 
                add     edx,eax         
                adc     edx,0           
                inc     edi             
                dec     ecx             
                jnz     @@GLine_2B
@@SkipGline_2B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[CValue2]
                add     eax,[DeltaC2]
                adc     eax,0
                mov     [CValue2],eax
                mov     eax,[CValue1]
                add     eax,[DeltaC1]
                adc     eax,0
                mov     [CValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2B
@@DoneTriangle: mov     esp,ebp
                pop     ebp             
                ret                 
gtriangle_      ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: ptriangle
    ;     Call: void ptriangle(x1,y1, x2,y2, x3,y3, t1,t2,t3, phongtable);
    ;   Return: -
    ;    Notes: This is for angular interpolated phong. Identical to
    ;           gouraud shading except theta values are interpolated.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ptriangle_      PROC    
                push    ebp             ; gota make sure we can access the
                mov     ebp,esp         ; arguments on the stack.
                컴컴
                ARG x3:DWORD, y3:DWORD,t1:DWORD, t2:DWORD, t3:DWORD, ptable:DWORD; 
                컴컴
                mov     [xTOP],eax
                mov     eax,edx
                mov     [xMID],ebx
                mov     ebx,ecx
                mov     ecx,[x3]        ;
                mov     [xBOT],ecx      ; xBOT=x3
                mov     ecx,[y3]        ;  ecx=y3
                mov     edx,[ptable]
                mov     [PHONGTABLE],edx
                mov     edx,[t1]        ; 
                mov     [tTOP],edx      ; cTOP=c1
                mov     edx,[t2]        ; 
                mov     [tMID],edx      ; cMID=c2
                mov     edx,[t3]        ; 
                mov     [tBOT],edx      ; cTOP=c3
@@yTOP_yMID:    cmp     eax,ebx         ; 
                jg      @@yTOP_yBOT     ; if(yTOP<yMID)
                xchg    eax,ebx         ;   swap yTOP with yMID
                mov     edx,[xTOP]      ;   swap xTOP with xMID
                xchg    edx,[xMID]      ;   swap tTOP with tMID
                mov     [xTOP],edx      ;
                mov     edx,[tTOP]      ;
                xchg    edx,[tMID]      ;
                mov     [tTOP],edx      ;
@@yTOP_yBOT:    cmp     eax,ecx         ;
                jg      @@yMID_yBOT     ; if(yTOP<yBOT)
                xchg    eax,ecx         ;   swap yTOP with yBOT
                mov     edx,[xTOP]      ;   swap xTOP with xBOT
                xchg    edx,[xBOT]      ;   swap tTOP with tBOT
                mov     [xTOP],edx      ;
                mov     edx,[tTOP]      ;
                xchg    edx,[tBOT]      ;
                mov     [tTOP],edx      ;
@@yMID_yBOT:    cmp     ebx,ecx         ;
                jg      @@DoneYCompare  ; if(yMID<yBOT)
                xchg    ebx,ecx         ;   swap yMID with yBOT
                mov     edx,[xMID]      ;   swap xMID with xBOT
                xchg    edx,[xBOT]      ;   swap tMID with tBOT
                mov     [xMID],edx      ;
                mov     edx,[tMID]      ;
                xchg    edx,[tBOT]      ;
                mov     [tMID],edx      ;
@@DoneYCompare: mov     [yTOP],eax      ; update yTOP, yMID and yBOT ready
                mov     [yMID],ebx      ; for scan conversion
                mov     [yBOT],ecx      ;
                컴컴
                mov     ecx,[yTOP]      ; Finds out which side the largest
                sub     ecx,[yBOT]      ; edge is.. Either Right or Left
                jz      @@DoneCheck
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                mov     ebx,[yMID]
                sub     ebx,[yBOT]
                imul    ebx
                idiv    ecx
                add     eax,[xBOT]
                mov     ebx,[xMID]
                cmp     eax,ebx
                jl      @@ChangeDirection
@@DoneCheck:    mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[tTOP]
                sub     eax,[tBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaT2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[tBOT]
                mov     [TValue2],eax  
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1A:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2A
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[tMID]
                sub     eax,[tBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaT1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[tBOT]    
                mov     [TValue1],eax
@@HLINE_1A:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1A
                cmp     [YStart],199
                jg      @@SkipPline_1A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_1A
                mov     ax,319
@@SkipXClip_1A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[TValue2]
                sub     eax,[TValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_1A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     esi,[PHONGTABLE]   
                mov     edx,[TValue1]
@@PLine_1A:     movzx   ebx,dx          
                shl     ebx,2
                mov     ebx,[esi + ebx] 
                mov     [edi],bl        
                add     edx,eax         
                adc     edx,0     
                inc     edi             
                dec     ecx             
                jnz     @@PLine_1A
@@SkipPline_1A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[TValue2]
                add     eax,[DeltaT2]
                adc     eax,0
                mov     [TValue2],eax
                mov     eax,[TValue1]
                add     eax,[DeltaT1]
                adc     eax,0
                mov     [TValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1A
@@Side2A:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[tTOP]
                sub     eax,[tMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaT1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[tMID]    
                mov     [TValue1],eax
@@HLINE_2A:     push    edi            
                cmp     [YStart],0
                jl      @@SkipPline_2A
                cmp     [YStart],199
                jg      @@SkipPline_2A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_2A
                mov     ax,319
@@SkipXClip_2A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[TValue2]
                sub     eax,[TValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_2A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     esi,[PHONGTABLE]        
                mov     edx,[TValue1]
@@PLine_2A:     movzx   ebx,dx          
                shl     ebx,2
                mov     ebx,[esi + ebx] 
                mov     [edi],bl        
                add     edx,eax         
                adc     edx,0           
                inc     edi             
                dec     ecx             
                jnz     @@PLine_2A
@@SkipPline_2A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[TValue2]
                add     eax,[DeltaT2]
                adc     eax,0
                mov     [TValue2],eax
                mov     eax,[TValue1]
                add     eax,[DeltaT1]
                adc     eax,0
                mov     [TValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2A
                jmp     @@DoneTriangle
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@@ChangeDirection:
                mov     ecx,[yTOP]    
                sub     ecx,[yBOT]     
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax  
                mov     eax,[tTOP]
                sub     eax,[tBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16        
                mov     [DeltaT2],eax   
                mov     eax,[xBOT]
                mov     [XValue2],eax   
                mov     eax,[tBOT]
                mov     [TValue2],eax  
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]  
@@Side1B:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2B
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[tMID]
                sub     eax,[tBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaT1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]    
                mov     [XValue1],eax
                mov     eax,[tBOT]    
                mov     [TValue1],eax
@@HLINE_1B:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1B
                cmp     [YStart],199
                jg      @@SkipPline_1B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_1B
                mov     ax,319
@@SkipXClip_1B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[TValue1]
                sub     eax,[TValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_1B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     esi,[PHONGTABLE]        
                mov     edx,[TValue2]
@@PLine_1B:     movzx   ebx,dx          
                shl     ebx,2
                mov     ebx,[esi + ebx] 
                mov     [edi],bl        
                add     edx,eax         
                adc     edx,0           
                inc     edi             
                dec     ecx             
                jnz     @@PLine_1B
@@SkipPline_1B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[TValue2]
                add     eax,[DeltaT2]
                adc     eax,0
                mov     [TValue2],eax
                mov     eax,[TValue1]
                add     eax,[DeltaT1]
                adc     eax,0
                mov     [TValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1B
@@Side2B:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[tTOP]
                sub     eax,[tMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaT1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]    
                mov     [XValue1],eax
                mov     eax,[tMID]   
                mov     [TValue1],eax
@@HLINE_2B:     push    edi           
                cmp     [YStart],0
                jl      @@SkipPline_2B
                cmp     [YStart],199
                jg      @@SkipPline_2B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_2B
                mov     ax,319
@@SkipXClip_2B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[TValue1]
                sub     eax,[TValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_2B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     esi,[PHONGTABLE]    
                mov     edx,[TValue2]
@@PLine_2B:     movzx   ebx,dx          
                shl     ebx,2
                mov     ebx,[esi + ebx] 
                mov     [edi],bl        
                add     edx,eax         
                adc     edx,0          
                inc     edi             
                dec     ecx             
                jnz     @@PLine_2B
@@SkipPline_2B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[TValue2]
                add     eax,[DeltaT2]
                adc     eax,0
                mov     [TValue2],eax
                mov     eax,[TValue1]
                add     eax,[DeltaT1]
                adc     eax,0
                mov     [TValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2B
@@DoneTriangle: mov     esp,ebp
                pop     ebp             
                ret                 
ptriangle_      ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: texturemap256
    ;     Call: void texturemap256(x1,y1,x2,y2,x3,y3,u1,v1,u2,v2,u3,v3,texture);
    ;   Return: -
    ;    Notes: This texture maps using a linear texture mapping algorithm.
    ;           The texture map must be 256x256 in size to use this routine.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
texturemap256_  PROC    
                push    ebp             ; gota make sure we can access the
                mov     ebp,esp         ; arguments on the stack.
                컴컴
                ARG x3:DWORD, y3:DWORD, u1:DWORD, v1:DWORD, u2:DWORD, v2:DWORD, \
                    u3:DWORD, v3:DWORD, texture:DWORD;
                컴컴
                mov     [xTOP],eax
                mov     eax,edx
                mov     [xMID],ebx
                mov     ebx,ecx
                mov     ecx,[x3]        ;
                mov     [xBOT],ecx      ; xBOT=x3
                mov     ecx,[y3]        ;  ecx=y3
                mov     esi,[texture]
                mov     edx,[u1]        ; 
                mov     [uTOP],edx      ; 
                mov     edx,[u2]        ; 
                mov     [uMID],edx      ; 
                mov     edx,[u3]        ; 
                mov     [uBOT],edx      ; 
                mov     edx,[v1]        ; 
                mov     [vTOP],edx      ; 
                mov     edx,[v2]        ; 
                mov     [vMID],edx      ; 
                mov     edx,[v3]        ; 
                mov     [vBOT],edx      ;
@@yTOP_yMID:    cmp     eax,ebx         ;
                jg      @@yTOP_yBOT     ; if(yTOP<yMID)
                xchg    eax,ebx         ;   swap yTOP with yMID
                mov     edx,[xTOP]      ;   swap xTOP with xMID
                xchg    edx,[xMID]      ;   swap uTOP with uMID
                mov     [xTOP],edx      ;   swap vTOP with vMID
                mov     edx,[uTOP]      ;
                xchg    edx,[uMID]      ;
                mov     [uTOP],edx      ;
                mov     edx,[vTOP]      ;
                xchg    edx,[vMID]      ;
                mov     [vTOP],edx      ;
@@yTOP_yBOT:    cmp     eax,ecx         ;
                jg      @@yMID_yBOT     ; if(yTOP<yBOT)
                xchg    eax,ecx         ;   swap yTOP with yBOT
                mov     edx,[xTOP]      ;   swap xTOP with xBOT
                xchg    edx,[xBOT]      ;   swap uTOP with uBOT
                mov     [xTOP],edx      ;   swap vTOP with vMID
                mov     edx,[uTOP]      ;
                xchg    edx,[uBOT]      ;
                mov     [uTOP],edx      ;
                mov     edx,[vTOP]      ;
                xchg    edx,[vBOT]      ;
                mov     [vTOP],edx      ;
@@yMID_yBOT:    cmp     ebx,ecx         ;
                jg      @@DoneYCompare  ; if(yMID<yBOT)
                xchg    ebx,ecx         ;   swap yMID with yBOT
                mov     edx,[xMID]      ;   swap xMID with xBOT
                xchg    edx,[xBOT]      ;   swap uMID with uBOT
                mov     [xMID],edx      ;   swap vMID with vBOT
                mov     edx,[uMID]      ;
                xchg    edx,[uBOT]      ;
                mov     [uMID],edx      ;
                mov     edx,[vMID]      ;
                xchg    edx,[vBOT]      ;
                mov     [vMID],edx      ;
@@DoneYCompare: mov     [yTOP],eax      ; update yTOP, yMID and yBOT ready
                mov     [yMID],ebx      ; for scan conversion
                mov     [yBOT],ecx      ;
                컴컴
                mov     ecx,[yTOP]      ; Finds out which side the largest
                sub     ecx,[yBOT]      ; edge is.. Either Right or Left
                jz      @@DoneCheck
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                mov     ebx,[yMID]
                sub     ebx,[yBOT]
                imul    ebx
                idiv    ecx
                add     eax,[xBOT]
                mov     ebx,[xMID]
                cmp     eax,ebx
                jl      @@ChangeDirection
@@DoneCheck:    mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[uTOP]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaU2],eax
                mov     eax,[vTOP]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaV2],eax
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[uBOT]
                mov     [UValue2],eax
                mov     eax,[vBOT]
                mov     [VValue2],eax
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1A:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2A
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uMID]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vMID]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[uBOT]    
                mov     [UValue1],eax
                mov     eax,[vBOT]    
                mov     [VValue1],eax
@@HLINE_1A:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1A
                cmp     [YStart],199
                jg      @@SkipPline_1A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_1A
                mov     ax,319
@@SkipXClip_1A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue2]
                sub     eax,[UValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_1A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                push    ebp
                mov     ebp,eax
                mov     eax,[VValue2]
                sub     eax,[VValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                xchg    ebp,eax
                mov     ebx,[UValue1]
                mov     edx,[VValue1]
                ; ebp = deltaV  eax = deltaU  ebx = u  edx = v
@@TLine_1A:     push    ecx
                xor     ecx,ecx
                mov     ch,dl
                mov     cl,bl
                mov     cl,[esi + ecx]
                mov     [edi],cl
                inc     edi
                pop     ecx
                add     ebx,eax
                adc     ebx,0
                add     edx,ebp
                adc     edx,0
                dec     ecx
                jnz     @@TLine_1A
                pop     ebp
@@SkipPline_1A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1A
@@Side2A:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uTOP]
                sub     eax,[uMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vTOP]
                sub     eax,[vMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[uMID]    
                mov     [UValue1],eax
                mov     eax,[vMID]    
                mov     [VValue1],eax
@@HLINE_2A:     push    edi            
                cmp     [YStart],0
                jl      @@SkipPline_2A
                cmp     [YStart],199
                jg      @@SkipPline_2A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_2A
                mov     ax,319
@@SkipXClip_2A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue2]
                sub     eax,[UValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_2A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                push    ebp
                mov     ebp,eax
                mov     eax,[VValue2]
                sub     eax,[VValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                xchg    ebp,eax
                mov     ebx,[UValue1]
                mov     edx,[VValue1]
                ; ebp = deltaV  eax = deltaU  ebx = u  edx = v
@@TLine_2A:     push    ecx
                xor     ecx,ecx
                mov     ch,dl
                mov     cl,bl
                mov     cl,[esi + ecx]
                mov     [edi],cl
                inc     edi
                pop     ecx
                add     ebx,eax
                adc     ebx,0
                add     edx,ebp
                adc     edx,0
                dec     ecx
                jnz     @@TLine_2A
                pop     ebp
@@SkipPline_2A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2A
                jmp     @@DoneTriangle
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@@ChangeDirection:
                mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[uTOP]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaU2],eax
                mov     eax,[vTOP]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaV2],eax
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[uBOT]
                mov     [UValue2],eax
                mov     eax,[vBOT]
                mov     [VValue2],eax
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1B:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2B
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uMID]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vMID]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[uBOT]    
                mov     [UValue1],eax
                mov     eax,[vBOT]    
                mov     [VValue1],eax
@@HLINE_1B:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1B
                cmp     [YStart],199
                jg      @@SkipPline_1B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_1B
                mov     ax,319
@@SkipXClip_1B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue1]
                sub     eax,[UValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_1B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                push    ebp
                mov     ebp,eax
                mov     eax,[VValue1]
                sub     eax,[VValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                xchg    ebp,eax
                mov     ebx,[UValue2]
                mov     edx,[VValue2]
                ; ebp = deltaV  eax = deltaU  ebx = u  edx = v
@@TLine_1B:     push    ecx
                xor     ecx,ecx
                mov     ch,dl
                mov     cl,bl
                mov     cl,[esi + ecx]
                mov     [edi],cl
                inc     edi
                pop     ecx
                add     ebx,eax
                adc     ebx,0
                add     edx,ebp
                adc     edx,0
                dec     ecx
                jnz     @@TLine_1B
                pop     ebp
@@SkipPline_1B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_1B
@@Side2B:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uTOP]
                sub     eax,[uMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vTOP]
                sub     eax,[vMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[uMID]    
                mov     [UValue1],eax
                mov     eax,[vMID]    
                mov     [VValue1],eax
@@HLINE_2B:     push    edi            
                cmp     [YStart],0
                jl      @@SkipPline_2B
                cmp     [YStart],199
                jg      @@SkipPline_2B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_2B
                mov     ax,319
@@SkipXClip_2B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue1]
                sub     eax,[UValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_2B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                push    ebp
                mov     ebp,eax
                mov     eax,[VValue1]
                sub     eax,[VValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                xchg    ebp,eax
                mov     ebx,[UValue2]
                mov     edx,[VValue2]
                ; ebp = deltaV  eax = deltaU  ebx = u  edx = v
@@TLine_2B:     push    ecx
                xor     ecx,ecx
                mov     ch,dl
                mov     cl,bl
                mov     cl,[esi + ecx]
                mov     [edi],cl
                inc     edi
                pop     ecx
                add     ebx,eax
                adc     ebx,0
                add     edx,ebp
                adc     edx,0
                dec     ecx
                jnz     @@TLine_2B
                pop     ebp
@@SkipPline_2B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                dec     [YCounter]
                jnz     @@HLINE_2B
@@DoneTriangle: mov     esp,ebp
                pop     ebp             
                ret                 
texturemap256_  ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: phongtexturemap256
    ;     Call: void phongtexturemap256(x1,y1,x2,y2,x3,y3,u1,v1,u2,v2,u3,v3,
    ;                texture,envmap,shadetbl);
    ;   Return: -
    ;    Notes: This texture maps using a linear texture mapping algorithm.
    ;           The texture map must be 256x256 in size to use this routine.
    ;           An enviroment map is used to fake phong. The env map must be
    ;           the same size as the texture map
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
phongtexturemap256_  PROC    
                push    ebp             ; gota make sure we can access the
                mov     ebp,esp         ; arguments on the stack.
                컴컴
                ARG x3:DWORD, y3:DWORD, u1:DWORD, v1:DWORD, u2:DWORD, v2:DWORD, \
                    u3:DWORD, v3:DWORD, lu1:DWORD, lv1:DWORD, lu2:DWORD, lv2:DWORD, \
                    lu3:DWORD, lv3:DWORD, texture:DWORD, envmap:DWORD, shadetbl:DWORD;
                컴컴
                mov     esi,[envmap]
                mov     [xTOP],eax
                mov     eax,edx
                mov     [xMID],ebx
                mov     ebx,ecx
                mov     ecx,[x3]        ;
                mov     [xBOT],ecx      ; xBOT=x3
                mov     ecx,[y3]        ;  ecx=y3
                mov     edx,[u1]        ; 
                mov     [uTOP],edx      ; 
                mov     edx,[u2]        ; 
                mov     [uMID],edx      ; 
                mov     edx,[u3]        ; 
                mov     [uBOT],edx      ; 
                mov     edx,[v1]        ; 
                mov     [vTOP],edx      ; 
                mov     edx,[v2]        ; 
                mov     [vMID],edx      ; 
                mov     edx,[v3]        ; 
                mov     [vBOT],edx      ;
                mov     edx,[lu1]
                mov     [luTOP],edx
                mov     edx,[lu2]
                mov     [luMID],edx
                mov     edx,[lu3]
                mov     [luBOT],edx
                mov     edx,[lv1]
                mov     [lvTOP],edx
                mov     edx,[lv2]
                mov     [lvMID],edx
                mov     edx,[lv3]
                mov     [lvBOT],edx
@@yTOP_yMID:    cmp     eax,ebx         ;
                jg      @@yTOP_yBOT     ; if(yTOP<yMID)
                xchg    eax,ebx         ;   swap yTOP with yMID
                mov     edx,[xTOP]      ;   swap xTOP with xMID
                xchg    edx,[xMID]      ;   swap uTOP with uMID
                mov     [xTOP],edx      ;   swap vTOP with vMID
                mov     edx,[uTOP]      ;
                xchg    edx,[uMID]      ;
                mov     [uTOP],edx      ;
                mov     edx,[vTOP]      ;
                xchg    edx,[vMID]      ;
                mov     [vTOP],edx      ;
                mov     edx,[luTOP]      ;
                xchg    edx,[luMID]      ;
                mov     [luTOP],edx      ;
                mov     edx,[lvTOP]      ;
                xchg    edx,[lvMID]      ;
                mov     [lvTOP],edx      ;
@@yTOP_yBOT:    cmp     eax,ecx         ;
                jg      @@yMID_yBOT     ; if(yTOP<yBOT)
                xchg    eax,ecx         ;   swap yTOP with yBOT
                mov     edx,[xTOP]      ;   swap xTOP with xBOT
                xchg    edx,[xBOT]      ;   swap uTOP with uBOT
                mov     [xTOP],edx      ;   swap vTOP with vMID
                mov     edx,[uTOP]      ;
                xchg    edx,[uBOT]      ;
                mov     [uTOP],edx      ;
                mov     edx,[vTOP]      ;
                xchg    edx,[vBOT]      ;
                mov     [vTOP],edx      ;
                mov     edx,[luTOP]      ;
                xchg    edx,[luBOT]      ;
                mov     [luTOP],edx      ;
                mov     edx,[lvTOP]      ;
                xchg    edx,[lvBOT]      ;
                mov     [lvTOP],edx      ;
@@yMID_yBOT:    cmp     ebx,ecx         ;
                jg      @@DoneYCompare  ; if(yMID<yBOT)
                xchg    ebx,ecx         ;   swap yMID with yBOT
                mov     edx,[xMID]      ;   swap xMID with xBOT
                xchg    edx,[xBOT]      ;   swap uMID with uBOT
                mov     [xMID],edx      ;   swap vMID with vBOT
                mov     edx,[uMID]      ;
                xchg    edx,[uBOT]      ;
                mov     [uMID],edx      ;
                mov     edx,[vMID]      ;
                xchg    edx,[vBOT]      ;
                mov     [vMID],edx      ;
                mov     edx,[luMID]      ;
                xchg    edx,[luBOT]      ;
                mov     [luMID],edx      ;
                mov     edx,[lvMID]      ;
                xchg    edx,[lvBOT]      ;
                mov     [lvMID],edx      ;
@@DoneYCompare: mov     [yTOP],eax      ; update yTOP, yMID and yBOT ready
                mov     [yMID],ebx      ; for scan conversion
                mov     [yBOT],ecx      ;
                컴컴
                mov     ecx,[yTOP]      ; Finds out which side the largest
                sub     ecx,[yBOT]      ; edge is.. Either Right or Left
                jz      @@DoneCheck
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                mov     ebx,[yMID]
                sub     ebx,[yBOT]
                imul    ebx
                idiv    ecx
                add     eax,[xBOT]
                mov     ebx,[xMID]
                cmp     eax,ebx
                jl      @@ChangeDirection
@@DoneCheck:    mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[uTOP]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaU2],eax
                mov     eax,[vTOP]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaV2],eax
                mov     eax,[lvTOP]
                sub     eax,[lvBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaLV2],eax
                mov     eax,[luTOP]
                sub     eax,[luBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaLU2],eax
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[uBOT]
                mov     [UValue2],eax
                mov     eax,[vBOT]
                mov     [VValue2],eax
                mov     eax,[luBOT]
                mov     [LUValue2],eax
                mov     eax,[lvBOT]
                mov     [LVValue2],eax
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1A:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2A
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uMID]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vMID]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[luMID]
                sub     eax,[luBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLU1],eax
                mov     eax,[lvMID]
                sub     eax,[lvBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLV1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[uBOT]    
                mov     [UValue1],eax
                mov     eax,[vBOT]    
                mov     [VValue1],eax
                mov     eax,[luBOT]    
                mov     [LUValue1],eax
                mov     eax,[lvBOT]    
                mov     [LVValue1],eax
@@HLINE_1A:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1A
                cmp     [YStart],199
                jg      @@SkipPline_1A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_1A
                mov     ax,319
@@SkipXClip_1A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue2]
                sub     eax,[UValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_1A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaU],eax
                mov     eax,[VValue2]
                sub     eax,[VValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaV],eax
                mov     eax,[LVValue2]
                sub     eax,[LVValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLV],eax
                mov     eax,[LUValue2]
                sub     eax,[LUValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLU],eax
                mov     eax,[UValue1]
                mov     [TmpU],eax
                mov     eax,[VValue1]
                mov     [TmpV],eax
                mov     eax,[LUValue1]
                mov     [TmpLU],eax
                mov     eax,[LVValue1]
                mov     [TmpLV],eax
@@TLine_1A:     push    ecx
                xor     ecx,ecx
                xor     ebx,ebx
                xor     edx,edx
                mov     esi,[texture]
                mov     eax,[TmpV]
                mov     ch,al
                mov     eax,[TmpU]
                mov     cl,al
                mov     bl,[esi + ecx]  ; bl = colour
                mov     esi,[envmap]
                mov     eax,[TmpLV]
                mov     ch,al
                mov     eax,[TmpLU]
                mov     cl,al
                mov     dl,[esi + ecx]  ; dl = shade
                mov     esi,[shadetbl]
                shl     ebx,7
                add     edx,ebx
                mov     al,[esi + edx]  ; al = colour to plot
                mov     [edi],al
                inc     edi
                pop     ecx
                mov     eax,[DeltaU]
                add     [TmpU],eax
                adc     [TmpU],0
                mov     eax,[DeltaV]
                add     [TmpV],eax
                adc     [TmpV],0
                mov     eax,[DeltaLU]
                add     [TmpLU],eax
                adc     [TmpLU],0
                mov     eax,[DeltaLV]
                add     [TmpLV],eax
                adc     [TmpLV],0
                dec     ecx
                jnz     @@TLine_1A
@@SkipPline_1A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                mov     eax,[DeltaLU1]
                add     [LUValue1],eax
                adc     [LUValue1],0
                mov     eax,[DeltaLU2]
                add     [LUValue2],eax
                adc     [LUValue2],0
                mov     eax,[DeltaLV1]
                add     [LVValue1],eax
                adc     [LVValue1],0
                mov     eax,[DeltaLV2]
                add     [LVValue2],eax
                adc     [LVValue2],0
                dec     [YCounter]
                jnz     @@HLINE_1A
@@Side2A:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uTOP]
                sub     eax,[uMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vTOP]
                sub     eax,[vMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[lvTOP]
                sub     eax,[lvMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLV1],eax
                mov     eax,[luTOP]
                sub     eax,[luMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLU1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[uMID]    
                mov     [UValue1],eax
                mov     eax,[vMID]    
                mov     [VValue1],eax
                mov     eax,[luMID]    
                mov     [LUValue1],eax
                mov     eax,[lvMID]    
                mov     [LVValue1],eax
@@HLINE_2A:     push    edi            
                cmp     [YStart],0
                jl      @@SkipPline_2A
                cmp     [YStart],199
                jg      @@SkipPline_2A
                mov     eax,[XValue2]
                cmp     ax,319
                jle     @@SkipXClip_2A
                mov     ax,319
@@SkipXClip_2A: mov     ebx,[XValue1]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2A
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue2]
                sub     eax,[UValue1]
                shl     eax,16
                mov     edx,[XValue2]
                mov     ebx,[XValue1]
                sub     dx,bx
                jz      @@SkipPline_2A
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaU],eax
                mov     eax,[VValue2]
                sub     eax,[VValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaV],eax
                mov     eax,[LVValue2]
                sub     eax,[LVValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLV],eax
                mov     eax,[LUValue2]
                sub     eax,[LUValue1]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLU],eax
                mov     eax,[UValue1]
                mov     [TmpU],eax
                mov     eax,[VValue1]
                mov     [TmpV],eax
                mov     eax,[LUValue1]
                mov     [TmpLU],eax
                mov     eax,[LVValue1]
                mov     [TmpLV],eax
@@TLine_2A:     push    ecx
                xor     ecx,ecx
                xor     ebx,ebx
                xor     edx,edx
                mov     esi,[texture]
                mov     eax,[TmpV]
                mov     ch,al
                mov     eax,[TmpU]
                mov     cl,al
                mov     bl,[esi + ecx]  ; bl = colour
                mov     esi,[envmap]
                mov     eax,[TmpLV]
                mov     ch,al
                mov     eax,[TmpLU]
                mov     cl,al
                mov     dl,[esi + ecx]  ; dl = shade
                mov     esi,[shadetbl]
                shl     ebx,7
                add     edx,ebx
                mov     al,[esi + edx]  ; al = colour to plot
                mov     [edi],al
                inc     edi
                pop     ecx
                mov     eax,[DeltaU]
                add     [TmpU],eax
                adc     [TmpU],0
                mov     eax,[DeltaV]
                add     [TmpV],eax
                adc     [TmpV],0
                mov     eax,[DeltaLU]
                add     [TmpLU],eax
                adc     [TmpLU],0
                mov     eax,[DeltaLV]
                add     [TmpLV],eax
                adc     [TmpLV],0
                dec     ecx
                jnz     @@TLine_2A
@@SkipPline_2A: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                mov     eax,[DeltaLU1]
                add     [LUValue1],eax
                adc     [LUValue1],0
                mov     eax,[DeltaLU2]
                add     [LUValue2],eax
                adc     [LUValue2],0
                mov     eax,[DeltaLV1]
                add     [LVValue1],eax
                adc     [LVValue1],0
                mov     eax,[DeltaLV2]
                add     [LVValue2],eax
                adc     [LVValue2],0
                dec     [YCounter]
                jnz     @@HLINE_2A
                jmp     @@DoneTriangle
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
@@ChangeDirection:
                mov     ecx,[yTOP]    
                sub     ecx,[yBOT]      
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaX2],eax   
                mov     eax,[uTOP]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaU2],eax
                mov     eax,[vTOP]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaV2],eax
                mov     eax,[lvTOP]
                sub     eax,[lvBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaLV2],eax
                mov     eax,[luTOP]
                sub     eax,[luBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16         
                mov     [DeltaLU2],eax
                mov     eax,[xBOT]
                mov     [XValue2],eax  
                mov     eax,[uBOT]
                mov     [UValue2],eax
                mov     eax,[vBOT]
                mov     [VValue2],eax
                mov     eax,[luBOT]
                mov     [LUValue2],eax
                mov     eax,[lvBOT]
                mov     [LVValue2],eax
                mov     edi,[yBOT]      
                mov     [YStart],edi
                lea     edi,[edi+edi*4]
                shl     edi,6
                add     edi,[vpage]    
@@Side1B:       mov     ecx,[yMID]   
                sub     ecx,[yBOT]
                jz      @@Side2B
                mov     eax,[xMID]
                sub     eax,[xBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uMID]
                sub     eax,[uBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vMID]
                sub     eax,[vBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[luMID]
                sub     eax,[luBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLU1],eax
                mov     eax,[lvMID]
                sub     eax,[lvBOT]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLV1],eax
                mov     eax,[yMID]   
                sub     eax,[yBOT]
                mov     [YCounter],eax
                mov     eax,[xBOT]      
                mov     [XValue1],eax
                mov     eax,[uBOT]    
                mov     [UValue1],eax
                mov     eax,[vBOT]    
                mov     [VValue1],eax
                mov     eax,[luBOT]    
                mov     [LUValue1],eax
                mov     eax,[lvBOT]    
                mov     [LVValue1],eax
@@HLINE_1B:     push    edi             
                cmp     [YStart],0
                jl      @@SkipPline_1B
                cmp     [YStart],199
                jg      @@SkipPline_1B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_1B
                mov     ax,319
@@SkipXClip_1B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_1B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue1]
                sub     eax,[UValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_1B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaU],eax
                mov     eax,[VValue1]
                sub     eax,[VValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaV],eax
                mov     eax,[LVValue1]
                sub     eax,[LVValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLV],eax
                mov     eax,[LUValue1]
                sub     eax,[LUValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLU],eax
                mov     eax,[UValue2]
                mov     [TmpU],eax
                mov     eax,[VValue2]
                mov     [TmpV],eax
                mov     eax,[LUValue2]
                mov     [TmpLU],eax
                mov     eax,[LVValue2]
                mov     [TmpLV],eax
@@TLine_1B:     push    ecx
                xor     ecx,ecx
                xor     ebx,ebx
                xor     edx,edx
                mov     esi,[texture]
                mov     eax,[TmpV]
                mov     ch,al
                mov     eax,[TmpU]
                mov     cl,al
                mov     bl,[esi + ecx]  ; bl = colour
                mov     esi,[envmap]
                mov     eax,[TmpLV]
                mov     ch,al
                mov     eax,[TmpLU]
                mov     cl,al
                mov     dl,[esi + ecx]  ; dl = shade
                mov     esi,[shadetbl]
                shl     ebx,7
                add     edx,ebx
                mov     al,[esi + edx]  ; al = colour to plot
                mov     [edi],al
                inc     edi
                pop     ecx
                mov     eax,[DeltaU]
                add     [TmpU],eax
                adc     [TmpU],0
                mov     eax,[DeltaV]
                add     [TmpV],eax
                adc     [TmpV],0
                mov     eax,[DeltaLU]
                add     [TmpLU],eax
                adc     [TmpLU],0
                mov     eax,[DeltaLV]
                add     [TmpLV],eax
                adc     [TmpLV],0
                dec     ecx
                jnz     @@TLine_1B
@@SkipPline_1B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                mov     eax,[DeltaLU1]
                add     [LUValue1],eax
                adc     [LUValue1],0
                mov     eax,[DeltaLU2]
                add     [LUValue2],eax
                adc     [LUValue2],0
                mov     eax,[DeltaLV1]
                add     [LVValue1],eax
                adc     [LVValue1],0
                mov     eax,[DeltaLV2]
                add     [LVValue2],eax
                adc     [LVValue2],0
                dec     [YCounter]
                jnz     @@HLINE_1B
@@Side2B:       mov     ecx,[yTOP]  
                sub     ecx,[yMID]
                jz      @@DoneTriangle
                mov     eax,[xTOP]
                sub     eax,[xMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaX1],eax
                mov     eax,[uTOP]
                sub     eax,[uMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaU1],eax
                mov     eax,[vTOP]
                sub     eax,[vMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaV1],eax
                mov     eax,[lvTOP]
                sub     eax,[lvMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLV1],eax
                mov     eax,[luTOP]
                sub     eax,[luMID]
                shl     eax,16
                cdq
                idiv    ecx
                ror     eax,16
                mov     [DeltaLU1],eax
                mov     eax,[yTOP]    
                sub     eax,[yMID]
                mov     [YCounter],eax
                mov     eax,[xMID]     
                mov     [XValue1],eax
                mov     eax,[uMID]    
                mov     [UValue1],eax
                mov     eax,[vMID]    
                mov     [VValue1],eax
                mov     eax,[luMID]    
                mov     [LUValue1],eax
                mov     eax,[lvMID]    
                mov     [LVValue1],eax
@@HLINE_2B:     push    edi            
                cmp     [YStart],0
                jl      @@SkipPline_2B
                cmp     [YStart],199
                jg      @@SkipPline_2B
                mov     eax,[XValue1]
                cmp     ax,319
                jle     @@SkipXClip_2B
                mov     ax,319
@@SkipXClip_2B: mov     ebx,[XValue2]
                movzx   edx,bx
                sub     ax,bx
                js      @@SkipPline_2B
                inc     ax
                movzx   ecx,ax
                add     edi,edx
                mov     eax,[UValue1]
                sub     eax,[UValue2]
                shl     eax,16
                mov     edx,[XValue1]
                mov     ebx,[XValue2]
                sub     dx,bx
                jz      @@SkipPline_2B
                movzx   ebx,dx
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaU],eax
                mov     eax,[VValue1]
                sub     eax,[VValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaV],eax
                mov     eax,[LVValue1]
                sub     eax,[LVValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLV],eax
                mov     eax,[LUValue1]
                sub     eax,[LUValue2]
                shl     eax,16
                cdq
                idiv    ebx
                ror     eax,16
                mov     [DeltaLU],eax
                mov     eax,[UValue2]
                mov     [TmpU],eax
                mov     eax,[VValue2]
                mov     [TmpV],eax
                mov     eax,[LUValue2]
                mov     [TmpLU],eax
                mov     eax,[LVValue2]
                mov     [TmpLV],eax
@@TLine_2B:     push    ecx
                xor     ecx,ecx
                xor     ebx,ebx
                xor     edx,edx
                mov     esi,[texture]
                mov     eax,[TmpV]
                mov     ch,al
                mov     eax,[TmpU]
                mov     cl,al
                mov     bl,[esi + ecx]  ; bl = colour
                mov     esi,[envmap]
                mov     eax,[TmpLV]
                mov     ch,al
                mov     eax,[TmpLU]
                mov     cl,al
                mov     dl,[esi + ecx]  ; dl = shade
                mov     esi,[shadetbl]
                shl     ebx,7
                add     edx,ebx
                mov     al,[esi + edx]  ; al = colour to plot
                mov     [edi],al
                inc     edi
                pop     ecx
                mov     eax,[DeltaU]
                add     [TmpU],eax
                adc     [TmpU],0
                mov     eax,[DeltaV]
                add     [TmpV],eax
                adc     [TmpV],0
                mov     eax,[DeltaLU]
                add     [TmpLU],eax
                adc     [TmpLU],0
                mov     eax,[DeltaLV]
                add     [TmpLV],eax
                adc     [TmpLV],0
                dec     ecx
                jnz     @@TLine_2B
@@SkipPline_2B: pop     edi
                add     edi,320
                inc     [YStart]
                mov     eax,[XValue2]
                add     eax,[DeltaX2]
                adc     eax,0
                mov     [XValue2],eax
                mov     eax,[XValue1]
                add     eax,[DeltaX1]
                adc     eax,0
                mov     [XValue1],eax
                mov     eax,[UValue2]
                add     eax,[DeltaU2]
                adc     eax,0
                mov     [UValue2],eax
                mov     eax,[UValue1]
                add     eax,[DeltaU1]
                adc     eax,0
                mov     [UValue1],eax
                mov     eax,[VValue2]
                add     eax,[DeltaV2]
                adc     eax,0
                mov     [VValue2],eax
                mov     eax,[VValue1]
                add     eax,[DeltaV1]
                adc     eax,0
                mov     [VValue1],eax
                mov     eax,[DeltaLU1]
                add     [LUValue1],eax
                adc     [LUValue1],0
                mov     eax,[DeltaLU2]
                add     [LUValue2],eax
                adc     [LUValue2],0
                mov     eax,[DeltaLV1]
                add     [LVValue1],eax
                adc     [LVValue1],0
                mov     eax,[DeltaLV2]
                add     [LVValue2],eax
                adc     [LVValue2],0
                dec     [YCounter]
                jnz     @@HLINE_2B
@@DoneTriangle: mov     esp,ebp
                pop     ebp             
                ret                 
phongtexturemap256_  ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: motionclear
    ;     Call: void motionclear(step)
    ;   Return: -
    ;    Notes: used for motion blur
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
motionclear_    PROC
                mov     ebx,eax
                mov     esi,[vpage]
                mov     ecx,64000
@@Show:         mov     al,[esi]
                sub     al,bl
                jns     @@Zappit
                mov     al,0
@@Zappit:       mov     [esi],al
                inc     esi
                dec     ecx
                jnz     @@Show
                ret
motionclear_    ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: dotproduct
    ;     Call: long dotproduct(*vector1, *vector2);
    ;   Return: the dot product of 2 unit vectors
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
dotproduct_     PROC
                mov     esi,eax         ; ESI -> v
                mov     edi,edx         ; EDI -> w
                mov     eax,[esi]       ; EAX = vX
                imul    dword ptr [edi] ;          
                shrd    eax,edx,8       ;
                mov     ebx,eax         ; EBX = vX * wX
                mov     eax,[esi+4]     ; EAX = vY
                imul    dword ptr [edi+4]         
                shrd    eax,edx,8       ;
                add     ebx,eax         ; EBX = (vX * wX) + (vY * wY)
                mov     eax,[esi+8]     ;
                imul    dword ptr [edi+8] 
                shrd    eax,edx,8       ;
                add     eax,ebx         ; EAX = (vX * wX + vY * wY + vZ * wZ)
                컴컴                    ; EAX = return value in 8.8 fixed 
                ret
dotproduct_     ENDP
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: initmatrix
    ;     Call: void initmatrix(xan, yan, zan);
    ;   Return: -
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
initmatrix_     PROC
                mov     ecx,eax
                shl     ecx,2
                mov     eax,[COSTABLE + ecx]
                mov     [CosX],eax
                mov     eax,[SINTABLE + ecx]
                mov     [SinX],eax
                mov     ecx,edx       ; setup Y angle
                shl     ecx,2
                mov     eax,[COSTABLE + ecx]
                mov     [CosY],eax
                mov     eax,[SINTABLE + ecx]
                mov     [SinY],eax
                shl     ebx,2
                mov     eax,[COSTABLE + ebx]
                mov     [CosZ],eax
                mov     eax,[SINTABLE + ebx]
                mov     [SinZ],eax
                컴컴
                mov     eax,[CosZ]      ; calc Matrix[0]
                imul    [CosY]
                mov     ebx,eax
                mov     eax,[SinX]
                imul    [SinZ]
                sar     eax,8
                imul    [SinY]
                add     eax,ebx
                sar     eax,8
                mov     [Matrix],eax
                mov     eax,[CosY]      ; calc Matrix[1]
                neg     eax
                imul    [SinZ]
                mov     ebx,eax
                mov     eax,[CosZ]
                imul    [SinX]
                sar     eax,8
                imul    [SinY]
                add     eax,ebx
                sar     eax,8
                mov     [Matrix+4],eax
                mov     eax,[CosX]      ; calc Matrix[2]
                imul    [SinY]
                sar     eax,8
                mov     [Matrix+8],eax
                mov     eax,[SinZ]      ; calc Matrix[3]
                imul    [CosX]
                sar     eax,8
                mov     [Matrix+12],eax
                mov     eax,[CosZ]      ; calc Matrix[4]
                imul    [CosX]
                sar     eax,8
                mov     [Matrix+16],eax
                mov     eax,[SinX]      ; calc Matrix[5]
                neg     eax
                mov     [Matrix+20],eax
                mov     eax,[SinY]      ; calc Matrix[6]
                neg     eax
                imul    [CosZ]
                mov     ebx,eax
                mov     eax,[SinZ]
                imul    [SinX]
                sar     eax,8
                imul    [CosY]
                add     eax,ebx
                sar     eax,8
                mov     [Matrix+24],eax
                mov     eax,[SinZ]      ; calc Matrix[7]
                imul    [SinY]
                mov     ebx,eax
                mov     eax,[CosZ]
                imul    [SinX]
                sar     eax,8
                imul    [CosY]
                add     eax,ebx
                sar     eax,8
                mov     [Matrix+28],eax
                mov     eax,[CosX]      ; calc Matrix[8]
                imul    [CosY]
                sar     eax,8
                mov     [Matrix+32],eax
                mov     eax,[Matrix]
                imul    eax,[Matrix+4]
                mov     [_6mulconst],eax
                mov     eax,[Matrix+12]
                imul    eax,[Matrix+16]
                mov     [_6mulconst+4],eax
                mov     eax,[Matrix+24]
                imul    eax,[Matrix+28]
                mov     [_6mulconst+8],eax
                ret
initmatrix_     ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: inversematrix
    ;     Call: void inversematrix(*vector, *transformedvector);
    ;   Return: -
    ;    Notes: By inversing a matrix multiplication we can do a rotation
    ;           in the opposite direction.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
inversematrix_  PROC
                mov     esi,eax
                mov     edi,edx
                mov     ebx,[esi]       ; transform x-coord
                imul    ebx,[Matrix]
                mov     eax,[esi+4]
                imul    [Matrix+12]
                add     ebx,eax
                mov     eax,[esi+8]
                imul    [Matrix+24]
                add     ebx,eax
                sar     ebx,8
                mov     [edi],ebx
                mov     ebx,[esi]       ; transform y-coord
                imul    ebx,[Matrix+4]
                mov     eax,[esi+4]
                imul    [Matrix+16]
                add     ebx,eax
                mov     eax,[esi+8]
                imul    [Matrix+28]
                add     ebx,eax
                sar     ebx,8
                mov     [edi+4],ebx
                mov     ebx,[esi]       ; transform z-coord
                imul    ebx,[Matrix+8]
                mov     eax,[esi+4]
                imul    [Matrix+20]
                add     ebx,eax
                mov     eax,[esi+8]
                imul    [Matrix+32]
                add     ebx,eax
                sar     ebx,8
                mov     [edi+8],ebx
                ret
inversematrix_  ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: matrotate
    ;     Call: void matrotate(*vertices, *rotatedverts, numverts, xt,yt,zt);
    ;   Return: transforms *vertices and places the results in *rotatedverts.
    ;           also translates.
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
                xt      dd      0
matrotate_      PROC
                push    ebp
                mov     ebp,esp
                컴컴
                ARG yt:DWORD, zt:DWORD;
                컴컴
                mov     esi,eax
                mov     edi,edx
                mov     [xt],ecx
                mov     ecx,ebx
                or      ecx,ecx
                jz      @@DoneRotate
@@RotateLoop:   mov     eax,[esi]
                imul    eax,[esi+4]
                mov     [_6mulconst+12],eax
                mov     eax,[Matrix+4]
                add     eax,[esi]
                mov     ebx,[Matrix]
                add     ebx,[esi+4]
                imul    eax,ebx
                sub     eax,[_6mulconst]
                sub     eax,[_6mulconst+12]
                mov     ebx,[Matrix+8]
                imul    ebx,[esi+8]
                add     eax,ebx
                sar     eax,8
                add     eax,[xt]
                mov     [edi],eax
                mov     eax,[Matrix+16]
                add     eax,[esi]
                mov     ebx,[Matrix+12]
                add     ebx,[esi+4]
                imul    eax,ebx
                sub     eax,[_6mulconst+4]
                sub     eax,[_6mulconst+12]
                mov     ebx,[Matrix+20]
                imul    ebx,[esi+8]
                add     eax,ebx
                sar     eax,8
                add     eax,[yt]
                mov     [edi+4],eax
                mov     eax,[Matrix+28]
                add     eax,[esi]
                mov     ebx,[Matrix+24]
                add     ebx,[esi+4]
                imul    eax,ebx
                sub     eax,[_6mulconst+8]
                sub     eax,[_6mulconst+12]
                mov     ebx,[Matrix+32]
                imul    ebx,[esi+8]
                add     eax,ebx
                sar     eax,8
                add     eax,[zt]
                mov     [edi+8],eax
                add     esi,20
                add     edi,20
                dec     ecx
                jnz     @@RotateLoop
@@DoneRotate:   mov     esp,ebp
                pop     ebp
                ret
matrotate_      ENDP

    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    ; Function: quicksort
    ;     Call: quicksort(*worldlist, worlditems)
    ;   Return: -
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
quicksort_      PROC
                mov     edi,eax
                mov     ecx,edx
                dec     ecx
                mov     edx,ecx
                shl     edx,4
                push    ebp
                xor     ebp,ebp
@@SortLoop:     mov     [sindex],ebp
                mov     ebx,ebp
                add     ebx,16
@@CountLoop:    mov     eax,[edi + ebx + 8]
                mov     esi,[sindex]
                cmp     eax,[edi + esi + 8]
                jle     @@LeaveIndex
                mov     [sindex],ebx
@@LeaveIndex:   add     ebx,16
                cmp     ebx,edx
                jle     @@CountLoop
                cmp     [sindex],ebp
                je      @@DontSwap
                mov     esi,[sindex]
                mov     eax,[edi + ebp]
                xchg    eax,[edi + esi]
                mov     [edi + ebp],eax
                mov     eax,[edi + ebp + 4]
                xchg    eax,[edi + esi + 4]
                mov     [edi + ebp + 4],eax
                mov     eax,[edi + ebp + 8]
                xchg    eax,[edi + esi + 8]
                mov     [edi + ebp + 8],eax
@@DontSwap:     add     ebp,16
                dec     ecx
                cmp     ecx,0
                jg      @@SortLoop
                pop     ebp
                ret
quicksort_      ENDP

  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
debug           PROC                            ; allows me to debug the
                push    ecx
                mov     ecx,0FFFFFFFFh          ; assembler routines with
@@debugloop:    dec     ecx                     ; S-ICE/WIN
                jnz     @@debugloop             ;
                pop     ecx
                ret                             ;
debug           ENDP                            ;
                END                             ;