#include <dos.h>
#include "vga.h"
#include "vesa.h"

static VESAINFO *vesainfo;
static uword    vesainfo_seg, vesainfo_sel;
static MODEINFO *modeinfo;
static uword    modeinfo_seg, modeinfo_sel;
static uword    *modelist;
static RMS      rms;
union  REGS     regs;
struct SREGS    sregs;

VESAset_display_start_t VESAset_display_start;
VESAset_bank_t          VESAset_bank;

static ubyte    *pmcode = NULL;
static void     *pm_set_display_start;
static void     *pm_set_bank;

uword DPMIdos_allocate(int size, uword *selector)
{
    uword       ptr = NULL;

    regs.w.ax  =0x100;
    regs.w.bx  =((size+15) & 0xFFFFFFF0) >> 4;;
    int386(DPMI_INT, &regs, &regs);

    if(regs.x.cflag == 0) {
        *selector=regs.w.dx;
        ptr=regs.w.ax;
    }

    return(ptr);
}

void DPMIdos_free(uword selector)
{
    regs.w.ax=0x101;
    regs.w.dx=selector;
    int386(DPMI_INT, &regs, &regs);
}

void DPMIsim_realmode_int(uword i, RMS *r)
{
    regs.w.ax = 0x0300;
    regs.w.bx = i;
    regs.w.cx = 0;
    sregs.es  = FP_SEG(r);
    regs.x.edi= FP_OFF(r);
    int386(DPMI_INT, &regs, &regs);
}

udword DPMImap_physical(udword addr, udword size)
{
    regs.w.ax = 0x0800;
    regs.w.bx = addr >> 16;
    regs.w.cx = addr & 0x0000FFFF;
    regs.w.si = size >> 16;
    regs.w.di = size & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);

    return ((regs.w.bx<<16)+regs.w.cx);
}    

void DPMIunmap_physical(udword addr)
{
    regs.w.ax = 0x0801;
    regs.w.bx = addr >> 16;
    regs.w.cx = addr & 0x0000FFFF;
    int386(DPMI_INT, &regs, &regs);
}

//---------------------------------------------------------------------------

void RMset_display_start(int x, int y)
{
    rms.eax = 0x4F07;
    rms.ebx = 0;
    rms.ecx = x;
    rms.edx = y;
    DPMIsim_realmode_int(0x10, &rms);
}

void RMset_bank(int bank)
{
    rms.eax = 0x4F05;
    rms.ebx = 0;
    rms.edx = bank*(64/modeinfo->WinGranularity);
    DPMIsim_realmode_int(0x10, &rms);
}

void PMset_display_start(int x, int y)
{
    printf("protected mode set display start called\n");
}

void PMset_bank(int bank)
{
    printf("protected mode set bank called\n");
}

int VESAdetect(void)
{
    uword   *pm_interface;

    vesainfo_seg = DPMIdos_allocate(sizeof(VESAINFO), &vesainfo_sel);
    vesainfo = (VESAINFO *)((udword)vesainfo_seg << 4);
    if(!vesainfo_seg)
        return VESAERR_NO_DOS_MEM;

    rms.eax = 0x4F00;
    rms.es  = vesainfo_seg;
    DPMIsim_realmode_int(0x10, &rms);
    if(rms.eax != 0x4F) {
        DPMIdos_free(vesainfo_sel);
        return VESAERR_NO_VESA;
    }

    modeinfo_seg = DPMIdos_allocate(sizeof(MODEINFO), &modeinfo_sel);
    modeinfo = (MODEINFO *)((udword)modeinfo_seg << 4);
    if(!modeinfo_seg) {
        DPMIdos_free(vesainfo_sel);
        return VESAERR_NO_DOS_MEM;
    }

    if(vesainfo->VbeVersion < 0x100) {
        DPMIdos_free(vesainfo_sel);
        DPMIdos_free(modeinfo_sel);
        return VESAERR_BAD_VERSION;
    }

    modelist = (UWORD*)((vesainfo->VideoModePtr & 0xFFFF) +
                       ((vesainfo->VideoModePtr >> 16) << 4));

    VESAset_display_start = RMset_display_start;
    VESAset_bank = RMset_bank;

    return VESAok; 
}                          

void VESAshutdown(void)
{
    DPMIdos_free(vesainfo_sel);
    DPMIdos_free(modeinfo_sel);
    if(pmcode)
        free(pmcode);
}


SURFACE *VESAopen_surface(int xsize, int ysize, int bpp, int search)
{
    int     i = 0, mode, pagsize, lfb;
    SURFACE *surf;

    while(modelist[i]!=0xFFFF) {
        mode    = modelist[i++];
        rms.eax = 0x4F01;
        rms.ecx = mode;
        rms.es  = modeinfo_seg;
        DPMIsim_realmode_int(0x10, &rms);

        if(modeinfo->XResolution==xsize && modeinfo->YResolution==ysize && modeinfo->BitsPerPixel==bpp) {

            lfb = modeinfo->ModeAttributes&0x80;

            
            if((search&LINEAR_MODE && lfb)||(search&BANKED_MODE && !lfb)) {

            surf=(SURFACE *)malloc(sizeof(SURFACE));
            if(!surf)
                return NULL;
            surf->xsize     = xsize;
            surf->ysize     = ysize;
            surf->bpp       = bpp;
            surf->vram      = vesainfo->TotalMemory << 16;
            surf->pagesize  = surf->vram / (xsize*ysize*(bpp>>3));

            if(surf->pagesize <= surf->vram)
                surf->numpages = surf->vram / surf->pagesize;

            if(modeinfo->ModeAttributes & 0x80) {
                surf->flags |= LINEAR_MODE;
                surf->lfb = (ubyte *)DPMImap_physical(modeinfo->PhysBasePtr, surf->vram);
                mode+=0x4000;   
            } else
                surf->flags |= BANKED_MODE;

            rms.eax = 0x4F02;
            rms.ebx = mode;
            rms.es  = modeinfo_seg;
            DPMIsim_realmode_int(0x10, &rms);
            return surf;
            }
        }
    }

    return NULL;
}

void VESAclose_surface(SURFACE *surf)
{
    if(surf->flags & LINEAR_MODE)
        DPMIunmap_physical((UDWORD)surf->lfb);

    free(surf);
}

int VESAfind_surface(int xsize, int ysize, int bpp, int search)
{
    int     i = 0, mode, lfb;

    while(modelist[i]!=0xFFFF) {
        mode    = modelist[i++];
        rms.eax = 0x4F01;
        rms.ecx = mode;
        rms.es  = modeinfo_seg;
        DPMIsim_realmode_int(0x10, &rms);

        if(modeinfo->XResolution==xsize && modeinfo->YResolution==ysize && modeinfo->BitsPerPixel==bpp)

            lfb = modeinfo->ModeAttributes&0x80;
            
            if((search&LINEAR_MODE && lfb)||(search&BANKED_MODE && !lfb))
                return mode;
    }

    return VESAok;
}

void VESAset_mode(int mode)
{
    if(mode<=0x13) {
        VGAset_mode(mode);
        return;
    }

    rms.eax = 0x4F01;
    rms.ecx = mode;
    rms.es  = modeinfo_seg;
    DPMIsim_realmode_int(0x10, &rms);

    rms.eax = 0x4F02;
    rms.ebx = mode;
    rms.es  = modeinfo_seg;
    DPMIsim_realmode_int(0x10, &rms);
}
