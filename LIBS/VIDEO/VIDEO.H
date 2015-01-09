#ifndef __VIDDRV_H
#define __VIDDRV_H

#include "\libs\h\typedef.h"
#include "\libs\h\memory.h"
#include "\libs\h\control.h"
#include "\libs\h\dpmi.h"

#ifndef NULL
#define NULL 0x00000000
#endif

//////////////////////////////////////////////////////////////////////////////
// Errors                                                                   //
//////////////////////////////////////////////////////////////////////////////
#define VIDOK                   0
#define VIDERR_CANT_INIT        1
#define VIDERR_DRIVER_FAILED    2
#define VIDERR_CANT_ADD_DRIVER  3
#define VIDERR_CANT_SET_MODE    4

//////////////////////////////////////////////////////////////////////////////
// Mode searching criteria flags / Options                                  //
//////////////////////////////////////////////////////////////////////////////
#define VID_EXACT               1
#define VID_BESTMATCH           2
#define VID_EXACT_BPP           4
#define VID_LARGER_BPP          8
#define VID_SMALLER_BPP         16
#define VID_EXACT_SIZE          32
#define VID_LARGER_SIZE         64
#define VID_SMALLER_SIZE        128
#define VID_LFB                 256
#define VID_PLANAR              512
#define VID_BANKED              1024
#define VID_DIRECT_WRITE        2048


//////////////////////////////////////////////////////////////////////////////
// Mode Types                                                               //
//////////////////////////////////////////////////////////////////////////////
typedef enum {
    LFB     = 1,
    BANKED  = 2,
    PLANAR  = 4,
}   MODEFLAG;

//////////////////////////////////////////////////////////////////////////////
// Blitter Types                                                            //
//////////////////////////////////////////////////////////////////////////////
enum BLITTYPES {
    BLIT4,       
    BLIT8,            
    BLIT15,
    BLIT16,
    BLIT24,
    BLIT32
};

//////////////////////////////////////////////////////////////////////////////
// Surface Types                                                            //
//////////////////////////////////////////////////////////////////////////////
typedef enum {
    NORMAL  = 1,
    USER    = 2,
}   SURFTYPE;

typedef struct surface {
    struct videodriver  *driver;
    struct mode         *mode;
    UWORD               xsize, ysize;
    UBYTE               bpp;
    UBYTE               *surface;
    UBYTE               *lfb;
    UBYTE               *pal;
    UBYTE               num_pages;
    UDWORD              page_size;
    UWORD               writemode;
    UWORD               x,y;
    SURFTYPE            surftype;
    void                (*Blit)(struct surface *surface);
}   SURFACE;

typedef struct mode {
    struct videodriver  *driver;
    UWORD               modenum;
    UWORD               xsize, ysize;
    UBYTE               bpp;
    MODEFLAG            flags;
    UDWORD              vram_size;
    UBYTE               *lfb;
    struct mode         *next, *prev; 
}   MODE;

typedef struct {
    void                (*Blit)(SURFACE *surface);
}   BLITTERS;

typedef struct videodriver {
    char                *drvname;                       
    char                major, minor;

    BLITTERS*           blitters;

    int                 (*Detect)(void);
    int                 (*SetMode)(MODE *mode);
    int                 (*SetModeBackup)(SURFACE *surface);
    int                 (*CloseMode)(void);
    int                 (*GetModeFirst)(MODE *mode);
    int                 (*GetModeNext)(MODE *mode);
//    int                 (*SetPage)(MODE *mode);
//    int                 (*SetDisplayStart)(UDWORD pos);
//    int                 (*SetActivePage)(MODE *mode);

}   VIDEODRIVER;

//////////////////////////////////////////////////////////////////////////////
// Driver Functions                                                         //
//////////////////////////////////////////////////////////////////////////////
int             VIDEOopen_driver(VIDEODRIVER *drv);
//VIDEODRIVER*    VIDEOload_driver(char *filename);
void            VIDEOremove_driver(VIDEODRIVER *drv);

//////////////////////////////////////////////////////////////////////////////
// Mode Functions                                                           //
//////////////////////////////////////////////////////////////////////////////
MODE*           VIDEOget_mode(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search);
int             VIDEOset_mode(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search);
int             VIDEOclose_mode(void);
MODE*           VIDEOget_drvmode(VIDEODRIVER *drv, UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search);
int             VIDEOset_drvmode(VIDEODRIVER *drv, UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search);

//////////////////////////////////////////////////////////////////////////////
// Surface Functions                                                        //
//////////////////////////////////////////////////////////////////////////////
SURFACE*        VIDEOopen_surface(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search);
int             VIDEOset_surface(SURFACE *surface);
SURFACE*        VIDEOcreate_surface(UWORD xsize, UWORD ysize, UBYTE bpp);
void            VIDEOclose_surface(SURFACE *surface);

//SURFACE*        VIDEOconvert_surface(SURFACE *surface, UBYTE bpp);
int             VIDEOset_custom_blit(SURFACE *surface, void (*blit)(SURFACE *surface));
int             VIDEOblit_surface(SURFACE *surface);

//////////////////////////////////////////////////////////////////////////////
// Palette / Colour Functions                                               //
//////////////////////////////////////////////////////////////////////////////
int             VIDEOset_palette(SURFACE *surface);
int             VIDEOget_palette(SURFACE *surface);
int             VIDEOset_colour(SURFACE *surface, UBYTE col, UBYTE r, UBYTE g, UBYTE b);
int             VIDEOget_colour(SURFACE *surface, UBYTE col, UBYTE *r, UBYTE *g, UBYTE *b);


UWORD           PACKRGB15(UBYTE r, UBYTE g, UBYTE b);
#pragma aux     PACKRGB15 =\
                "mov al,ah"\
                "shl al,5"\
                "add al,bl"\
                "shr ah,3"\
                "shl bh,2"\
                "add ah,bh"\
                parm [bh] [ah] [bl] value [ax];

//////////////////////////////////////////////////////////////////////////////
// Retrace / Timing Functions                                               //
//////////////////////////////////////////////////////////////////////////////

void            VIDEOwait_no_vr(void);
#pragma aux     VIDEOwait_no_vr =\
                "mov dx,03DAh"\
                "nvr:"\
                "in al,dx"\
                "test al,8"\
                "jnz nvr"\
                modify [eax edx];

void            VIDEOwait_vr(void);
#pragma aux     VIDEOwait_vr =\
                "mov dx,03DAh"\
                "vr:"\
                "in al,dx"\
                "test al,8"\
                "jz vr"\
                modify [eax edx];

void            VIDEOwait_hr(void);
#pragma aux     VIDEOwait_hr =\
                "mov dx,03DAh"\
                "hr:"\
                "in al,dx"\
                "test al,1"\
                "jnz hr"\
                modify [eax edx];

//////////////////////////////////////////////////////////////////////////////
// Graphics Filters                                                         //
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Initalisation / Deinitalisation Functions                                //
//////////////////////////////////////////////////////////////////////////////
int             VIDEOopen(void);
void            VIDEOclose(void);

#endif
