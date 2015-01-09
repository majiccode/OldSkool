//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         DMA CONTROLLER FUNCTIONS                         //
//                                                                          //
//                      Copyright (c) 1997 Paul Adams                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#include "dma.h"
#include "\libs\h\control.h"
#include "\libs\h\memory.h"

UBYTE   mask_reg[]  = {0x0A, 0x0A, 0x0A, 0x0A, 0xD4, 0xD4, 0xD4, 0xD4};
UBYTE   mode_reg[]  = {0x0B, 0x0B, 0x0B, 0x0B, 0xD6, 0xD6, 0xD6, 0xD6};
UBYTE   clear_reg[] = {0x0C, 0x0C, 0x0C, 0x0C, 0xD8, 0xD8, 0xD8, 0xD8};
UBYTE   page_reg[]  = {0x87, 0x83, 0x81, 0x82, 0x8F, 0x8B, 0x89, 0x8A};
UBYTE   addr_reg[]  = {0x00, 0x02, 0x04, 0x06, 0xC0, 0xC4, 0xC8, 0xCC};
UBYTE   count_reg[] = {0x01, 0x03, 0x05, 0x07, 0xC2, 0xC6, 0xCA, 0xCE};

#define LO(a)   (a & 0x00FF)
#define HI(a)   ((a >> 8) & 0x00FF)

UBYTE *DMAallocate_buffer(DMABUF *dmabuf)
{
    dmabuf->DMAbuffer_seg   = MEMdos_allocate(dmabuf->DMAbuffer_size * 2, &dmabuf->DMAbuffer_sel);
    dmabuf->DMAbuffer_offset= dmabuf->DMAbuffer_seg << 4;

    if((dmabuf->DMAbuffer_offset & 0xFFFF)>=(0x10000-dmabuf->DMAbuffer_size))
        dmabuf->DMAbuffer_offset = (dmabuf->DMAbuffer_offset & 0xFFFF0000) + 0x10000;

    dmabuf->DMAbuffer       = (UBYTE *)dmabuf->DMAbuffer_offset;
    dmabuf->DMApage         = (dmabuf->DMAbuffer_offset & 0xF0000) >> 16;

    return dmabuf->DMAbuffer;
}

void DMAfree_buffer(DMABUF *dmabuf)
{
    MEMdos_free(dmabuf->DMAbuffer_sel);
}

void DMAsetup(DMABUF *dmabuf)
{
    UBYTE   chan, c, mode, ofslo, ofshi, page, lenhi, lenlo;
    UDWORD  length;

    chan    = dmabuf->DMAchannel;
    mode    = dmabuf->DMAmode;
    ofslo   = LO(dmabuf->DMAbuffer_offset);
    ofshi   = HI(dmabuf->DMAbuffer_offset);
    page    = dmabuf->DMApage;
    length  = dmabuf->DMAlength;

    if(chan > 3)
        length >>= 1;       // 16bit dma length is divided by 2
        
    lenlo   = LO(length-1);
    lenhi   = HI(length-1);

    c = (chan <= 3) ? chan : chan-4;

    OUTW(mask_reg[chan],c + 4);        
    OUTW(clear_reg[chan],0);           
    OUTW(mode_reg[chan],c + mode);
    OUTW(page_reg[chan],page);        

    OUTW(addr_reg[chan],ofslo);     
    OUTW(addr_reg[chan],ofshi);

    OUTW(count_reg[chan],lenlo);       
    OUTW(count_reg[chan],lenhi);

    OUTW(mask_reg[chan],c);         
}

void DMApause(DMABUF *dmabuf)
{
    UBYTE   c, chan;

    chan    = dmabuf->DMAchannel;
    c = (chan <= 3) ? chan : chan-4;

    OUTB(mask_reg[chan], c|4);
}

void DMAcontiune(DMABUF *dmabuf)
{
    UBYTE   c, chan;

    chan    = dmabuf->DMAchannel;
    c = (chan <= 3) ? chan : chan-4;

    OUTB(mask_reg[chan], c);
}

void DMAstop(DMABUF *dmabuf)
{
    UBYTE   c, chan;

    chan    = dmabuf->DMAchannel;
    c = (chan <= 3) ? chan : chan-4;

    OUTB(mask_reg[chan],c | 4);
    OUTB(clear_reg[chan],0);
    OUTB(mask_reg[chan],c);
}


