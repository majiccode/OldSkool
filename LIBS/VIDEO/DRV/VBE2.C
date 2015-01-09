//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VBE Graphics Driver                                                      //
// version 1.0b                                                             //
//                                                                          //
// code: frenzy                                                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#include    <dos.h>
#include    <i86.h>
#include    <stdio.h>
#include    "mode13h.h"
#include    "flib.h"

#define     UBYTE   unsigned char
#define     UWORD   unsigned short
#define     UDWORD  unsigned long


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VESAINFO and MODEINFO structures. Filled in by VBE                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
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


UWORD       vesainfo_segment, vesainfo_selector;
VESAINFO    *vesainfo;

UWORD       modeinfo_segment, modeinfo_selector;
MODEINFO    *modeinfo;


struct
{
    UBYTE       initalised;
    UBYTE       *buffer;            // offscreen drawing buffer
    UBYTE       *screen;            // screen address
    UDWORD      linear;
    UWORD       xsize, ysize;       //
    UWORD       xrealsize;          // xsize*(bpp>>3);
    UBYTE       bpp;
    UDWORD      pagesize, currpage;
    UBYTE       lfb, dummybuf;
    void        (*blitter)(void);
}   VBE_SCREEN;

typedef struct {                        // pcx info
    char        *pcxdata;               // ptr to uncompressed pcx file
    char        *palette;               // ptr to palette
    int         xsize;                  // xsize of picture
    int         ysize;                  // ysize of picture
    int         bpp;                    // bits per pixel
}   PCX;

struct {                                // pcx header
    char        manufacturer;
    char        version;
    char        encoding;
    char        bpp;
    short int   xmin;
    short int   ymin;
    short int   xmax;
    short int   ymax;
    short int   hdpi;
    short int   vdpi;
    char        colourmap[48];
    char        reserved;
    char        colour_planes;
    short int   bytes_per_line;
    short int   palinfo;
    short int   hscreen_size;
    short int   vscreen_size;
    char        filler[54];
}   PCX_HEADER;

typedef struct {                                // pcx header
    char        manufacturer;
    char        version;
    char        encoding;
    char        bpp;
    short int   xmin;
    short int   ymin;
    short int   xmax;
    short int   ymax;
    short int   hdpi;
    short int   vdpi;
    char        colourmap[48];
    char        reserved;
    char        colour_planes;
    short int   bytes_per_line;
    short int   palinfo;
    short int   hscreen_size;
    short int   vscreen_size;
    char        filler[54];
}   PCX_HEADER2;


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// PCX_load                                                                 //
//                                                                          //
// loads up a PCX file                                                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int PCX_load(char *filename, PCX *pcxdesc)
{
    int     width, height, totalbytes;
    int     x, y, n, i, c;
    FILE    *fp;

    if(!(fp=fopen(filename, "rb")))
        return 1;


    // read header
    if(fread(&PCX_HEADER, 1, sizeof(PCX_HEADER), fp) == sizeof(PCX_HEADER)) {

        if(PCX_HEADER.manufacturer == 0x0A && PCX_HEADER.version >= 5) {
                    
            width       = PCX_HEADER.xmax-PCX_HEADER.xmin+1;
            height      = PCX_HEADER.ymax-PCX_HEADER.ymin+1;
            totalbytes  = PCX_HEADER.bytes_per_line * PCX_HEADER.colour_planes;

            // allocate memory for pcx
            pcxdesc->pcxdata = (char *)malloc(totalbytes*height);
            if(pcxdesc->pcxdata == NULL)
                return 1;

            for(y=0; y<height; y++) {
                i=0;
                do {
                    c=fgetc(fp);
                    if((c&0xC0)==0xC0) {    // are highest 2 bits set?
                        n=c & 0x3F;         // mask off 2 highest bits
                        c=fgetc(fp);
                        while(n--) pcxdesc->pcxdata[y*totalbytes + i++]=c;
                    } else pcxdesc->pcxdata[y*totalbytes + i++]=c;
                } while(i<totalbytes);
            }

            c=fgetc(fp);

            if(c==12) {
                // allocate memory for pcx palette
                pcxdesc->palette = (char *)malloc(768);
                if(pcxdesc->palette == NULL) {
                    free(pcxdesc->pcxdata);
                    return 1;
                }

                fread(pcxdesc->palette, 768, 1, fp);
                for(i=0; i<768; i++)
                    pcxdesc->palette[i] >>= 2;
            }

        } else return 1;

    } else return 1;

    fclose(fp);
    return 0;
}
int PCX_load2(char *pcx, PCX *pcxdesc)
{
    int     width, height, totalbytes;
    int     x, y, n, i, c;
    int     fp;
    PCX_HEADER2 *pcxhdr;

    pcxhdr = (PCX_HEADER2 *)pcx;

    width       = pcxhdr->xmax-pcxhdr->xmin+1;
    height      = pcxhdr->ymax-pcxhdr->ymin+1;
    totalbytes  = pcxhdr->bytes_per_line * pcxhdr->colour_planes;

    // allocate memory for pcx
    pcxdesc->pcxdata = (char *)malloc(totalbytes*height);
    if(pcxdesc->pcxdata == NULL)
        return 1;

    fp=sizeof(PCX_HEADER2);

    for(y=0; y<height; y++) {
        i=0;
        do {
            c=pcx[fp++];
            if((c&0xC0)==0xC0) {    // are highest 2 bits set?
                n=c & 0x3F;         // mask off 2 highest bits
                c=pcx[fp++];
                while(n--) pcxdesc->pcxdata[y*totalbytes + i++]=c;
             } else pcxdesc->pcxdata[y*totalbytes + i++]=c;
         } while(i<totalbytes);
    }

    return 0;
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// RealMode Call Structure used in SIMULATE REAL MODE INTERRUPT             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
struct
{
    UDWORD      edi, esi, ebp, reserved, ebx, edx, ecx, eax;
    UWORD       flags, es, ds, fs, gs, ip, cs, sp, ss;
}   RMI;


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VBE Driver exit on error point                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_error(char *errmsg)
{
    printf("VBE ERROR: %s", errmsg);
    exit(1);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Simulate Real Mode Interrupt                                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_realmode_int(UBYTE intnum)
{
    struct SREGS    sr;
    union REGS      r;

    // fill segment registers with current values
    segread(&sr);

    // setup ready for interrupt
    r.w.ax =0x0300;
    r.h.bl =intnum;
    r.h.bh =0;
    r.w.cx =0;
    sr.es  =FP_SEG(&RMI);            // es=selector of realmode call struc
    r.x.edi=FP_OFF(&RMI);            // edi=offset of realmode call struc
    int386x(0x31, &r, &r, &sr);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Allocates Dos Memory Block                                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UWORD VBE_dosalloc(int size, UWORD *selector)
{
    union REGS      r;
    UWORD           ptr = NULL;

    // round to nearest paragraph
    size    =((size+15) & 0xFFFFFFF0) >> 4;
    r.w.ax  =0x100;
    r.w.bx  =size;
    int386(0x31, &r, &r);

    // CF clear if successfull
    if(r.x.cflag == 0) {
        *selector=r.w.dx;
        ptr=r.w.ax;
    }

    return(ptr);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Free Dos Memory Block                                                    //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_dosfree(UWORD selector)
{
    union REGS      r;

    r.w.ax=0x101;
    r.w.dx=selector;
    int386(0x31, &r, &r);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Physical Address Mapping                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UDWORD VBE_map_physical(UDWORD physical, UDWORD size)
{
    union REGS      r;

    r.w.ax=0x800;
    r.w.bx=physical >> 16;
    r.w.cx=physical & 0xFFFF;
    r.w.si=size >> 16;
    r.w.di=size & 0xFFFF;
    int386(0x31, &r, &r);

    return(r.w.bx << 16 | r.w.cx);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Free Physical Address Mapping                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_free_physical(UDWORD linear)
{
    union REGS      r;

    r.w.ax=0x801;
    r.w.bx=linear >> 16;
    r.w.cx=linear & 0xFFFF;
    int386(0x31, &r, &r);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Set Vesa Mode                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_setmode(UDWORD modenum)
{
    memset(&RMI, 0, sizeof(RMI));
    RMI.eax = 0x4F02;
    RMI.ebx = modenum;
    RMI.es  = modeinfo_segment;
    VBE_realmode_int(0x10);
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Set Display Start Address                                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_setstart(UDWORD pos)
{
    memset(&RMI, 0, sizeof(RMI));
    RMI.eax = 0x4F07;
    RMI.ebx = 0;
    RMI.ecx = pos % VBE_SCREEN.xrealsize;
    RMI.edx = pos / VBE_SCREEN.xrealsize;
    RMI.es  = modeinfo_segment;

    VBE_realmode_int(0x10);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Blitters                                                                 //
//                                                                          //
//   blitter1  - for modes that have a LFB and not enough memory for 2      //
//               video pages                                                //
//                                                                          //
//   blitter2  - for modes that have a LFB and enough video memory for 2    //
//               pages at least                                             //
//                                                                          //
//   blitter3  - for modes with no LFB that require bank switching          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void blitter1()
{
    memcpy(VBE_SCREEN.screen, VBE_SCREEN.buffer, VBE_SCREEN.xrealsize*VBE_SCREEN.ysize);
}    

void blitter2()
{
    VBE_SCREEN.buffer = VBE_SCREEN.screen + VBE_SCREEN.currpage;
    VBE_SCREEN.currpage = VBE_SCREEN.pagesize - VBE_SCREEN.currpage;
    VBE_setstart(VBE_SCREEN.currpage);
}


void blitter3()
{

}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VBE Initalisation                                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_init()
{
    // allocate memory for vesa info block
    vesainfo_segment = VBE_dosalloc(sizeof(VESAINFO), &vesainfo_selector);
    vesainfo = (VESAINFO *)((UDWORD)vesainfo_segment << 4);
    if(vesainfo_segment == NULL)
        VBE_error("cant allocate dos memory block");

    // get VESA info
    memset(&RMI, 0, sizeof(RMI));
    RMI.eax = 0x4F00;
    RMI.es  = vesainfo_segment;
    VBE_realmode_int(0x10);
    if(RMI.eax != 0x4F) {
        VBE_dosfree(vesainfo_selector);
        VBE_error("vesa bios not detected");
    }

    // allocate memory for mode info block
    modeinfo_segment = VBE_dosalloc(sizeof(MODEINFO), &modeinfo_selector);
    modeinfo = (MODEINFO *)((UDWORD)modeinfo_segment << 4);
    if(modeinfo_segment == NULL) {
        VBE_dosfree(vesainfo_selector);
        VBE_error("cant allocate dos memory block");
    }

    // check for version 2 VBE
    if(vesainfo->VbeVersion < 0x100) {
        VBE_dosfree(vesainfo_selector);
        VBE_dosfree(modeinfo_selector);
        VBE_error("version of bios too low. run vesa driver (univbe)");
    }
}
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VBE Mode Initalisation                                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_initmode(UWORD xsize, UWORD ysize, UBYTE bpp)
{
    UDWORD      *modelist, i = 0, foundmode = 0;
    UWORD       modenum;

    modelist=((vesainfo->VideoModePtr >> 16) << 4) +
              (vesainfo->VideoModePtr & 0xFFFF);
    while(modelist[i]!=-1) {

        modenum=modelist[i++];

        // get mode info
        memset(&RMI, 0, sizeof(RMI));
        RMI.eax = 0x4F01;
        RMI.ecx = modenum;
        RMI.es  = modeinfo_segment;
        VBE_realmode_int(0x10);

        if(modeinfo->XResolution==xsize &&
           modeinfo->YResolution==ysize &&
           modeinfo->BitsPerPixel==bpp)
        {
            VBE_SCREEN.initalised=1;
            
            VBE_SCREEN.xsize=xsize;
            VBE_SCREEN.ysize=ysize;
            VBE_SCREEN.xrealsize=xsize * (bpp>>3);
            VBE_SCREEN.lfb=1;   
            VBE_SCREEN.dummybuf=0;   
            
            // mode found, check if LFB available
            if(modeinfo->ModeAttributes & 0x80) {

                VBE_SCREEN.linear=VBE_map_physical(modeinfo->PhysBasePtr,
                                               vesainfo->TotalMemory << 16);
                VBE_SCREEN.screen=(char *)VBE_SCREEN.linear;

                if((vesainfo->TotalMemory-1)<(xsize*ysize*(bpp>>3)>>15)) {

                    VBE_SCREEN.dummybuf=1;
                    VBE_SCREEN.buffer=(char *)malloc(xsize*ysize*(bpp>>3));

                    if(VBE_SCREEN.buffer==NULL)
                        VBE_error("not enough memory for LFB");

                    VBE_SCREEN.blitter=&blitter1;

                    VBE_setmode(modenum + 0x4000);

                } else {

                    VBE_SCREEN.currpage=0;
                    VBE_SCREEN.dummybuf=0;
                    VBE_SCREEN.pagesize=(xsize*ysize*(bpp>>3)+65535)&0xFFFF0000;
                    VBE_SCREEN.buffer=VBE_SCREEN.screen + VBE_SCREEN.pagesize;
                    VBE_SCREEN.blitter=&blitter2;
                    VBE_setmode(modenum + 0x4000);
                }
            } else {

                VBE_SCREEN.dummybuf=1;
                VBE_SCREEN.lfb=0;      
                VBE_SCREEN.screen=(char *)0xA0000;
                VBE_SCREEN.buffer=(char *)malloc(xsize*ysize*(bpp>>3));

                if(VBE_SCREEN.buffer==NULL)
                    VBE_error("not enough memory for LFB");

                VBE_SCREEN.blitter=&blitter3;
                VBE_setmode(modenum);
            }

            break;
        }
    }
}
void VBE_initmode2(UWORD xsize, UWORD ysize, UBYTE bpp)
{
    UDWORD      *modelist, i = 0, foundmode = 0;
    UWORD       modenum;

    modelist=((vesainfo->VideoModePtr >> 16) << 4) +
              (vesainfo->VideoModePtr & 0xFFFF);
    while(modelist[i]!=-1) {

        modenum=modelist[i++];

        // get mode info
        memset(&RMI, 0, sizeof(RMI));
        RMI.eax = 0x4F01;
        RMI.ecx = modenum;
        RMI.es  = modeinfo_segment;
        VBE_realmode_int(0x10);

        if(modeinfo->BitsPerPixel==24 || modeinfo->BitsPerPixel==32)
        {
            VBE_SCREEN.initalised=1;
            
            VBE_SCREEN.xsize=xsize;
            VBE_SCREEN.ysize=ysize;
            VBE_SCREEN.xrealsize=xsize * (bpp>>3);
            VBE_SCREEN.lfb=1;   
            VBE_SCREEN.dummybuf=0;   
            
            // mode found, check if LFB available
            if(modeinfo->ModeAttributes & 0x80) {

                VBE_SCREEN.linear=VBE_map_physical(modeinfo->PhysBasePtr,
                                               vesainfo->TotalMemory << 16);
                VBE_SCREEN.screen=(char *)VBE_SCREEN.linear;

                if((vesainfo->TotalMemory-1)<(xsize*ysize*(bpp>>3)>>15)) {

                    VBE_SCREEN.dummybuf=1;
                    VBE_SCREEN.buffer=(char *)malloc(xsize*ysize*(bpp>>3));

                    if(VBE_SCREEN.buffer==NULL)
                        VBE_error("not enough memory for LFB");

                    VBE_SCREEN.blitter=&blitter1;

                    VBE_setmode(modenum + 0x4000);

                } else {

                    VBE_SCREEN.currpage=0;
                    VBE_SCREEN.dummybuf=0;
                    VBE_SCREEN.pagesize=(xsize*ysize*(bpp>>3)+65535)&0xFFFF0000;
                    VBE_SCREEN.buffer=VBE_SCREEN.screen + VBE_SCREEN.pagesize;
                    VBE_SCREEN.blitter=&blitter2;
                    VBE_setmode(modenum + 0x4000);
                }
            } else {

                VBE_SCREEN.dummybuf=1;
                VBE_SCREEN.lfb=0;      
                VBE_SCREEN.screen=(char *)0xA0000;
                VBE_SCREEN.buffer=(char *)malloc(xsize*ysize*(bpp>>3));

                if(VBE_SCREEN.buffer==NULL)
                    VBE_error("not enough memory for LFB");

                VBE_SCREEN.blitter=&blitter3;
                VBE_setmode(modenum);
            }

            break;
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VBE Mode Initalisation                                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_displaymodes()
{
    UDWORD      *modelist, i = 0, foundmode = 0;
    UWORD       modenum;

    modelist=((vesainfo->VideoModePtr >> 16) << 4) +
              (vesainfo->VideoModePtr & 0xFFFF);

    while(modelist[i]!=-1) {

        modenum=modelist[i++];

        // get mode info
        memset(&RMI, 0, sizeof(RMI));
        RMI.eax = 0x4F01;
        RMI.ecx = modenum;
        RMI.es  = modeinfo_segment;
        VBE_realmode_int(0x10);
        printf("mode number %d : \n",i);
        printf("x: %d, y: %d, bpp: %d\n", modeinfo->XResolution,modeinfo->YResolution,modeinfo->BitsPerPixel);
        if(modeinfo->ModeAttributes & 0x80)
         printf("LFB present for this mode\n\n");
         i++;

         getch();
    }
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Shutdown VBE driver                                                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void VBE_shutdown()
{
    if(VBE_SCREEN.initalised) {
        if(VBE_SCREEN.dummybuf)
            free(VBE_SCREEN.buffer);

        if(VBE_SCREEN.lfb)
            VBE_free_physical(VBE_SCREEN.linear);

        VBE_dosfree(vesainfo_selector);
        VBE_dosfree(modeinfo_selector);

        memset(&RMI, 0, sizeof(RMI));
        RMI.eax = 0x3;
        VBE_realmode_int(0x10);

        VBE_SCREEN.initalised=0;
    }
}

main()
{
    FILE    *fp;
    char    *piccy, *pal, *screen = 0xA0000;
    int     x, y, k, xp, yp, xsize, ysize, bpp;
    unsigned char r,g,b, g2;
    unsigned char p;
    int i;

    PCX mypcx;

   /*
    fp=fopen("1.raw", "rb");
    piccy=(char *)malloc(640*480*3);
    if(!piccy)
    {
        printf("memory error!");
        exit(1);
    }
    fread(piccy, 640*480*3, 1, fp);
    fclose(fp);
*/


    FLIB_init("pic.dat");
    piccy=FLIB_load("1.pcx");
    PCX_load2(piccy, &mypcx);
    free(piccy);


   // PCX_load("1.pcx", &mypcx);

    VBE_init();

//    VBE_displaymodes();
 
    VBE_initmode(640, 480, 16);

    
//    VGA_setpalette(mypcx.palette, 0, 256);

    xsize=modeinfo->XResolution;
    ysize=modeinfo->YResolution;
    bpp=modeinfo->BitsPerPixel;

    if(!VBE_SCREEN.initalised)
        VBE_error("cant initalised mode: 640x480x16bit");

    if(!VBE_SCREEN.lfb)
        VBE_error("no lfb");

/*
    for(y=0; y<480; y++)
        for(x=0; x<640; x++) {
            k=y*640 + x;
            r=mypcx.pcxdata[k];
            yp=y * 640;
            xp=x;
            VBE_SCREEN.screen[yp+xp]=r;
        }
*/ 

    
 

    for(y=0; y<480; y++)
        for(x=0; x<640; x++) {
            k=y*640*3 + x;
            r=mypcx.pcxdata[k];

            k=y*640*3 + x+640;
            g=mypcx.pcxdata[k+1];

            k=y*640*3 + x+640+640;
            b=mypcx.pcxdata[k+2];

            r>>=3;
            g>>=3;
            b>>=3;
            yp=y * 640 * 2;
            xp=x * 2;

            // clamp r,g,b values
            if(r>31) r=31;
            if(g>31) g=31;
            if(b>31) b=31;

            p=(g << 5) + b;
            VBE_SCREEN.screen[ yp+xp ] = p;
            p=(g >> 3) + (r << 2);
            VBE_SCREEN.screen[ yp+xp + 1] = p;
        }
     
  

    getch();
    
    VBE_shutdown();
   // free(piccy);
   // free(pal);
    free(mypcx.pcxdata);

//    printf("x=%d, y=%d, bpp=%d\n", xsize, ysize, bpp);

    FLIB_close();
    return 0;
}

