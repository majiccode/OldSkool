//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         DPMI INTERFACE FUNCTIONS                         //
//                               version 1.0                                //
//                                                                          //
//                      Copyright (c) 1997 Paul Adams                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#include    <i86.h>
#include    "\libs\h\dpmi.h"

union REGS      regs;
struct SREGS    sregs;

static int DPMI_ERROR = 0;

static DPMI_VERSION dpmi_version;

UBYTE DPMIerror(void)
{
    return DPMI_ERROR;
}

UWORD DPMIallocate_desc(void)
{
    regs.w.ax = 0x0000;
    regs.w.cx = 1;  
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    return regs.w.ax;
}

void DPMIfree_desc(UWORD sel)
{
    regs.w.ax = 0x0001;
    regs.w.bx = sel;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

UWORD DPMIseg_to_sel(UWORD seg)
{
    regs.w.ax = 0x0002;
    regs.w.bx = seg;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    return regs.w.ax;
}

UDWORD DPMIget_sel_base(UWORD sel)
{
    regs.w.ax = 0x0006;
    regs.w.bx = sel;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    return ((regs.w.cx << 16) + regs.w.dx);
}

void DPMIset_sel_base(UWORD sel, UDWORD base)
{
    regs.w.ax = 0x0007;
    regs.w.bx = sel;
    regs.w.cx = base >> 16;
    regs.w.dx = base & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

void DPMIset_seg_limit(UWORD sel, UDWORD limit)
{
    regs.w.ax = 0x0008;
    regs.w.bx = sel;
    regs.w.cx = limit >> 16;
    regs.w.dx = limit & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

void DPMIset_rights(UWORD sel, UWORD rights)
{
    regs.w.ax = 0x0009;
    regs.w.bx = sel;
    regs.w.cx = rights;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

void DPMIcreate_code_alias(UWORD sel)
{
    regs.w.ax = 0x000A;
    regs.w.bx = sel;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

UDWORD DPMIget_realmode_int(UWORD i)
{
    regs.w.ax = 0x0200;
    regs.w.bx = i;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    return ((regs.w.cx<<16)+regs.w.dx);
}

void DPMIset_realmode_int(UWORD i, UWORD seg, UWORD off)
{
    regs.w.ax = 0x0201;
    regs.w.bx = i;
    regs.w.cx = seg;
    regs.w.dx = off;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

void DPMIget_pmode_int(UWORD i, UWORD *sel, UDWORD *off)
{
    regs.w.ax = 0x0204;
    regs.w.bx = i;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    *sel=regs.w.cx;
    *off=regs.x.edx;
}

void DPMIset_pmode_int(UWORD i, UWORD sel, UDWORD off)
{
    regs.w.ax = 0x0205;
    regs.w.bx = i;
    regs.w.cx = sel;
    regs.x.edx = off;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

void DPMIsim_realmode_int(UWORD i, RMS *r)
{
    regs.w.ax = 0x0300;
    regs.w.bx = i;
    regs.w.cx = 0;
    sregs.es  = FP_SEG(r);
    regs.x.edi= FP_OFF(r);
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

DPMI_VERSION *DPMIget_version(void)
{
    regs.w.ax = 0x0400;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    dpmi_version.MajorVersion   = regs.h.ah;
    dpmi_version.MinorVersion   = regs.h.al;
    dpmi_version.Flags          = regs.w.bx;
    dpmi_version.CPUtype        = regs.h.cl - 1;
    dpmi_version.PICmaster      = regs.h.dh;
    dpmi_version.PICslave       = regs.h.dl;

    return(&dpmi_version);
}

UDWORD DPMImap_physical(UDWORD addr, UDWORD size)
{
    regs.w.ax = 0x0800;
    regs.w.bx = addr >> 16;
    regs.w.cx = addr & 0x0000FFFF;
    regs.w.si = size >> 16;
    regs.w.di = size & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;

    return ((regs.w.bx<<16)+regs.w.cx);
}

void DPMIunmap_physical(UDWORD addr)
{
    regs.w.ax = 0x0801;
    regs.w.bx = addr >> 16;
    regs.w.cx = addr & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);
    DPMI_ERROR = regs.w.cflag;
}

