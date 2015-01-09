;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ                         SYSTEM CONTROL FUNCTIONS                          บ
;บ                                version 1.0                                บ
;บ                                                                           บ
;บ                                                                           บ
;บ              Copyright (c)1997 Paul Adams aka frenzy [SPARC]              บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
            .386P
            .MODEL FLAT
             LOCALS
            .CODE

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ SYSTEM FUNCTIONS                                                          บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
            PUBLIC  SYScpuid_, ;SYSfpu_, SYSos_,

            ALIGN   4
cpu_type    dd      ?

SYScpuid_   PROC
            pushad
            mov     [cpu_type],1        ; 286?
            pushfd
            pop     eax                 
            mov     ecx,eax         
            xor     eax,40000h    
            push    eax               
            popfd                     
            pushfd                     
            pop     eax                 
            xor     eax,ecx         
            mov     [cpu_type], 2       ; 386? 
            je      end_get_cpuid
            mov     [cpu_type], 3       ; 486?     
            pushfd
            pop     eax                 
            mov     ecx,eax        
            xor     eax,200000h  
            push    eax              
            popfd                     
            pushfd                     
            pop     eax               
            xor     eax, ecx         
            je      end_get_cpuid
            mov     [cpu_type],4        ; 586
end_get_cpuid:
            popad
            mov     eax,[cpu_type]
            ret
SYScpuid_   ENDP
        
;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ TIMER FUNCTIONS                                                           บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
            PUBLIC  TMRinit_, TMRremove_, TMRgettime_, _TIME_CONSTANT

            ALIGN   4
PENTIUM     =       0
PIT         =       1
TMRtype     db      ?
_TIME_CONSTANT      dq     ?

TMRinit_    PROC
            mov     [TMRtype],al
            cmp     eax,PENTIUM
            je      @@use_p5_timer
            cmp     [VRIon],1
            jne     @@use_PIT
            mov     [TMRtype],-1
            xor     eax,eax    
            ret                
@@use_PIT:  pushad              
            push    0
            push    1193180
            fild    qword ptr [esp]
            add     esp,8
            fstp    qword ptr [_TIME_CONSTANT]
            mov     ax,900h
            int     31h         
            mov     al,34h    
            out     43h,al
            xor     ax,ax
            out     40h,al
            out     40h,al
            mov     ax,901h
            int     31h
            popad
            mov     eax,1
            ret
@@use_p5_timer:                      
            pushad
            push    2
            fild    dword ptr [esp]    
            add     esp,4              
            mov     ecx,cs:[046Ch]
            db      0Fh, 31h
            push    edx
            push    eax
            fild    qword ptr [esp]
            fchs
            add     esp,8
            add     ecx,18*2
@@wait2:    mov     ebx,cs:[046Ch]
            cmp     ebx,ecx
            jb      @@wait2
            db      0Fh, 31h
            push    edx
            push    eax
            fild    qword ptr [esp]
            add     esp,8
            faddp   st(1), st
            fdivrp  st(1)
            fstp    qword ptr [_TIME_CONSTANT]
            popad
            mov     eax,1
            ret
TMRinit_    ENDP

TMRgettime_ PROC
            pushad
            cmp     [TMRtype],PENTIUM
            je      @@do_p5_timer
            mov     edx,cs:[046Ch]
            shrd    eax,edx,16
            shr     edx,16
            xor     ax,ax
            out     43h,al
            in      al,40h
            mov     ah,al
            in      al,40h
            xchg    al,ah
            neg     ax
            push    edx
            push    eax
            fild    qword ptr [esp]
            add     esp,8
            popad
            ret
@@do_p5_timer:
            db      0Fh, 31h
            push    edx
            push    eax
            fild    qword ptr [esp]
            add     esp,8
            popad
            ret
TMRgettime_ ENDP

TMRremove_  PROC
            cmp     [TMRtype],PIT
            je      @@remove
            ret
@@remove:   pushad
            mov     ax,900h
            int     31h
            mov     al,36h      
            out     43h,al
            xor     ax,ax
            out     40h,al
            out     40h,al
            mov     ax,901h
            int     31h
            popad
            ret
TMRremove_  ENDP


;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ VRI FUNCTIONS                                                             บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
            PUBLIC  VRIinit_, VRIhook_, VRIremove_, _VRItime, _VRIactive
            PUBLIC  _VRIfunc

            ALIGN   4
_VRItime    dd      ?          
_VRIactive  dd      ?          
_VRIfunc    dd      ?         
IRQ0OFF     dd      ?
IRQ0SEL     dw      ?
DATASEL     dw      ?
VRIon       db      0

VRIinit_    PROC
            pushad
            mov     ax,900h   
            int     31h
            mov     al,30h
            out     43h,al
            mov     dx,3DAh
@@invrt1:   in      al,dx
            test    al,8
            jnz     @@invrt1
@@wait1:    in      al,dx
            test    al,8
            jz      @@wait1
            xor     al,al  
            out     40h,al
            out     40h,al
@@invrt2:   in      al,dx
            test    al,8
            jnz     @@invrt2
@@wait2:    in      al,dx
            test    al,8
            jz      @@wait2
            in      al,40h
            mov     ah,al
            in      al,40h
            xchg    ah,al    
            neg     ax          
            sub     ax,0C0h    
            movzx   eax,ax
            mov     dword ptr [_VRItime],eax
            mov     al,36h    
            out     43h,al
            xor     al,al
            out     40h,al
            out     40h,al
            mov     ax,901h    
            int     31h
            popad
            ret
VRIinit_    ENDP

VRIhook_    PROC
            pushad
            mov     [VRIon],1
            mov     [_VRIfunc],0
            mov     [_VRIactive],1
            mov     ax,0400h  
            int     31h        
            mov     bl,dh
            mov     ax,0204h
            int     31h
            mov     word ptr [IRQ0SEL],cx
            mov     dword ptr [IRQ0OFF],edx
            inc     al
            mov     cx,cs
            mov     edx,offset VRI_HANDLER
            int     31h            
            mov     [DATASEL],ds
            mov     ax,900h
            int     31h      
            mov     ebx,[_VRItime]
            mov     al,30h
            out     43h,al
            mov     dx,3DAh
@@wait:     in      al,dx
            test    al,8
            jz      @@wait
@@invrt:    in      al,dx
            test    al,8
            jnz     @@invrt
            mov     al,bl
            out     40h,al
            mov     al,bh
            out     40h,al
            mov     ax,901h
            int     31h
            popad
            ret
VRIhook_    ENDP

VRIremove_  PROC
            pushad
            mov     [VRIon],0
            mov     ax,900h
            int     31h
            mov     al,36h   
            out     43h,al
            xor     al,al
            out     40h,al
            out     40h,al
            mov     ax,0400h  
            int     31h        
            mov     bl,dh
            mov     ax,0205h
            mov     cx,word ptr [IRQ0SEL]
            mov     edx,dword ptr [IRQ0OFF]
            int     31h
            mov     ax,901h
            int     31h
            popad
            ret
VRIremove_  ENDP

VRI_HANDLER PROC
            pushad
            pushfd
            push    ds
            mov     ax,cs:[DATASEL]
            mov     ds,ax
            mov     dx,3DAh
            in      al,dx
            test    al,8
            jz      $-3
            mov     eax,[_VRItime]
            out     40h,al
            mov     al,ah
            out     40h,al
            mov     al,20h
            out     20h,al
            sti
            mov     [_VRIactive],0
            mov     edx,[_VRIfunc]
            test    edx,edx
            jz      @@no_func
            call    edx
@@no_func:  mov     [_VRIactive],1
            pop     ds
            popfd
            popad
            iretd
VRI_HANDLER ENDP

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ KBD FUNCTIONS                                                             บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
            PUBLIC  KBDhook_, KBDremove_, KBDgetkey_, KBDpressed_, KBDflush_
            PUBLIC  _KBDbuffer, _KBDkeys, _KBDhit

            ALIGN   4

_KBDbuffer  dd      OFFSET KBDbuffer
_KBDkeys    dd      OFFSET KBDkeys

KBDbuffer   db      256 dup(?)
KBDkeys     db      256 dup(?)
KBDbuffer_head      dd      ?
KBDbuffer_tail      dd      ?
KBDbuffer_ptr       dd      ?

_KBDhit     db      ?

extended    dd      ?

IRQ1OFF     dd      ?
IRQ1SEL     dw      ?

KBDhook_    PROC
            pushad
            mov     ax,0400h
            int     31h        
            mov     bl,dh
            inc     bl
            mov     ax,0204h
            int     31h
            mov     word ptr [IRQ1SEL],cx
            mov     dword ptr [IRQ1OFF],edx
            inc     al
            mov     cx,cs
            mov     edx,offset KBD_HANDLER
            int     31h            
            mov     [DATASEL],ds
            call    KBDflush_
            popad
            ret
KBDhook_    ENDP

KBDremove_  PROC
            pushad
            mov     ax,0400h
            int     31h        
            mov     bl,dh
            inc     bl
            mov     ax,0205h
            mov     cx,word ptr [IRQ1SEL]
            mov     edx,dword ptr [IRQ1OFF]
            int     31h
            popad
            ret
KBDremove_  ENDP

KBDgetkey_  PROC
            xor     eax,eax
            mov     ebx,[KBDbuffer_head]
            mov     al,[KBDbuffer + ebx]
            inc     eax
            inc     ebx
            cmp     ebx,256
            jb      @@ok
            xor     ebx,ebx
@@ok:       mov     [KBDbuffer_head],ebx
            ret
KBDgetkey_  ENDP

KBDpressed_ PROC
            movzx   ax,byte ptr [KBDkeys + eax]
            movzx   eax,ax
            ret
KBDpressed_ ENDP
            
KBDflush_   PROC
            push    eax
            push    ecx
            push    edi
            mov     [KBDbuffer_head],0
            mov     [KBDbuffer_tail],255
            mov     [KBDbuffer_ptr],0
            mov     [_KBDhit],0
            mov     [extended],0
            xor     eax,eax
            mov     ecx,256 / 2
            mov     edi,offset KBDbuffer
            repz    stosd
            pop     edi
            pop     ecx
            pop     eax
            ret            
KBDflush_   ENDP

KBD_HANDLER PROC
            push    eax
            push    ebx
            push    edx
            push    ebp
            push    ds
            mov     ax,cs:[DATASEL]
            mov     ds,ax
            xor     eax,eax
            in      al,60h
            
            cmp     al,0E0h
            je      @@extended

            mov     bl,al
            shr     bl,7
            xor     bl,1
            and     al,01111111b

            mov     edx,[extended]
            shl     edx,7

            mov     [_KBDhit],0

            mov     [KBDkeys + edx + eax],bl
            test    bl,bl
            jz      @@done

            mov     [_KBDhit],1

            mov     ebp,[KBDbuffer_ptr]
            cmp     ebp,256
            jae     @@overflow

            add     ebp,[KBDbuffer_head]
            cmp     ebp,256
            jb      @@addchar
            add     ebp,-256
            add     ebp,[KBDbuffer_head]

@@addchar:  add     eax,edx            
            mov     ds:[KBDbuffer + ebp],al
            inc     [KBDbuffer_ptr]
@@overflow: mov     [extended],0
            jmp     @@done

            mov     [extended],0
            jmp     @@done

@@extended: mov     [extended],1

@@done:     pop     ds
            pop     ebp
            pop     edx
            pop     ebx
            mov     al,20h
            out     20h,al
            pop     eax
            iretd
KBD_HANDLER ENDP

            END
