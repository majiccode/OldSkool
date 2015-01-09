.386P
.MODEL FLAT
 LOCALS
.CODE


PUBLIC  Blit8BIT_LFB_;
PUBLIC  Blit15BIT_LFB_;
PUBLIC  Blit16BIT_LFB_;
PUBLIC  Blit24BIT_LFB_;
PUBLIC  Blit32BIT_LFB_;


SURFACE_s       STRUC
    driver      dd      ?
    mode        dd      ?
    xsize       dw      ?
    ysize       dw      ?
    bpp         db      ?
    surf        dd      ?
    lfb         dd      ?
    pal         dd      ?
    num_pages   db      ?
    page_size   dd      ?
    writemode   dw      ?
    blit        dd      ?
SURFACE_s       ENDS


ALIGN 4


Blit8BIT_LFB_ proc
        pushad
        mov     ebx,[edi.ysize]
        mov     edx,[edi.xsize]
        mov     esi,[edi.surf]
        mov     ebp,[edi.lfb]
@@yloop:
        mov     ecx,edx
@@xloop:
        mov     eax
        

Blit8BIT_LFB_ endp

END
