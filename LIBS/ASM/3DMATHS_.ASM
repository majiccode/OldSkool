; ***************************************************************************
; *                                                                         *
; *                 FPU Matrix/Vector Routines for Fluid3D                  *
; *                                                                         *
; *-------------------------------------------------------------------------*
; *                                                                         *
; *  author(s): frenzy                                                      *
; *                                                                         *
; *  last revision: 26/2/97                                                 *
; *                                                                         *
; *  releated files: 3dmaths.c, 3dmaths.h                                   *
; *                                                                         *
; *                                                                         *
; *  updates:                                                               *
; *  --------                                                               *
; *                                                                         *
; *                                                                         *
; *                                                                         *
; *                                                                         *
; *                                                                         *
; ***************************************************************************

        .386P
        .MODEL FLAT
         LOCALS
        .CODE

        ; misc routines

        PUBLIC  MATH_init_fpu_;

        ; 2x1 Vector Routines:

        PUBLIC  VEC2_zero_, VEC2_copy_, VEC2_add_, VEC2_sub_;
        PUBLIC  VEC2_inverse_, VEC2_dot_, VEC2_length_;
        PUBLIC  VEC2_norm_, VEC2_equal_, VEC2_rotate_;

        ; 3x1 Vector Routines:

        PUBLIC  VEC3_zero_, VEC3_copy_, VEC3_add_, VEC3_sub_;
        PUBLIC  VEC3_inverse_, VEC3_dot_, VEC3_cross_, VEC3_length_;
        PUBLIC  VEC3_norm_, VEC3_equal_, VEC3_rotate_;

        ; 3x3 Matrix Routines:

        PUBLIC  MAT3_ident_, MAT3_copy_, MAT3_transpose_;
        PUBLIC  MAT3_xrot_, MAT3_yrot_, MAT3_zrot_, MAT3_xyzrot_;
        PUBLIC  MAT3_setup7mul_, MAT3_mul_, MAT3_vecmul_;
        PUBLIC  MAT3_transform_;

        ; 4x4 Matrix Routines:

        PUBLIC  MAT4_ident_, MAT4_copy_, MAT4_transpose_;
        PUBLIC  MAT4_xrot_, MAT4_yrot_, MAT4_zrot_, MAT4_xyzrot_;
        PUBLIC  MAT4_setup7mul_, MAT4_mul_, MAT4_vecmul_;
        PUBLIC  MAT4_transform_;


        ; varibles located in 3dmaths.h

        EXTRN   _sintable:DWORD, _costable:DWORD;

        align   4

; fpu vars
dummy           dw      ?
controlword     dw      ?

; constants for 7mul rotation system
AxAy            dd      ?
BxBy            dd      ?
CxCy            dd      ?
xy              dd      ?

; temp matrix
temp3x3         dd      3*3 dup(?)
temp4x4         dd      4*4 dup(?)

; temp vars
temp            dd      ?
temp2           dd      ?

;*****************************************************************************
; MATH_init_fpu
;
;     in: EAX = precision
;                   0 = (fast)24bits, 1=(med)53bits. 2=(slow)64bits
;*****************************************************************************
MATH_init_fpu_  PROC

        finit
        fstcw   [controlword]
        mov     bx,[controlword]
        and     bh,0FCh                 ; mask out bits 8 and 9
        or      bh,al                   ; set required precision
        mov     [controlword],bx
        fldcw   [controlword]
        ret

MATH_init_fpu_  ENDP

;*****************************************************************************
; VEC2_zero:                   
;                                  
;     in: EAX -> 2x1 vector
;
;*****************************************************************************
VEC2_zero_      PROC

        fldz
        fst     dword ptr [eax]
        fstp    dword ptr [eax+4]
        ret
                        
VEC2_zero_      ENDP

;*****************************************************************************
; VEC2_copy:                   
;                                  
;     in: EAX -> dest 2x1 vector
;         EBX -> source 2x1 vector
;
;*****************************************************************************
VEC2_copy_      PROC

        fld     dword ptr [ebx]
        fld     dword ptr [ebx+4]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC2_copy_      ENDP

;*****************************************************************************
; VEC2_add:                    
;                                  
;     in: EAX -> dest 2x1 vector
;         EBX -> v1
;         ECX -> v2
;
;*****************************************************************************
VEC2_add_       PROC

        fld     dword ptr [ebx]
        fadd    dword ptr [ecx]
        fld     dword ptr [ebx+4]
        fadd    dword ptr [ecx+4]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC2_add_       ENDP

;*****************************************************************************
; VEC2_sub:                    
;                                  
;     in: EAX -> dest 2x1 vector
;         EBX -> v1
;         ECX -> v2
;
;*****************************************************************************
VEC2_sub_       PROC

        fld     dword ptr [ebx]
        fsub    dword ptr [ecx]
        fld     dword ptr [ebx+4]
        fsub    dword ptr [ecx+4]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC2_sub_       ENDP

;*****************************************************************************
; VEC2_inverse:                
;                                  
;     in: EAX -> 2x1 vector
;
;*****************************************************************************
VEC2_inverse_   PROC

        fld     dword ptr [eax]
        fchs
        fld     dword ptr [eax+4]
        fchs
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC2_inverse_   ENDP

;*****************************************************************************
; VEC2_dot:                
;                                  
;     in: EAX -> 2x1 vector
;         EBX -> 2x1 vector
;
;*****************************************************************************
VEC2_dot_       PROC

        fld     dword ptr [eax]
        fmul    dword ptr [ebx]
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+4]
        faddp   st(1)                   
        ret                             ; watcom pops of value from fpu :)
                        
VEC2_dot_       ENDP


;*****************************************************************************
; VEC2_length:             
;                                  
;     in: EAX -> v1
;
;*****************************************************************************
VEC2_length_    PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax]
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+4]
        faddp   st(1)
        fsqrt                           ; eeekk...
        ret                             
                        
VEC2_length_    ENDP

;*****************************************************************************
; VEC2_norm:               
;                                  
;     in: EAX -> v1
;
;*****************************************************************************
VEC2_norm_      PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax]
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+4]
        faddp   st(1)
        fsqrt                           ; oh no..
        fld     dword ptr [eax]
        fld     dword ptr [eax+4]
        fdiv    st,st(2)
        fstp    dword ptr [eax+4]
        fdiv    st,st(1)
        fstp    dword ptr [eax]
        ret
                        
VEC2_norm_      ENDP

;*****************************************************************************
; VEC2_equal:              
;                                  
;     in: EAX -> v1
;         EBX -> v2
;
;*****************************************************************************
VEC2_equal_     PROC

        mov     ecx,[eax]
        cmp     [ebx],ecx
        jne     @@notequal
        mov     ecx,[eax+4]
        cmp     [ebx+4],ecx
        jne     @@notequal
        mov     eax,1
        ret
@@notequal:
        xor     eax,eax
        ret
                        
VEC2_equal_     ENDP

;*****************************************************************************
; VEC2_rotate:             
;                                  
;     in: EAX -> vector
;         EBX =  angle
;
;*****************************************************************************
VEC2_rotate_    PROC

        fld     [_costable+ebx*4]
        fmul    dword ptr [eax]
        fld     [_sintable+ebx*4]
        fmul    dword ptr [eax+4]
        fld     [_sintable+ebx*4]
        fmul    dword ptr [eax]
        fld     [_costable+ebx*4]
        fmul    dword ptr [eax+4]
        faddp   st(1)
        fstp    dword ptr [eax+4]
        fsubp   st(1)
        fstp    dword ptr [eax]

        ret
                        
VEC2_rotate_    ENDP



;*****************************************************************************
; VEC3_zero:                   
;                                  
;     in: EAX -> 3x1 vector
;
;*****************************************************************************
VEC3_zero_      PROC

        fldz
        fst     dword ptr [eax]
        fst     dword ptr [eax+4]
        fstp    dword ptr [eax+8]
        ret
                        
VEC3_zero_      ENDP

;*****************************************************************************
; VEC3_copy:                   
;                                  
;     in: EAX -> dest 3x1 vector
;         EBX -> source 3x1 vector
;
;*****************************************************************************
VEC3_copy_      PROC

        fld     dword ptr [ebx]
        fld     dword ptr [ebx+4]
        fld     dword ptr [ebx+8]
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC3_copy_      ENDP

;*****************************************************************************
; VEC3_add:                    
;                                  
;     in: EAX -> dest 3x1 vector
;         EBX -> v1
;         ECX -> v2
;
;*****************************************************************************
VEC3_add_       PROC

        fld     dword ptr [ebx]
        fadd    dword ptr [ecx]
        fld     dword ptr [ebx+4]
        fadd    dword ptr [ecx+4]
        fld     dword ptr [ebx+8]
        fadd    dword ptr [ecx+8]
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC3_add_       ENDP

;*****************************************************************************
; VEC3_sub:                    
;                                  
;     in: EAX -> dest 3x1 vector
;         EBX -> v1
;         ECX -> v2
;
;*****************************************************************************
VEC3_sub_       PROC

        fld     dword ptr [ebx]
        fsub    dword ptr [ecx]
        fld     dword ptr [ebx+4]
        fsub    dword ptr [ecx+4]
        fld     dword ptr [ebx+8]
        fsub    dword ptr [ecx+8]
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC3_sub_       ENDP

;*****************************************************************************
; VEC3_inverse:                
;                                  
;     in: EAX -> 3x1 vector
;
;*****************************************************************************
VEC3_inverse_   PROC

        fld     dword ptr [eax]
        fchs
        fld     dword ptr [eax+4]
        fchs
        fld     dword ptr [eax+8]
        fchs
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]
        ret
                        
VEC3_inverse_   ENDP

;*****************************************************************************
; VEC3_dot:                
;                                  
;     in: EAX -> 3x1 vector
;         EBX -> 3x1 vector
;
;*****************************************************************************
VEC3_dot_       PROC

        fld     dword ptr [eax]
        fmul    dword ptr [ebx]
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+4]
        fxch                            ; ux*vx | uy*vy  
        fld     dword ptr [eax+8]
        fmul    dword ptr [ebx+8]
        fxch                            ; ux*vx | uz*vz | uy*vy
        faddp   st(2)
        faddp   st(1)                   
        ret                             ; watcom pops of value from fpu :)
                        
VEC3_dot_       ENDP

;*****************************************************************************
; VEC3_cross:              
;                                  
;     in: EAX -> dest vector
;         EBX -> v1         
;         ECX -> v2
;
;*****************************************************************************
VEC3_cross_     PROC

        fld     dword ptr [ebx+4]
        fmul    dword ptr [ecx+8]       ; v1x*v2z
        fld     dword ptr [ebx+8]
        fmul    dword ptr [ecx+4]       ; v1x*v2z | v1z*v2y
        fld     dword ptr [ebx+8]
        fmul    dword ptr [ecx]         ; v1z*v2x | v1x*v2z | v1z*v2y
        fld     dword ptr [ebx]
        fmul    dword ptr [ecx+8]       ; v1x*v2z | v1z*v2x | v1x*v2z | v1z*v2y
        fld     dword ptr [ebx]
        fmul    dword ptr [ecx+4]       ; v1x*v2y | ...
        fld     dword ptr [ebx+4]
        fmul    dword ptr [ecx]         ; v1y*v2x | ...
        fsubp   st(1)
        fstp    dword ptr [eax+8]
        fsubp   st(1)
        fstp    dword ptr [eax+4]
        fsubp   st(1)
        fstp    dword ptr [eax]
        ret                           
                        
VEC3_cross_     ENDP

;*****************************************************************************
; VEC3_length:             
;                                  
;     in: EAX -> v1
;
;*****************************************************************************
VEC3_length_    PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax]
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+4]
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+8]
        faddp   st(2)
        faddp   st(1)
        fsqrt                           ; eeekk...
        ret                             
                        
VEC3_length_    ENDP

;*****************************************************************************
; VEC3_norm:               
;                                  
;     in: EAX -> v1
;
;*****************************************************************************
VEC3_norm_      PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax]
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+4]
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+8]
        faddp   st(2)
        faddp   st(1)
        fsqrt                           ; oh no..
        fld     dword ptr [eax]
        fld     dword ptr [eax+4]
        fld     dword ptr [eax+8]
        fdiv    st,st(3)
        fstp    dword ptr [eax+8]
        fdiv    st,st(2)
        fstp    dword ptr [eax+4]
        fdiv    st,st(1)
        fstp    dword ptr [eax]
        ret
                        
VEC3_norm_      ENDP

;*****************************************************************************
; VEC3_equal:              
;                                  
;     in: EAX -> v1
;         EBX -> v2
;
;*****************************************************************************
VEC3_equal_     PROC

        mov     ecx,[eax]
        cmp     [ebx],ecx
        jne     @@notequal
        mov     ecx,[eax+4]
        cmp     [ebx+4],ecx
        jne     @@notequal
        mov     ecx,[eax+8]
        cmp     [ebx+8],ecx
        jne     @@notequal
        mov     eax,1
        ret
@@notequal:
        xor     eax,eax
        ret
                        
VEC3_equal_     ENDP

;*****************************************************************************
; VEC3_rotate:             
;                                  
;     in: EAX -> vector
;         EBX =  xan, ECX = yan, EDX = zan
;
;*****************************************************************************
VEC3_rotate_    PROC

        fld     [_costable+ebx*4]
        fmul    dword ptr [eax+4]
        fld     [_sintable+ebx*4]
        fmul    dword ptr [eax+8]
        fld     [_sintable+ebx*4]
        fmul    dword ptr [eax+4]
        fld     [_costable+ebx*4]
        fmul    dword ptr [eax+8]
        faddp   st(1)
        fstp    dword ptr [eax+8]
        fsubp   st(1)
        fstp    dword ptr [eax+4]

        fld     [_costable+ecx*4]
        fmul    dword ptr [eax]
        fld     [_sintable+ecx*4]
        fmul    dword ptr [eax+8]
        fld     [_sintable+ecx*4]
        fmul    dword ptr [eax]
        fld     [_costable+ecx*4]
        fmul    dword ptr [eax+8]
        faddp   st(1)
        fstp    dword ptr [eax+8]
        fsubp   st(1)
        fstp    dword ptr [eax]

        fld     [_costable+edx*4]
        fmul    dword ptr [eax]
        fld     [_sintable+edx*4]
        fmul    dword ptr [eax+4]
        fld     [_sintable+edx*4]
        fmul    dword ptr [eax]
        fld     [_costable+edx*4]
        fmul    dword ptr [eax+4]
        faddp   st(1)
        fstp    dword ptr [eax+4]
        fsubp   st(1)
        fstp    dword ptr [eax]

        ret
                        
VEC3_rotate_    ENDP

;*****************************************************************************
; MAT3_ident:                  
;                                  
;     in: EAX -> 3x3 matrix
;
;*****************************************************************************
MAT3_ident_     PROC

        fldz
        fld1
        fst     dword ptr [eax]
        fst     dword ptr [eax + 16]
        fstp    dword ptr [eax + 32]
        fst     dword ptr [eax + 4]
        fst     dword ptr [eax + 8]
        fst     dword ptr [eax + 12]
        fst     dword ptr [eax + 20]
        fst     dword ptr [eax + 24]
        fstp    dword ptr [eax + 28]
        ret

MAT3_ident_  ENDP
        
;*****************************************************************************
; MAT3_copy:
;
;     in: EAX -> source 3x3 matrix   
;         EBX -> destination 3x3 matrix
;
;*****************************************************************************
MAT3_copy_      PROC

        fld     dword ptr [eax]         
        fld     dword ptr [eax+4]       
        fld     dword ptr [eax+8]       
        fstp    dword ptr [ebx+8]       
        fstp    dword ptr [ebx+4]       
        fstp    dword ptr [ebx]         

        fld     dword ptr [eax+12]
        fld     dword ptr [eax+16]
        fld     dword ptr [eax+20]
        fstp    dword ptr [ebx+20]
        fstp    dword ptr [ebx+16]
        fstp    dword ptr [ebx+12]

        fld     dword ptr [eax+24]
        fld     dword ptr [eax+28]
        fld     dword ptr [eax+32]
        fstp    dword ptr [ebx+32]
        fstp    dword ptr [ebx+28]
        fstp    dword ptr [ebx+24]
        ret

MAT3_copy_      ENDP

;*****************************************************************************
; MAT3_transpose:
;
;     in: EAX -> 3x3 matrix   
;
;*****************************************************************************
MAT3_transpose_ PROC

        fld     dword ptr [eax+4]
        fld     dword ptr [eax+12]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax+12]

        fld     dword ptr [eax+8]
        fld     dword ptr [eax+24]
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+24]

        fld     dword ptr [eax+20]
        fld     dword ptr [eax+28]
        fstp    dword ptr [eax+20]
        fstp    dword ptr [eax+28]
        ret

MAT3_transpose_ ENDP

;*****************************************************************************
; MAT3_xrot:
;
;     in: EAX -> 3x3 matrix   
;         EBX = xangle in degrees
;
;*****************************************************************************
MAT3_xrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax+16]
        fstp    dword ptr [eax+32]
        fst     dword ptr [eax+20]
        fchs
        fstp    dword ptr [eax+28]
        ret

MAT3_xrot_      ENDP

;*****************************************************************************
; MAT3_yrot:
;
;     in: EAX -> 3x3 matrix   
;         EBX = yangle in degrees
;
;*****************************************************************************
MAT3_yrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax]
        fstp    dword ptr [eax+32]
        fst     dword ptr [eax+24]
        fchs
        fstp    dword ptr [eax+8]
        ret

MAT3_yrot_      ENDP

;*****************************************************************************
; MAT3_zrot:
;
;     in: EAX -> 3x3 matrix   
;         EBX = zangle in degrees
;
;*****************************************************************************
MAT3_zrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax]
        fstp    dword ptr [eax+16]
        fst     dword ptr [eax+4]
        fchs
        fstp    dword ptr [eax+12]
        ret

MAT3_zrot_      ENDP


;*****************************************************************************
; MAT3_xyzrot:
;
;     in: EAX -> 3x3 matrix   
;         EBX = xan, ECX = yan, EDX = zan  (in degrees)
;
; precalc'd expresions for xyz rotation matrix:
;
;       cy*cz              cy*sz          -sy         Ax  Bx  Cx
; sx*sy*cz - cx*sz   sx*sy*sz + cx*cz    sx*cy  ==    Ay  By  Cy
; cx*sy*cz + sx*sz   cx*sy*sz - sx*cz    cx*cy        Az  Bz  Cz
;
; extra expressions calculated for 7-mul rotation:
;
; Ax*Ay, Bx*By, Cx*Cy
; 
;*****************************************************************************
MAT3_xyzrot_    PROC

        fld     [_costable+ecx*4]       ; pipeline???
        fmul    [_costable+edx*4]       ;
        fld     [_costable+ecx*4]       ;
        fmul    [_sintable+edx*4]       ;
        fld     [_sintable+ebx*4]       ;
        fmul    [_costable+ecx*4]       ;
        fld     [_costable+ebx*4]       ;
        fmul    [_costable+ecx*4]       ;
        fld     [_sintable+ecx*4]       ;
        fchs                            ;
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+32]
        fstp    dword ptr [eax+20]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]

        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+ecx*4]       ; st = sx * sy
        fld     [_costable+edx*4]       ; st = cz
        fmul    st, st(1)               ; st = sx * sy * cz
        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+edx*4]       ; st = cx * sz
        fxch
        fsubp   st(1)                   ; st = st - st(1)
        fstp    dword ptr [eax+12]      
        ffree   st                      ; must remove maybe...

        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+ecx*4]       ; st = sx * sy
        fld     [_sintable+edx*4]       ; st = sz
        fmul    st, st(1)               ; st(1) = sx * sy * sz
        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_costable+edx*4]       ; st = cx*cz
        faddp   st(1)                   ; st = st + st(1)
        fstp    dword ptr [eax+16]
        ffree   st

        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+ecx*4]       ; st = cx * sy
        fld     [_costable+edx*4]       ; st = cz
        fmul    st, st(1)               ; st(1) = cx * sy * cz
        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+edx*4]       ; st = sx*sz
        faddp   st(1)                   ; st = st + st(1)
        fstp    dword ptr [eax+24]
        ffree   st

        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+ecx*4]       ; st = cx * sy
        fld     [_sintable+edx*4]       ; st = sz
        fmul    st, st(1)               ; st = cx * sy * sz
        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_costable+edx*4]       ; st = sx * cz
        fxch
        fsubp   st(1)                   ; st = st - st(1)
        fstp    dword ptr [eax+28]      
        ffree   st                                         

        fld     dword ptr [eax]
        fmul    dword ptr [eax+12]      ; AxAy
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+16]      ; BxBy
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+20]      ; CxCy
        fxch
        fstp    dword ptr [BxBy]
        fstp    dword ptr [CxCy]
        fstp    dword ptr [AxAy]
        ret

MAT3_xyzrot_    ENDP

;*****************************************************************************
; MAT3_setup7mul:
;
;     in: EAX -> 3x3 matrix   
;
; magic numbers for 7mul rotation:                     
;
; Ax*Ay, Bx*By, Cx*Cy
; 
;*****************************************************************************
MAT3_setup7mul_ PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax+12]      ; AxAy
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+16]      ; BxBy
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+20]      ; CxCy
        fxch
        fstp    dword ptr [BxBy]
        fstp    dword ptr [CxCy]
        fstp    dword ptr [AxAy]
        ret

MAT3_setup7mul_ ENDP

;*****************************************************************************
; MAT3_mul: 
;
;     in: EAX -> dest 3x3 matrix M1    (M1*M2)
;         EBX -> source 3x3 matrix M2   
;
;
; a looping matrix multiplier might or might not be faster.. must test.
;
;*****************************************************************************
MAT3_mul_       PROC

        fld     dword ptr [eax]
        fmul    dword ptr [ebx]
        fld     dword ptr [eax+4]    
        fmul    dword ptr [ebx+12]
        fld     dword ptr [eax+8]       
        fmul    dword ptr [ebx+24]
        faddp   st(1)                   ;
        faddp   st(1)                   ; stall??
        fstp    dword ptr [temp3x3]

        fld     dword ptr [eax]        
        fmul    dword ptr [ebx+4]
        fld     dword ptr [eax+4]    
        fmul    dword ptr [ebx+16]
        fld     dword ptr [eax+8]       
        fmul    dword ptr [ebx+28]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+4]

        fld     dword ptr [eax]        
        fmul    dword ptr [ebx+8]
        fld     dword ptr [eax+4]    
        fmul    dword ptr [ebx+20]
        fld     dword ptr [eax+8]       
        fmul    dword ptr [ebx+32]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+8]

        fld     dword ptr [eax+12]        
        fmul    dword ptr [ebx]
        fld     dword ptr [eax+16]    
        fmul    dword ptr [ebx+12]
        fld     dword ptr [eax+20]       
        fmul    dword ptr [ebx+24]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+12]

        fld     dword ptr [eax+12]        
        fmul    dword ptr [ebx+4]
        fld     dword ptr [eax+16]    
        fmul    dword ptr [ebx+16]
        fld     dword ptr [eax+20]       
        fmul    dword ptr [ebx+28]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+16]

        fld     dword ptr [eax+12]        
        fmul    dword ptr [ebx+8]
        fld     dword ptr [eax+16]    
        fmul    dword ptr [ebx+20]
        fld     dword ptr [eax+20]       
        fmul    dword ptr [ebx+32]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+20]

        fld     dword ptr [eax+24]        
        fmul    dword ptr [ebx]
        fld     dword ptr [eax+28]    
        fmul    dword ptr [ebx+12]
        fld     dword ptr [eax+32]       
        fmul    dword ptr [ebx+24]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+24]

        fld     dword ptr [eax+24]        
        fmul    dword ptr [ebx+4]
        fld     dword ptr [eax+28]    
        fmul    dword ptr [ebx+16]
        fld     dword ptr [eax+32]       
        fmul    dword ptr [ebx+28]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+28]

        fld     dword ptr [eax+24]        
        fmul    dword ptr [ebx+8]
        fld     dword ptr [eax+28]    
        fmul    dword ptr [ebx+20]
        fld     dword ptr [eax+32]       
        fmul    dword ptr [ebx+32]
        faddp   st(1)
        faddp   st(1)
        fstp    dword ptr [temp3x3+32]

        fld     dword ptr [temp3x3]         
        fld     dword ptr [temp3x3+4]       
        fld     dword ptr [temp3x3+8]       
        fstp    dword ptr [eax+8]       
        fstp    dword ptr [eax+4]       
        fstp    dword ptr [eax]         
        fld     dword ptr [temp3x3+12]
        fld     dword ptr [temp3x3+16]
        fld     dword ptr [temp3x3+20]
        fstp    dword ptr [eax+20]
        fstp    dword ptr [eax+16]
        fstp    dword ptr [eax+12]
        fld     dword ptr [temp3x3+24]
        fld     dword ptr [temp3x3+28]
        fld     dword ptr [temp3x3+32]
        fstp    dword ptr [eax+32]
        fstp    dword ptr [eax+28]
        fstp    dword ptr [eax+24]

        ret

MAT3_mul_       ENDP

;*****************************************************************************
; MAT3_vecmul:
;
;     in: EAX -> 3x3 matrix                   
;         EBX -> 3x1 vector             
;         ECX -> 3x1 destination vector
;
; does 7muls to multiply vector by matrix using the 'magic' numbers setup
; by MAT3_xyzrot and/or MAT3_setup7mul
;
; notes:
;
;     Ax + By + Cz = (A+y)(B+x) - AB - xy + Cz
;                      
;     xy = constant for point being rotated (calculated at start of routine)
;     AB = constant for rotation matrix     (precalc'd by matrix setup)
;
;*****************************************************************************
MAT3_vecmul_    PROC

        fld     dword ptr [ebx+8]       

        fld     [AxAy]                  ; AxAy

        fld     dword ptr [ebx]         ;
        fmul    dword ptr [ebx+4]       ; x*y | AxAy
        fst     dword ptr [xy]          ; keep x*y for later
        fld     dword ptr [ebx]         ; x | x*y | AxAy
        fld     dword ptr [ebx+4]       ; y | x | x*y | AxAy
        fld     dword ptr [eax]         ; ax | y | x | x*y | AxAy
        fld     dword ptr [eax+12]      ; ay | ax | y | x | x*y | AxAy
        faddp   st(3)                   ; ax | y | ay+x | x*y | AxAy
        faddp   st(1)                   ; ax+y | ay+x | x*y | AxAy
        fmulp   st(1)                   ; ax+y*ay+x | x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y - AxAy
        fxch
        fmul    dword ptr [eax+24]      ; z | (ax+y)*(ay+x) - x*y - AxAy
        faddp   st(1)                   ; Az*z + (ax+y)*(ay+x) - x*y - AxAy
        fstp    dword ptr [ecx]

        fld     dword ptr [ebx+8]       
        fld     [BxBy]       
        fld     [xy]          
        fld     dword ptr [ebx]      
        fld     dword ptr [ebx+4]     
        fld     dword ptr [eax+4]      
        fld     dword ptr [eax+16]    
        faddp   st(3)                 
        faddp   st(1)                   
        fmulp   st(1)                 
        fsubp   st(1)                   
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+28]      
        faddp   st(1)                 
        fstp    dword ptr [ecx+4]

        fld     dword ptr [ebx+8]       
        fld     [CxCy]       
        fld     [xy]          
        fld     dword ptr [ebx]       
        fld     dword ptr [ebx+4]       
        fld     dword ptr [eax+8]      
        fld     dword ptr [eax+20]      
        faddp   st(3)                
        faddp   st(1)               
        fmulp   st(1)                  
        fsubp   st(1)                 
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+32]      
        faddp   st(1)                 
        fstp    dword ptr [ecx+8]

        ret

MAT3_vecmul_    ENDP

;*****************************************************************************
; MAT3_transform:
;
;     in: EAX -> 3x3 matrix                   
;         EBX -> 3x1 ptr to list of 3x1 vectors
;         EDX -> 3x1 ptr to dest list of 3x1 vectors
;         ECX =  number of vectors to transform
;
;*****************************************************************************
MAT3_transform_ PROC

        test    ecx,ecx
        jz      @@donexform

@@xform:
        
        fld     dword ptr [ebx+8]       
        fld     [AxAy]                  ; AxAy
        fld     dword ptr [ebx]         ;
        fmul    dword ptr [ebx+4]       ; x*y | AxAy
        fst     dword ptr [xy]          ; keep x*y for later
        fld     dword ptr [ebx]         ; x | x*y | AxAy
        fld     dword ptr [ebx+4]       ; y | x | x*y | AxAy
        fld     dword ptr [eax]         ; ax | y | x | x*y | AxAy
        fld     dword ptr [eax+12]      ; ay | ax | y | x | x*y | AxAy
        faddp   st(3)                   ; ax | y | ay+x | x*y | AxAy
        faddp   st(1)                   ; ax+y | ay+x | x*y | AxAy
        fmulp   st(1)                   ; ax+y*ay+x | x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y - AxAy
        fxch
        fmul    dword ptr [eax+24]      ; z | (ax+y)*(ay+x) - x*y - AxAy
        faddp   st(1)                   ; Az*z + (ax+y)*(ay+x) - x*y - AxAy
        fstp    dword ptr [edx]

        fld     dword ptr [ebx+8]       
        fld     [BxBy]       
        fld     [xy]          
        fld     dword ptr [ebx]      
        fld     dword ptr [ebx+4]     
        fld     dword ptr [eax+4]      
        fld     dword ptr [eax+16]    
        faddp   st(3)                 
        faddp   st(1)                   
        fmulp   st(1)                 
        fsubp   st(1)                   
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+28]      
        faddp   st(1)                 
        fstp    dword ptr [edx+4]

        fld     dword ptr [ebx+8]       
        fld     [CxCy]       
        fld     [xy]          
        fld     dword ptr [ebx]       
        fld     dword ptr [ebx+4]       
        fld     dword ptr [eax+8]      
        fld     dword ptr [eax+20]      
        faddp   st(3)                
        faddp   st(1)               
        fmulp   st(1)                  
        fsubp   st(1)                 
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+32]      
        faddp   st(1)                 
        fstp    dword ptr [edx+8]

        add     ebx,12
        add     edx,12
        dec     ecx
        jnz     @@xform

@@donexform:
        ret

MAT3_transform_ ENDP

;*****************************************************************************
; MAT4_ident:                  
;                                  
;     in: EAX -> 4x4 matrix
;
;*****************************************************************************
MAT4_ident_  PROC

        fldz
        fld1
        fst     dword ptr [eax]
        fst     dword ptr [eax + 20]
        fst     dword ptr [eax + 40]
        fstp    dword ptr [eax + 60]

        fst     dword ptr [eax + 4]
        fst     dword ptr [eax + 8]
        fst     dword ptr [eax + 12]
        fst     dword ptr [eax + 16]
        fst     dword ptr [eax + 24]
        fst     dword ptr [eax + 28]
        fst     dword ptr [eax + 32]
        fst     dword ptr [eax + 36]
        fst     dword ptr [eax + 44]
        fst     dword ptr [eax + 48]
        fst     dword ptr [eax + 52]
        fstp    dword ptr [eax + 56]
        ret

MAT4_ident_  ENDP
        
;*****************************************************************************
; MAT4_copy:
;
;     in: EAX -> source 4x4 matrix   
;         EBX -> destination 4x4 matrix
;
;*****************************************************************************
MAT4_copy_      PROC

        mov     ecx,8

@@copy: fild    qword ptr [eax]
        fild    qword ptr [eax+8]
        fxch
        fistp   qword ptr [ebx]
        fistp   qword ptr [ebx+8]
        add     eax,16
        add     ebx,16
        dec     ecx
        jnz     @@copy
        ret

MAT4_copy_      ENDP

;*****************************************************************************
; MAT4_transpose:
;
;     in: EAX -> 4x4 matrix   
;
;*****************************************************************************
MAT4_transpose_ PROC

        fld     dword ptr [eax+4]
        fld     dword ptr [eax+16]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax+12]

        fld     dword ptr [eax+8]
        fld     dword ptr [eax+32]
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+32]

        fld     dword ptr [eax+12]
        fld     dword ptr [eax+48]
        fstp    dword ptr [eax+12]
        fstp    dword ptr [eax+48]

        fld     dword ptr [eax+24]
        fld     dword ptr [eax+36]
        fstp    dword ptr [eax+24]
        fstp    dword ptr [eax+36]

        fld     dword ptr [eax+28]
        fld     dword ptr [eax+52]
        fstp    dword ptr [eax+28]
        fstp    dword ptr [eax+52]

        fld     dword ptr [eax+44]
        fld     dword ptr [eax+56]
        fstp    dword ptr [eax+44]
        fstp    dword ptr [eax+56]
        ret

MAT4_transpose_ ENDP

;*****************************************************************************
; MAT4_xrot:
;
;     in: EAX -> 4x4 matrix   
;         EBX = xangle in degrees
;
;*****************************************************************************
MAT4_xrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax+20]
        fstp    dword ptr [eax+40]
        fst     dword ptr [eax+24]
        fchs
        fstp    dword ptr [eax+36]
        ret

MAT4_xrot_      ENDP

;*****************************************************************************
; MAT4_yrot:
;
;     in: EAX -> 4x4 matrix   
;         EBX = yangle in degrees
;
;*****************************************************************************
MAT4_yrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax]
        fstp    dword ptr [eax+40]
        fst     dword ptr [eax+32]
        fchs
        fstp    dword ptr [eax+8]
        ret

MAT4_yrot_      ENDP

;*****************************************************************************
; MAT4_zrot:
;
;     in: EAX -> 4x4 matrix   
;         EBX = zangle in degrees
;
;*****************************************************************************
MAT4_zrot_      PROC

        fld     [_sintable+ebx*4]
        fld     [_costable+ebx*4]
        fst     dword ptr [eax]
        fstp    dword ptr [eax+20]
        fst     dword ptr [eax+4]
        fchs
        fstp    dword ptr [eax+16]
        ret

MAT4_zrot_      ENDP


;*****************************************************************************
; MAT4_xyzrot:
;
;     in: EAX -> 4x4 matrix   
;         EBX = xan, ECX = yan, EDX = zan  (in degrees)
;
; precalc'd expresions for xyz rotation matrix:
;
;       cy*cz              cy*sz          -sy         Ax  Bx  Cx
; sx*sy*cz - cx*sz   sx*sy*sz + cx*cz    sx*cy  ==    Ay  By  Cy
; cx*sy*cz + sx*sz   cx*sy*sz - sx*cz    cx*cy        Az  Bz  Cz
;
; extra expressions calculated for 7-mul rotation:
;
; Ax*Ay, Bx*By, Cx*Cy
; 
;*****************************************************************************
MAT4_xyzrot_    PROC

        fld     [_costable+ecx*4]       ; pipeline???
        fmul    [_costable+edx*4]       ;
        fld     [_costable+ecx*4]       ;
        fmul    [_sintable+edx*4]       ;
        fld     [_sintable+ebx*4]       ;
        fmul    [_costable+ecx*4]       ;
        fld     [_costable+ebx*4]       ;
        fmul    [_costable+ecx*4]       ;
        fld     [_sintable+ecx*4]       ;
        fchs                            ;
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+40]
        fstp    dword ptr [eax+24]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]

        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+ecx*4]       ; st = sx * sy
        fld     [_costable+edx*4]       ; st = cz
        fmul    st, st(1)               ; st = sx * sy * cz
        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+edx*4]       ; st = cx * sz
        fxch
        fsubp   st(1)                   ; st = st - st(1)
        fstp    dword ptr [eax+16]      
        ffree   st                      ; must remove maybe...

        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+ecx*4]       ; st = sx * sy
        fld     [_sintable+edx*4]       ; st = sz
        fmul    st, st(1)               ; st(1) = sx * sy * sz
        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_costable+edx*4]       ; st = cx*cz
        faddp   st(1)                   ; st = st + st(1)
        fstp    dword ptr [eax+20]
        ffree   st

        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+ecx*4]       ; st = cx * sy
        fld     [_costable+edx*4]       ; st = cz
        fmul    st, st(1)               ; st(1) = cx * sy * cz
        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_sintable+edx*4]       ; st = sx*sz
        faddp   st(1)                   ; st = st + st(1)
        fstp    dword ptr [eax+32]
        ffree   st

        fld     [_costable+ebx*4]       ; st = cx
        fmul    [_sintable+ecx*4]       ; st = cx * sy
        fld     [_sintable+edx*4]       ; st = sz
        fmul    st, st(1)               ; st = cx * sy * sz
        fld     [_sintable+ebx*4]       ; st = sx
        fmul    [_costable+edx*4]       ; st = sx * cz
        fxch
        fsubp   st(1)                   ; st = st - st(1)
        fstp    dword ptr [eax+36]      
        ffree   st                                         

        fld     dword ptr [eax]
        fmul    dword ptr [eax+16]      ; AxAy
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+20]      ; BxBy
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+24]      ; CxCy
        fxch
        fstp    dword ptr [BxBy]
        fstp    dword ptr [CxCy]
        fstp    dword ptr [AxAy]
        ret

MAT4_xyzrot_    ENDP

;*****************************************************************************
; MAT4_setup7mul:
;
;     in: EAX -> 4x4 matrix   
;
; magic numbers for 7mul rotation:                     
;
; Ax*Ay, Bx*By, Cx*Cy
; 
;*****************************************************************************
MAT4_setup7mul_ PROC

        fld     dword ptr [eax]
        fmul    dword ptr [eax+16]      ; AxAy
        fld     dword ptr [eax+4]
        fmul    dword ptr [eax+20]      ; BxBy
        fld     dword ptr [eax+8]
        fmul    dword ptr [eax+24]      ; CxCy
        fxch
        fstp    dword ptr [BxBy]
        fstp    dword ptr [CxCy]
        fstp    dword ptr [AxAy]
        ret

MAT4_setup7mul_ ENDP

;*****************************************************************************
; MAT4_mul: 
;
;     in: EAX -> dest 4x4 matrix M1    (M1*M2)
;         EBX -> source 4x4 matrix M2   
;
;
; a looping matrix multiplier might or might not be faster.. must test.
;
;*****************************************************************************
MAT4_mul_       PROC

        fld     dword ptr [eax]         ;
        fmul    dword ptr [ebx]         ; a
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+16]      ; b | a
        fld     dword ptr [eax+8]       ;
        fmul    dword ptr [ebx+32]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+12]
        fmul    dword ptr [ebx+48]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4]

        fld     dword ptr [eax]         ;
        fmul    dword ptr [ebx+4]       ; a
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+20]      ; b | a
        fld     dword ptr [eax+8]       ;
        fmul    dword ptr [ebx+36]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+12]
        fmul    dword ptr [ebx+52]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+4]

        fld     dword ptr [eax]         ;
        fmul    dword ptr [ebx+8]       ; a
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+24]      ; b | a
        fld     dword ptr [eax+8]       ;
        fmul    dword ptr [ebx+40]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+12]
        fmul    dword ptr [ebx+56]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+8]

        fld     dword ptr [eax]         ;
        fmul    dword ptr [ebx+12]      ; a
        fld     dword ptr [eax+4]
        fmul    dword ptr [ebx+28]      ; b | a
        fld     dword ptr [eax+8]       ;
        fmul    dword ptr [ebx+44]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+12]
        fmul    dword ptr [ebx+60]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+12]

        ; --------

        fld     dword ptr [eax+16]      ;
        fmul    dword ptr [ebx]         ; a
        fld     dword ptr [eax+20]
        fmul    dword ptr [ebx+16]      ; b | a
        fld     dword ptr [eax+24]      ;
        fmul    dword ptr [ebx+32]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+28]
        fmul    dword ptr [ebx+48]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+16]

        fld     dword ptr [eax+16]      ;
        fmul    dword ptr [ebx+4]       ; a
        fld     dword ptr [eax+20]
        fmul    dword ptr [ebx+20]      ; b | a
        fld     dword ptr [eax+24]      ;
        fmul    dword ptr [ebx+36]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+28]
        fmul    dword ptr [ebx+52]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+20]

        fld     dword ptr [eax+16]      ;
        fmul    dword ptr [ebx+8]       ; a
        fld     dword ptr [eax+20]
        fmul    dword ptr [ebx+24]      ; b | a
        fld     dword ptr [eax+24]      ;
        fmul    dword ptr [ebx+40]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+28]
        fmul    dword ptr [ebx+56]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+24]

        fld     dword ptr [eax+16]      ;
        fmul    dword ptr [ebx+12]      ; a
        fld     dword ptr [eax+20]
        fmul    dword ptr [ebx+28]      ; b | a
        fld     dword ptr [eax+24]      ;
        fmul    dword ptr [ebx+44]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+28]
        fmul    dword ptr [ebx+60]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+28]

        ; --------

        fld     dword ptr [eax+32]      ;
        fmul    dword ptr [ebx]         ; a
        fld     dword ptr [eax+36]
        fmul    dword ptr [ebx+16]      ; b | a
        fld     dword ptr [eax+40]      ;
        fmul    dword ptr [ebx+32]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+44]
        fmul    dword ptr [ebx+48]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+32]

        fld     dword ptr [eax+32]      ;
        fmul    dword ptr [ebx+4]       ; a
        fld     dword ptr [eax+36]
        fmul    dword ptr [ebx+20]      ; b | a
        fld     dword ptr [eax+40]      ;
        fmul    dword ptr [ebx+36]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+44]
        fmul    dword ptr [ebx+52]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+36]

        fld     dword ptr [eax+32]      ;
        fmul    dword ptr [ebx+8]       ; a
        fld     dword ptr [eax+36]
        fmul    dword ptr [ebx+24]      ; b | a
        fld     dword ptr [eax+40]      ;
        fmul    dword ptr [ebx+40]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+44]
        fmul    dword ptr [ebx+56]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+40]

        fld     dword ptr [eax+32]      ;
        fmul    dword ptr [ebx+12]      ; a
        fld     dword ptr [eax+36]
        fmul    dword ptr [ebx+28]      ; b | a
        fld     dword ptr [eax+40]      ;
        fmul    dword ptr [ebx+44]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+44]
        fmul    dword ptr [ebx+60]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+44]

        ; --------

        fld     dword ptr [eax+48]      ;
        fmul    dword ptr [ebx]         ; a
        fld     dword ptr [eax+52]
        fmul    dword ptr [ebx+16]      ; b | a
        fld     dword ptr [eax+56]      ;
        fmul    dword ptr [ebx+32]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+60]
        fmul    dword ptr [ebx+48]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+48]

        fld     dword ptr [eax+48]      ;
        fmul    dword ptr [ebx+4]       ; a
        fld     dword ptr [eax+52]
        fmul    dword ptr [ebx+20]      ; b | a
        fld     dword ptr [eax+56]      ;
        fmul    dword ptr [ebx+36]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+60]
        fmul    dword ptr [ebx+52]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+52]

        fld     dword ptr [eax+48]      ;
        fmul    dword ptr [ebx+8]       ; a
        fld     dword ptr [eax+52]
        fmul    dword ptr [ebx+24]      ; b | a
        fld     dword ptr [eax+56]      ;
        fmul    dword ptr [ebx+40]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+60]
        fmul    dword ptr [ebx+56]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+56]

        fld     dword ptr [eax+48]      ;
        fmul    dword ptr [ebx+12]      ; a
        fld     dword ptr [eax+52]
        fmul    dword ptr [ebx+28]      ; b | a
        fld     dword ptr [eax+56]      ;
        fmul    dword ptr [ebx+44]      ; c | b | a
        fxch                            ; b | c | a
        fld     dword ptr [eax+60]
        fmul    dword ptr [ebx+60]      ; d | b | c | a
        fxch    st(3)                   ; a | b | c | d
        faddp   st(1)                   ; a + b | c | d           
        faddp   st(1)                   ; a + b + c | d
        faddp   st(1)                   ; a + b + c + d
        fstp    dword ptr [temp4x4+60]


        fld     [temp4x4]
        fld     [temp4x4+4]
        fld     [temp4x4+8]
        fld     [temp4x4+12]
        fxch
        fstp    dword ptr [eax+8]
        fstp    dword ptr [eax+12]
        fstp    dword ptr [eax+4]
        fstp    dword ptr [eax]

        fld     [temp4x4+16]
        fld     [temp4x4+20]
        fld     [temp4x4+24]
        fld     [temp4x4+28]
        fxch
        fstp    dword ptr [eax+24]
        fstp    dword ptr [eax+28]
        fstp    dword ptr [eax+20]
        fstp    dword ptr [eax+16]

        fld     [temp4x4+32]
        fld     [temp4x4+36]
        fld     [temp4x4+40]
        fld     [temp4x4+44]
        fxch
        fstp    dword ptr [eax+40]
        fstp    dword ptr [eax+44]
        fstp    dword ptr [eax+36]
        fstp    dword ptr [eax+32]

        fld     [temp4x4+48]
        fld     [temp4x4+52]
        fld     [temp4x4+56]
        fld     [temp4x4+60]
        fxch
        fstp    dword ptr [eax+56]
        fstp    dword ptr [eax+60]
        fstp    dword ptr [eax+52]
        fstp    dword ptr [eax+48]

        ret

MAT4_mul_       ENDP

;*****************************************************************************
; MAT4_vecmul:
;
;     in: EAX -> 4x4 matrix                   
;         EBX -> 3x1 vector             
;         ECX -> 3x1 destination vector
;
; does 7muls to multiply vector by matrix using the 'magic' numbers setup
; by MAT3_xyzrot and/or MAT3_setup7mul
;
; notes:
;
;     Ax + By + Cz = (A+y)(B+x) - AB - xy + Cz
;                      
;     xy = constant for point being rotated (calculated at start of routine)
;     AB = constant for rotation matrix     (precalc'd by matrix setup)
;
;*****************************************************************************
MAT4_vecmul_    PROC

        fld     dword ptr [ebx+8]       

        fld     [AxAy]                  ; AxAy

        fld     dword ptr [ebx]         ;
        fmul    dword ptr [ebx+4]       ; x*y | AxAy
        fst     dword ptr [xy]          ; keep x*y for later
        fld     dword ptr [ebx]         ; x | x*y | AxAy
        fld     dword ptr [ebx+4]       ; y | x | x*y | AxAy
        fld     dword ptr [eax]         ; ax | y | x | x*y | AxAy
        fld     dword ptr [eax+16]      ; ay | ax | y | x | x*y | AxAy
        faddp   st(3)                   ; ax | y | ay+x | x*y | AxAy
        faddp   st(1)                   ; ax+y | ay+x | x*y | AxAy
        fmulp   st(1)                   ; ax+y*ay+x | x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y - AxAy
        fxch
        fmul    dword ptr [eax+32]      ; z | (ax+y)*(ay+x) - x*y - AxAy
        faddp   st(1)                   ; Az*z + (ax+y)*(ay+x) - x*y - AxAy
        fadd    dword ptr [eax+48]      ; add the displacement
        fstp    dword ptr [ecx]

        fld     dword ptr [ebx+8]       
        fld     [BxBy]       
        fld     [xy]          
        fld     dword ptr [ebx]      
        fld     dword ptr [ebx+4]     
        fld     dword ptr [eax+4]      
        fld     dword ptr [eax+20]    
        faddp   st(3)                 
        faddp   st(1)                   
        fmulp   st(1)                 
        fsubp   st(1)                   
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+36]      
        faddp   st(1)
        fadd    dword ptr [eax+52]
        fstp    dword ptr [ecx+4]

        fld     dword ptr [ebx+8]       
        fld     [CxCy]       
        fld     [xy]          
        fld     dword ptr [ebx]       
        fld     dword ptr [ebx+4]       
        fld     dword ptr [eax+8]      
        fld     dword ptr [eax+24]      
        faddp   st(3)                
        faddp   st(1)               
        fmulp   st(1)                  
        fsubp   st(1)                 
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+40]      
        faddp   st(1)
        fadd    dword ptr [eax+56]
        fstp    dword ptr [ecx+8]

        ret

MAT4_vecmul_    ENDP

;*****************************************************************************
; MAT4_transform:
;
;     in: EAX -> 4x4 matrix                   
;         EBX -> source 3x1 vectors
;         EDX -> destination 3x1 vectors
;         ECX =  number of vectors to transform
;
;*****************************************************************************
MAT4_transform_ PROC

        test    ecx,ecx
        jz      @@donexform

@@xform:

        fld     dword ptr [ebx+8]       
        fld     [AxAy]                  ; AxAy
        fld     dword ptr [ebx]         ;
        fmul    dword ptr [ebx+4]       ; x*y | AxAy
        fst     dword ptr [xy]          ; keep x*y for later
        fld     dword ptr [ebx]         ; x | x*y | AxAy
        fld     dword ptr [ebx+4]       ; y | x | x*y | AxAy
        fld     dword ptr [eax]         ; ax | y | x | x*y | AxAy
        fld     dword ptr [eax+16]      ; ay | ax | y | x | x*y | AxAy
        faddp   st(3)                   ; ax | y | ay+x | x*y | AxAy
        faddp   st(1)                   ; ax+y | ay+x | x*y | AxAy
        fmulp   st(1)                   ; ax+y*ay+x | x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y | AxAy
        fsubp   st(1)                   ; (ax+y)*(ay+x) - x*y - AxAy
        fxch
        fmul    dword ptr [eax+32]      ; z | (ax+y)*(ay+x) - x*y - AxAy
        faddp   st(1)                   ; Az*z + (ax+y)*(ay+x) - x*y - AxAy
        fadd    dword ptr [eax+48]      ; add the displacement
        fstp    dword ptr [edx]

        fld     dword ptr [ebx+8]       
        fld     [BxBy]       
        fld     [xy]          
        fld     dword ptr [ebx]      
        fld     dword ptr [ebx+4]     
        fld     dword ptr [eax+4]      
        fld     dword ptr [eax+20]    
        faddp   st(3)                 
        faddp   st(1)                   
        fmulp   st(1)                 
        fsubp   st(1)                   
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+36]      
        faddp   st(1)
        fadd    dword ptr [eax+52]
        fstp    dword ptr [edx+4]

        fld     dword ptr [ebx+8]       
        fld     [CxCy]       
        fld     [xy]          
        fld     dword ptr [ebx]       
        fld     dword ptr [ebx+4]       
        fld     dword ptr [eax+8]      
        fld     dword ptr [eax+24]      
        faddp   st(3)                
        faddp   st(1)               
        fmulp   st(1)                  
        fsubp   st(1)                 
        fsubp   st(1)                 
        fxch
        fmul    dword ptr [eax+40]      
        faddp   st(1)
        fadd    dword ptr [eax+56]
        fstp    dword ptr [edx+8]

        add     ebx,12
        add     edx,12
        dec     ecx
        jnz     @@xform

@@donexform:
        ret

MAT4_transform_ ENDP


                END
