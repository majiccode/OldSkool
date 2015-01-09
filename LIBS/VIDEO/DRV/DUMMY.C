//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Dummy Video Driver                                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#include "\libs\video\video.h"
#include <dos.h>

static int curr_mode;

static UBYTE *vidmem = (UBYTE *)0xA0000;

void Blit4BIT(SURFACE *surface)
{
}

void Blit8BIT(SURFACE *surface)
{
    int     x,y,i;

    for(y=0; y<200; y++)
        for(x=0; x<320; x++)
            vidmem[y*320 + x]=surface->surface[y*320 + x];
}

void Blit15BIT(SURFACE *surface)
{
}

void Blit16BIT(SURFACE *surface)
{
}

void Blit24BIT(SURFACE *surface)
{
}

void Blit32BIT(SURFACE *surface)
{
}


//
// Blitters for driver
//
BLITTERS blitters[] = {
    &Blit4BIT,
    &Blit8BIT,
    &Blit15BIT,
    &Blit16BIT,
    &Blit24BIT,
    &Blit32BIT
};

//
// Modes available with driver
//
MODE modes[] = {
    NULL,
    0x13,
    320, 200, 8,                // standard mode 13h
    LFB,
    64000,
    (void *)0xA0000,
    NULL, NULL,

    NULL,
    0x14,
    80, 25, 16,
    PLANAR,
    64000,
    (void *)0xA0000,
    NULL, NULL,

    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
};

// Detect if VIDEO driver will work with current hardware
int Detect(void)
{
    return 0;
}

// Set a video mode
int SetMode(int mode)
{
    union REGS r;

    r.w.ax = mode;
    int386(0x10, &r, &r);

    return 0;
}

// Get first mode available
MODE *GetModeFirst(void)
{
    curr_mode = 1;
    return &modes[0];
}

// Get next mode available
MODE *GetModeNext(void)
{
    if(modes[curr_mode].modenum)
        return &modes[curr_mode++];
    
    return NULL;
}

// Get mode information
MODE *GetModeInfo(MODE *mode)
{
    return mode;
}


VIDEODRIVER dummy_video_driver = {
    "Dummy Video Driver",       // driver name
    0x1, 0x0,                   // version number, minor.major (1.0)

    &blitters,
    &modes,                     // ptr to mode list
    &Detect,                    // detect
    &SetMode,
    &GetModeFirst,
    &GetModeNext,
    &GetModeInfo
};
