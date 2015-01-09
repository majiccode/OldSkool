//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         DPMI INTERFACE FUNCTIONS                         //
//                               version 1.0                                //
//                                                                          //
//                      Copyright (c) 1997 Paul Adams                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#ifndef __DPMI_H
#define __DPMI_H

#include    "\libs\h\typedef.h"

#define     DPMI_INT        0x31

typedef struct {
    UBYTE   MajorVersion, MinorVersion;
    UWORD   Flags;
    UBYTE   CPUtype;
    UBYTE   PICmaster, PICslave;
}   DPMI_VERSION;

typedef struct {
    UDWORD      edi, esi, ebp, reserved, ebx, edx, ecx, eax;
    UWORD       flags, es, ds, fs, gs, ip, cs, sp, ss;
}   RMS;


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// LDT DESCRIPTER FUNCTIONS                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UWORD   DPMIallocate_desc(void);
void    DPMIfree_desc(UWORD sel);
UWORD   DPMIseg_to_sel(UWORD seg);
UDWORD  DPMIget_sel_base(UWORD sel);
void    DPMIset_sel_base(UWORD sel, UDWORD base);
void    DPMIset_seg_limit(UWORD sel, UDWORD limit);
void    DPMIset_rights(UWORD sel, UWORD rights);
void    DPMIcreate_code_alias(UWORD sel);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// INTERRUPT FUNCTIONS                                                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UDWORD  DPMIget_realmode_int(UWORD i);
void    DPMIset_realmode_int(UWORD i, UWORD seg, UWORD off);
void    DPMIget_pmode_int(UWORD i, UWORD *sel, UDWORD *off);
void    DPMIset_pmode_int(UWORD i, UWORD sel, UDWORD off);
void    DPMIsim_realmode_int(UWORD i, RMS *r);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMORY FUNCTIONS                                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UWORD   DPMIdos_allocate(int size, uword *selector);
void    DPMIdos_free(uword selector);
UDWORD  DPMImap_physical(UDWORD addr, UDWORD size);
void    DPMIunmap_physical(UDWORD addr);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MISC FUNCTIONS                                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
DPMI_VERSION *DPMIget_version(void);

#endif
