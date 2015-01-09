//                                                                          
//                       VESA 2.0 Video Display Driver
//                                                                          
//                                version 1.0
//
//
//                              Internal Version
//
//
#include "\libs\video\video.h"


typedef struct
{
    UDWORD      VbeSignature;       // VBE Signature
    UWORD       VbeVersion;         // VBE Version
    UDWORD      OemStringPtr;       // Pointer to OEM String
    UBYTE       Capabilities[4];    // Capabilities of graphics cont.
    UDWORD      VideoModePtr;       // Pointer to Video Mode List
    UWORD       TotalMemory;        // Number of 64kb memory blocks
                                    // Added for VBE 2.0
    UWORD       OemSoftwareRev;     // VBE implementation Software revision
    UDWORD      OemVendorNamePtr;   // Pointer to Vendor Name String
    UDWORD      OemProductNamePtr;  // Pointer to Product Name String
    UDWORD      OemProductRevPtr;   // Pointer to Product Revision String
    UBYTE       Reserved[222];      // Reserved for VBE implementation
                                    // scratch area
    UBYTE       OemData[256];       // Data Area for OEM Strings
}   VESAINFO;

typedef struct
{
    // Mandatory information for all VBE revisions
    UWORD       ModeAttributes;     // mode attributes
    UBYTE       WinAAttributes;     // window A attributes
    UBYTE       WinBAttributes;     // window B attributes
    UWORD       WinGranularity;     // window granularity
    UWORD       WinSize;            // window size
    UWORD       WinASegment;        // window A start segment
    UWORD       WinBSegment;        // window B start segment
    UDWORD      WinFuncPtr;         // pointer to window function
    UWORD       BytesPerScanLine;   // bytes per scan line

    // Mandatory information for VBE 1.2 and above
    UWORD       XResolution;        // horizontal resolution in pixels or chars
    UWORD       YResolution;        // vertical resolution in pixels or chars
    UBYTE       XCharSize;          // character cell width in pixels
    UBYTE       YCharSize;          // character cell height in pixels
    UBYTE       NumberOfPlanes;     // number of memory planes
    UBYTE       BitsPerPixel;       // bits per pixel
    UBYTE       NumberOfBanks;      // number of banks
    UBYTE       MemoryModel;        // memory model type
    UBYTE       BankSize;           // bank size in KB
    UBYTE       NumberOfImagePages; // number of images
    UBYTE       Reserved;           // reserved for page function

    // Direct Color fields (required for direct/6 and YUV/7 memory models)
    UBYTE       RedMaskSize;        // size of direct color red mask in bits
    UBYTE       RedFieldPosition;   // bit position of lsb of red mask
    UBYTE       GreenMaskSize;      // size of direct color green mask in bits
    UBYTE       GreenFieldPosition; // bit position of lsb of green mask
    UBYTE       BlueMaskSize;       // size of direct color blue mask in bits
    UBYTE       BlueFieldPosition;  // bit position of lsb of blue mask
    UBYTE       RsvdMaskSize;       // size of direct color reserved mask in bits
    UBYTE       RsvdFieldPosition;  // bit position of lsb of reserved mask
    UBYTE       DirectColorModeInfo;// direct color mode attributes

    // Mandatory information for VBE 2.0 and above
    UDWORD      PhysBasePtr;        // physical address for flat frame buffer
    UDWORD      OffScreenMemOffset; // pointer to start of off screen memory
    UWORD       OffScreenMemSize;   // amount of off screen memory in 1k units
    UBYTE       Reserved2[206];     // remainder of ModeInfoBlock
}   MODEINFO;

static int      curr_mode;
static VESAINFO *vesainfo;
static UWORD    vesainfo_segment, vesainfo_selector;
static MODEINFO *modeinfo;
static UWORD    modeinfo_segment, modeinfo_selector;
static UWORD    *modelist;
static RMS      rms;
static MODE     *current_mode;


/////////////////////////
// Function Prototypes //
/////////////////////////
void    Blit4BIT_LFB(SURFACE *surface);
void    Blit8BIT_LFB(SURFACE *surface);
void    Blit15BIT_LFB(SURFACE *surface);
void    Blit16BIT_LFB(SURFACE *surface);
void    Blit24BIT_LFB(SURFACE *surface);
void    Blit32BIT_LFB(SURFACE *surface);

void    Blit4BIT_BANKED(SURFACE *surface);
void    Blit8BIT_BANKED(SURFACE *surface);
void    Blit15BIT_BANKED(SURFACE *surface);
void    Blit16BIT_BANKED(SURFACE *surface);
void    Blit24BIT_BANKED(SURFACE *surface);
void    Blit32BIT_BANKED(SURFACE *surface);

void    Blit15to16_LFB(SURFACE *surface);
void    Blit16to15_LFB(SURFACE *surface);


int     Detect(void);
int     Shutdown(void);
int     GetModeFirst(MODE *mode);
int     GetModeNext(MODE *mode);
int     SetMode(MODE *mode);
int     SetModeBackup(SURFACE *surface);
int     CloseMode(void);


////////////////////////////////
// Video Interface Structures //
////////////////////////////////
BLITTERS blitters_LFB[] = {
    &Blit4BIT_LFB,
    &Blit8BIT_LFB,
    &Blit15BIT_LFB,
    &Blit16BIT_LFB,
    &Blit24BIT_LFB,
    &Blit32BIT_LFB
};

BLITTERS blitters_BANKED[] = {
    &Blit4BIT_BANKED,
    &Blit8BIT_BANKED,
    &Blit15BIT_BANKED,
    &Blit16BIT_BANKED,
    &Blit24BIT_BANKED,
    &Blit32BIT_BANKED
};

BLITTERS blit_conversions_LFB[6][6] = {
   { NULL, NULL, NULL, NULL, NULL, NULL },         
   { NULL, NULL, NULL, NULL, NULL, NULL },        
   { NULL, NULL, NULL, NULL, NULL, NULL },  
   { NULL, NULL, NULL, NULL, NULL, NULL },        
   { NULL, NULL, NULL, NULL, NULL, NULL },        
   { NULL, NULL, NULL, NULL, NULL, NULL }          
};

BLITTERS blit_conversions_BANKED[6][6] = {
   { NULL, NULL, NULL, NULL, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL, NULL }
};

VIDEODRIVER vesa2_driver = {
    "VESA2.0 Video Driver",    
    0x1, 0x0,               

    &blitters_LFB,
    &Detect,                    
    &SetMode,
    &SetModeBackup,
    &CloseMode,
    &GetModeFirst,
    &GetModeNext,
};

//////////////////////
// BLITTERS FOR LFB //
//////////////////////

void Blit4BIT_LFB(SURFACE *surface)
{
}

void Blit8BIT_LFB(SURFACE *surface)
{
}

void Blit15BIT_LFB(SURFACE *surface)
{
}

void Blit16BIT_LFB(SURFACE *surface)
{
}

void Blit24BIT_LFB(SURFACE *surface)
{
}

void Blit32BIT_LFB(SURFACE *surface)
{
}

/////////////////////////
// BLITTERS FOR BANKED //
/////////////////////////

void Blit4BIT_BANKED(SURFACE *surface)
{
}

void Blit8BIT_BANKED(SURFACE *surface)
{
}

void Blit15BIT_BANKED(SURFACE *surface)
{
}

void Blit16BIT_BANKED(SURFACE *surface)
{
}

void Blit24BIT_BANKED(SURFACE *surface)
{
}

void Blit32BIT_BANKED(SURFACE *surface)
{
}

///////////////////////////////////
// Blit Conversions for LFB mode //
///////////////////////////////////
void dummy_blit(SURFACE *surface)
{
}

void Blit15to16_LFB(SURFACE *surface)
{
}

void Blit16to15_LFB(SURFACE *surface)
{
}

//////////////////////////////////////
// Blit Conversions for BANKED mode //
//////////////////////////////////////


/////////////////////////////////
// Detect if VESA2 is present. //
/////////////////////////////////
int Detect(void)
{
    UWORD   segment, offset;

    // allocate dos memory for vesainfo structure

    vesainfo_segment = MEMdos_allocate(sizeof(VESAINFO), &vesainfo_selector);
    vesainfo = (VESAINFO *)(vesainfo_segment << 4);
    if(!vesainfo_segment)
        return 1;

    // get VESA info
    rms.eax = 0x4F00;
    rms.es  = vesainfo_segment;
    DPMIsim_realmode_int(0x10, &rms);
    if(rms.eax != 0x4F) {
        MEMdos_free(vesainfo_selector);
        return 1;
    }

    // allocate memory for mode info block
    modeinfo_segment = MEMdos_allocate(sizeof(MODEINFO), &modeinfo_selector);
    modeinfo = (MODEINFO *)((UDWORD)modeinfo_segment << 4);
    if(!modeinfo_segment) {
        MEMdos_free(vesainfo_selector);
        return 1;
    }

    // check for version 2 VBE
    if(vesainfo->VbeVersion < 0x100) {
        MEMdos_free(vesainfo_selector);
        MEMdos_free(modeinfo_selector);
        return 1;
    }


    modelist = (UWORD*)((vesainfo->VideoModePtr & 0xFFFF) +
                       ((vesainfo->VideoModePtr >> 16) << 4));

    return 0;           
}                          

///////////////////////////
// Shutdown VESA2 driver //
///////////////////////////
int Shutdown(void)
{
    MEMdos_free(vesainfo_selector);
    MEMdos_free(modeinfo_selector);
    return 0;
}

//////////////////////////////
// Get first mode available //
//////////////////////////////
int GetModeFirst(MODE *mode)
{
    UDWORD  modenum;

    modenum = modelist[0];
    if(modenum==0xFFFF)
        return 1;

    curr_mode = 1;

    rms.eax = 0x4F01;
    rms.ecx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);
    
    mode->modenum = modenum;
    mode->xsize = modeinfo->XResolution;
    mode->ysize = modeinfo->YResolution;
    mode->bpp = modeinfo->BitsPerPixel;
    mode->vram_size = vesainfo->TotalMemory << 16;

    if(modeinfo->ModeAttributes & 0x80)
        mode->flags |= LFB;
    else
        mode->flags |= BANKED;

    if(mode->flags & LFB)
        mode->lfb = (UBYTE *)modeinfo->PhysBasePtr;

    return 0;
}

/////////////////////////////
// Get next mode available //
/////////////////////////////
int GetModeNext(MODE *mode)
{
    UWORD  modenum;

    modenum = modelist[curr_mode];
    if(modenum==0xFFFF)
        return 1;

    curr_mode++;

    rms.eax = 0x4F01;
    rms.ecx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);

    mode->modenum = modenum;
    mode->xsize = modeinfo->XResolution;
    mode->ysize = modeinfo->YResolution;
    mode->bpp = modeinfo->BitsPerPixel;
    mode->vram_size = vesainfo->TotalMemory << 16;

    if(modeinfo->ModeAttributes & 0x80)
        mode->flags |= LFB;
    else
        mode->flags |= BANKED;

    if(mode->flags & LFB)
        mode->lfb = (UBYTE *)modeinfo->PhysBasePtr;

    return 0;
}

//////////////
// Set Mode //
//////////////
int SetMode(MODE *mode)
{
    int     modenum;
    udword  addr;

    modenum = mode->modenum;

    rms.eax = 0x4F01;
    rms.ecx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);

    if(modeinfo->ModeAttributes & 0x80) {
        vesa2_driver.blitters = &blitters_LFB;
        addr = DPMImap_physical((UDWORD)mode->lfb, mode->vram_size);
        mode->lfb = (UBYTE *)addr;
        modenum+=0x4000;
    } else {
        vesa2_driver.blitters = &blitters_BANKED;
    }        

    rms.eax = 0x4F02;
    rms.ebx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);

    current_mode = mode;

    return 0;
}

///////////////////
// Get Blit Type //
///////////////////
int GetBlitType(UBYTE bpp)
{
    switch(bpp) {
        case 4: return BLIT4;
        case 8: return BLIT8;
        case 15:return BLIT15;
        case 16:return BLIT16;
        case 24:return BLIT24;
        case 32:return BLIT32;
    };

    return 0;
}

///////////////////////////////////
// Set Mode with Blit Convertion //
///////////////////////////////////
int SetModeBackup(SURFACE *surface)
{
    int     modenum;
    udword  addr;
    int     blit_source, blit_dest;

    blit_source = GetBlitType(surface->bpp);
    blit_dest = GetBlitType(surface->mode->bpp);

    modenum = surface->mode->modenum;

    rms.eax = 0x4F01;
    rms.ecx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);

    if(modeinfo->ModeAttributes & 0x80) {
        vesa2_driver.blitters = &blitters_LFB;
        addr = DPMImap_physical((UDWORD)surface->mode->lfb, surface->mode->vram_size);
        surface->mode->lfb = (UBYTE *)addr;
        surface->lfb = (UBYTE *)addr;
        modenum+=0x4000;
    } else {
        vesa2_driver.blitters = &blitters_BANKED;
    }        

    if(blit_source != blit_dest) {

        // blit converters
        if(surface->mode->flags&LFB)
            surface->Blit = blit_conversions_LFB[blit_source][blit_dest].Blit;
        else
            surface->Blit = blit_conversions_BANKED[blit_source][blit_dest].Blit;

    } else
        surface->Blit = vesa2_driver.blitters[blit_dest].Blit;


    if(!surface->Blit)
        return 1;
    

    rms.eax = 0x4F02;
    rms.ebx = modenum;
    rms.es  = modeinfo_segment;
    DPMIsim_realmode_int(0x10, &rms);

    current_mode = surface->mode;

    return 0;
}

////////////////
// Close Mode //
////////////////
int CloseMode(void)
{
    if(current_mode->flags == LFB)
        DPMIunmap_physical((UDWORD)current_mode->lfb);


    return 0;
}    


