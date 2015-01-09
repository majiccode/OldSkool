//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         DMA CONTROLLER FUNCTIONS                         //
//                                                                          //
//                      Copyright (c) 1997 Paul Adams                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#ifndef __DMA_C
#define __DMA_C

#include    "\libs\h\typedef.h"
#include    "\libs\h\control.h"

#define DMA_CASCADE     0xC0            // bits 7-6
#define DMA_BLOCK       0x80
#define DMA_SIGNAL      0x40
#define DMA_DEMAND      0x00
#define DMA_RESERVED    0x0C            // bits 3-2
#define DMA_READ        0x08
#define DMA_WRITE       0x04
#define DMA_VERIFY      0x00
#define DMA_AUTOINIT    0x10            // bit 4

typedef struct {
    UBYTE  *DMAbuffer;
    UDWORD  DMAbuffer_size;
    UDWORD  DMAlength;
    UDWORD  DMAbuffer_offset;
    UWORD   DMAbuffer_seg, DMAbuffer_sel;
    UBYTE   DMAchannel, DMAmode;
    UBYTE   DMApage;
    UWORD   DMAposition;
}   DMABUF;
        
UBYTE  *DMAallocate_buffer(DMABUF *dmabuf);
int     DMAfree_buffer(DMABUF *dmabuf);
void    DMAsetup(DMABUF *dmabuf);
void    DMApause(DMABUF *dmabuf);
void    DMAcontinue(DMABUF *dmabuf);
void    DMAstop(DMABUF *dmabuf);

#endif
