#include "\libs\h\dpmi.h"
#include "\libs\h\vesa.h"
#include "\libs\h\memory.h"

VESAINFO        *vesainfo;
static uword    vesainfo_seg, vesainfo_sel;
MODEINFO        *modeinfo;
static uword    modeinfo_seg, modeinfo_sel;
static uword    *modelist;
static RMS      rms;

VESAset_display_start_t VESAset_display_start;
VESAset_bank_t          VESAset_bank;

static ubyte    *pmcode = NULL;
static void     *pm_set_display_start;
static void     *pm_set_bank;

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
}

void PMset_bank(int bank)
{
}

char *VESAget_error(int err)
{
    switch(err) {
        case VESAERR_NO_DOS_MEM:
            return "Not enough base memory!!!";

        case VESAERR_NO_VESA:
            return "No VESA driver found, install UNIVBE!!!";

        case VESAERR_BAD_VERSION:
            return "You require VESA2.0+ to run this program!!!";
            break;

        case VESAERR_NO_MEM:
            return "Not enough memory!!!";
            break;

        default:
            return "Internal Error";
    }
}


int VESAdetect(void)
{
    uword   *pm_interface;

    MEMinit(MAXHEAP);

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

            surf=(SURFACE *)MEMallocate(sizeof(SURFACE));  
            if(!surf)
                return NULL;
            surf->xsize     = xsize;
            surf->ysize     = ysize;
            surf->bpp       = bpp;
            surf->vram      = vesainfo->TotalMemory << 16;
            surf->pagesize  = surf->vram / (xsize*ysize*(bpp>>3));
            surf->bytes_per_line = xsize*(bpp>>3);

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

    MEMfree(surf);
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

        if(modeinfo->XResolution==xsize && modeinfo->YResolution==ysize && modeinfo->BitsPerPixel==bpp) {

            lfb = modeinfo->ModeAttributes&0x80;
            
            if((search&LINEAR_MODE && lfb)||(search&BANKED_MODE && !lfb))
                return mode;
        }
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
