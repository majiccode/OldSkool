#ifndef __VGA_H
#define __VGA_H

#include    "\libs\h\typedef.h"

uchar       *VGAbuffer  = (uchar *)0xA0000;
uword       VGAxmin     = 0;
uword       VGAxmax     = 320;
uword       VGAymin     = 0;
uword       VGAymax     = 200;

void VGAset_mode(int mode);
#pragma aux VGAset_mode =\
    "int    10h"\
parm [eax] modify [eax];

void VGAset_colour(UBYTE col, UBYTE r, UBYTE g, UBYTE b);
#pragma aux VGAset_colour =\
    "mov    dx,3C8h"\
    "out    dx,al"\
    "inc    dx"\
    "mov    al,ah"\
    "out    dx,al"\
    "mov    al,bl"\
    "out    dx,al"\
    "mov    al,bh"\
    "out    dx,al"\
parm [al][ah][bl][bh] modify [eax ebx edx];

UDWORD VGAget_colour(UBYTE col);
#pragma aux VGAget_colour =\
    "mov    dx,3C7h"\
    "out    dx,al"\
    "mov    dx,3C9h"\
    "in     al,dx"\
    "shl    eax,8"\
    "in     al,dx"\
    "shl    eax,8"\
    "in     al,dx"\
parm [eax] value [eax] modify [edx];

void VGAset_palette(UBYTE *pal);
#pragma aux VGAset_palette =\
    "mov    dx,3C8h"\
    "xor    al,al"\
    "out    dx,al"\
    "inc    dx"\
    "mov    cx,256"\
"setpal:"\
    "mov    al,[edi]"\
    "out    dx,al"\
    "mov    al,[edi+1]"\
    "out    dx,al"\
    "mov    al,[edi+2]"\
    "out    dx,al"\
    "add    edi,3"\
    "dec    cx"\
    "jnz    setpal"\
parm [edi] modify [edi eax edx ecx];

void VGAget_palette(UBYTE *pal);
#pragma aux VGAget_palette =\
    "mov    dx,3C7h"\
    "xor    al,al"\
    "out    dx,al"\
    "mov    dx,3C9h"\
    "mov    cx,256"\
"getpal:"\
    "in     al,dx"\
    "mov    [edi],al"\
    "in     al,dx"\
    "mov    [edi+1],al"\
    "in     al,dx"\
    "mov    [edi+2],al"\
    "add    edi,3"\
    "dec    cx"\
    "jnz    getpal"\
parm [edi] modify [edi eax edx ecx];

void VGAblank_palette(void);
#pragma aux VGAblank_palette =\
    "mov    dx,3C8h"\
    "xor    al,al"\
    "out    dx,al"\
    "inc    dx"\
    "mov    cx,256"\
"blankpal:"\
    "out    dx,al"\
    "out    dx,al"\
    "out    dx,al"\
    "dec    cx"\
    "jnz    blankpal"\
modify [eax edx ecx];

void VGAwait_no_vr(void);
#pragma aux VGAwait_no_vr =\
    "mov    dx,03DAh"\
"nvr:"\
    "in     al,dx"\
    "test   al,8"\
    "jnz    nvr"\
modify [eax edx];

void VGAwait_vr(void);
#pragma aux VGAwait_vr =\
    "mov    dx,03DAh"\
"vr:"\
    "in     al,dx"\
    "test   al,8"\
    "jz     vr"\
modify [eax edx];

void VGAwait_hr(void);
#pragma aux VGAwait_hr =\
    "mov    dx,03DAh"\
"hr:"\
    "in     al,dx"\
    "test   al,1"\
    "jnz    hr"\
modify [eax edx];

void VGAclear_screen(UBYTE *buf);
#pragma aux VGAclear_screen =\
    "mov    ecx,16000"\
    "cld"\
    "xor    eax,eax"\
    "rep    stosd"\
parm [edi] modify [eax ecx edi];

void VGAcopy_screen(UBYTE *buf, UBYTE *dest);
#pragma aux VGAcopy_screen =\
    "mov    ecx,16000"\
    "cld"\
    "rep    movsd"\
parm [esi] [edi] modify [ecx esi edi];

void VGAset_border(UBYTE c);
#pragma aux VGAset_border =\
    "test   bl,bl"\
    "jz     l1"\
    "test   byte ptr ds:[417h],1"\
    "jz     bye"\
"l1:"\
    "mov    dx,03DAh"\
    "in     al,dx"\
    "mov    dx,03C0h"\
    "mov    al,31h"\
    "out    dx,al"\
    "mov    al,bl"\
    "out    dx,al"\
"bye:"\
parm [ebx] modify [eax edx];

#endif
