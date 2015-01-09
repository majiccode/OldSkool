#ifndef __VESA_H__
#define __VESA_H__

#define DPMI_INT    0x31

#ifndef ubyte
#define ubyte unsigned char
#endif
#ifndef uword
#define uword unsigned short
#endif
#ifndef udword
#define udword unsigned int
#endif
#ifndef NULL
#define NULL    0x0
#endif

// error message:
#define VESAok                  0
#define VESAERR_NO_DOS_MEM      1
#define VESAERR_NO_VESA         2
#define VESAERR_BAD_VERSION     3
#define VESAERR_NO_MEM          4

// vbe2 structures:
typedef struct {
    udword      VbeSignature;       // VBE Signature
    uword       VbeVersion;         // VBE Version
    udword      OemStringPtr;       // Pointer to OEM String
    ubyte       Capabilities[4];    // Capabilities of graphics cont.
    udword      VideoModePtr;       // Pointer to Video Mode List
    uword       TotalMemory;        // Number of 64kb memory blocks
                                    // Added for VBE 2.0
    uword       OemSoftwareRev;     // VBE implementation Software revision
    udword      OemVendorNamePtr;   // Pointer to Vendor Name String
    udword      OemProductNamePtr;  // Pointer to Product Name String
    udword      OemProductRevPtr;   // Pointer to Product Revision String
    ubyte       Reserved[222];      // Reserved for VBE implementation
                                    // scratch area
    ubyte       OemData[256];       // Data Area for OEM Strings
}   VESAINFO;

typedef struct {
    // Mandatory information for all VBE revisions
    uword       ModeAttributes;     // mode attributes
    ubyte       WinAAttributes;     // window A attributes
    ubyte       WinBAttributes;     // window B attributes
    uword       WinGranularity;     // window granularity
    uword       WinSize;            // window size
    uword       WinASegment;        // window A start segment
    uword       WinBSegment;        // window B start segment
    udword      WinFuncPtr;         // pointer to window function
    uword       BytesPerScanLine;   // bytes per scan line

    // Mandatory information for VBE 1.2 and above
    uword       XResolution;        // horizontal resolution in pixels or chars
    uword       YResolution;        // vertical resolution in pixels or chars
    ubyte       XCharSize;          // character cell width in pixels
    ubyte       YCharSize;          // character cell height in pixels
    ubyte       NumberOfPlanes;     // number of memory planes
    ubyte       BitsPerPixel;       // bits per pixel
    ubyte       NumberOfBanks;      // number of banks
    ubyte       MemoryModel;        // memory model type
    ubyte       BankSize;           // bank size in KB
    ubyte       NumberOfImagePages; // number of images
    ubyte       Reserved;           // reserved for page function

    // Direct Color fields (required for direct/6 and YUV/7 memory models)
    ubyte       RedMaskSize;        // size of direct color red mask in bits
    ubyte       RedFieldPosition;   // bit position of lsb of red mask
    ubyte       GreenMaskSize;      // size of direct color green mask in bits
    ubyte       GreenFieldPosition; // bit position of lsb of green mask
    ubyte       BlueMaskSize;       // size of direct color blue mask in bits
    ubyte       BlueFieldPosition;  // bit position of lsb of blue mask
    ubyte       RsvdMaskSize;       // size of direct color reserved mask in bits
    ubyte       RsvdFieldPosition;  // bit position of lsb of reserved mask
    ubyte       DirectColorModeInfo;// direct color mode attributes

    // Mandatory information for VBE 2.0 and above
    udword      PhysBasePtr;        // physical address for flat frame buffer
    udword      OffScreenMemOffset; // pointer to start of off screen memory
    uword       OffScreenMemSize;   // amount of off screen memory in 1k units
    ubyte       Reserved2[206];     // remainder of ModeInfoBlock
}   MODEINFO;


// flags:
#define LINEAR_MODE     1
#define BANKED_MODE     2

// Realmode call structure:
typedef struct {
    udword      edi, esi, ebp, reserved, ebx, edx, ecx, eax;
    uword       flags, es, ds, fs, gs, ip, cs, sp, ss;
}   RMS;

// Surface information: 
typedef struct {
    int     xsize;                  
    int     ysize;
    int     bpp;                    // bits per pixel (8,15,16,24,32...)
    int     vram;                   // amount of video memory
    int     numpages;               // number of pages available
    int     pagesize;               // size of page in bytes
    int     flags;                  // bit flags
    ubyte   *lfb;
}   SURFACE;

// functions:
typedef     void (*VESAset_display_start_t)(int x, int y);
typedef     void (*VESAset_bank_t)(int bank);

int         VESAdetect(void);
void        VESAshutdown(void);

SURFACE*    VESAopen_surface(int xsize, int ysize, int bpp, int search);
void        VESAclose_surface(SURFACE *surface);
void        VESAcheck(int xsize, int ysize, int bpp, int search);
int         VESAset_mode(int mode);

extern      VESAset_display_start_t VESAset_display_start;
extern      VESAset_bank_t          VESAset_bank;


#endif
