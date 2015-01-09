#include "\libs\h\fmaths.h"
#include "video.h"

static MODE *modelist, *tail, *current_mode;
static int  video_tag;


void        VIDEOset_dos_mode(int mode);
#pragma aux VIDEOset_dos_mode =\
            "int    10h"\
            parm [eax] modify [eax];


void VIDEOdummy_blitter(SURFACE *surface)
{
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// DRIVER BASED FUNCTIONS:                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

char *VIDEOget_error(int errnum)
{
    switch(errnum) {
        case 0: return NULL;
        case VIDERR_CANT_INIT: return "Can't initalise";
        case VIDERR_DRIVER_FAILED: return "Failed to load driver";
        case VIDERR_CANT_SET_MODE: return "Can't set required video mode";
        default: return "Internal Error";
    }
}

void VIDEOclose(void)
{
    MEMfree_taged(video_tag);
    MEMfree_tag(video_tag);
    MEMset_default_tag();
}

int VIDEOopen(void)
{
    if(!MEMinit(MAXHEAP))
        return VIDERR_CANT_INIT;
    
    video_tag = MEMget_unused_tag();

    return VIDOK;
}

int VIDEOopen_driver(VIDEODRIVER *drv)
{
    MODE        *mode, *prev, m;
    int         err;
    
    MEMset_tag(video_tag);

    if(drv->Detect()) {
        VIDEOclose();
        return VIDERR_DRIVER_FAILED;
    }

    modelist=(MODE *)MEMallocate(sizeof(MODE));
    if(!modelist) {
        VIDEOclose();
        return VIDERR_DRIVER_FAILED;
    }

    err=drv->GetModeFirst(modelist);
    if(err) {
        VIDEOclose();
        return VIDERR_DRIVER_FAILED;
    }
    
    modelist->driver=drv;
    modelist->next=NULL;
    modelist->prev=NULL;
    tail=modelist;
    prev=modelist;
    do {
        err=drv->GetModeNext(&m);
        if(!err) {
            mode=(MODE *)MEMallocate(sizeof(MODE));
            if(!mode) {
                VIDEOclose();
                return VIDERR_DRIVER_FAILED;
            }
            mode->modenum=m.modenum;
            mode->xsize=m.xsize;
            mode->ysize=m.ysize;
            mode->bpp=m.bpp;
            mode->flags=m.flags;
            mode->vram_size=m.vram_size;
            mode->lfb=m.lfb;
            mode->next=NULL;
            mode->prev=prev;
            mode->driver=drv;
            prev->next=mode;
            prev=mode;
            tail=mode;
        }    
    } while(!err);

    MEMset_default_tag();

    return VIDOK;;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MODE FUNCTIONS:                                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

MODE *VIDEOsearch_mode(VIDEODRIVER *drv, UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{
    MODE        *mode, *best_mode;
    UWORD       xs, ys, depth, foundmode;
    DWORD       match_xsize, match_ysize, match_bpp;
    UDWORD      best_match, match, best_bpp;
    UBYTE       lfb;

    best_match = 99999;
    best_bpp = 99999;
    best_mode = NULL;
    foundmode = 0;

    if(search==(VID_BESTMATCH + VID_EXACT_BPP + VID_EXACT_SIZE))
        search=VID_EXACT;

    for(mode=modelist; mode->next; mode=mode->next) {

        if(drv==NULL || drv==mode->driver) {

            xs = mode->xsize;
            ys = mode->ysize;
            depth = mode->bpp;
            lfb = (mode->flags & LFB) ^ 1;

            match_bpp = fabs(depth - bpp);
            match_xsize = fabs(xs - xsize);
            match_ysize = fabs(ys - ysize);


            if(search&VID_EXACT)
                if(xsize==xs && ysize==ys && bpp==depth) {
                    best_mode=mode;
                    if(mode->flags & LFB)
                        return best_mode;
                }

            if(search&VID_BESTMATCH) {
                if(search&VID_EXACT_BPP) {
                    if(bpp==depth) {
                        if(search&VID_LARGER_SIZE) {
                            if(xs>=xsize && ys>=ysize) {
                                match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                if(match<=best_match) {
                                    best_mode=mode;
                                    best_match=match;
                                }
                            }
                        }

                        if(search&VID_SMALLER_SIZE) {
                            if(xs<=xsize && ys<=ysize) {
                                match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                if(match<=best_match) {
                                    best_mode=mode;
                                    best_match=match;
                                }
                            }
                        }
                    }
                }

                if(search&VID_SMALLER_BPP) {
                    if(depth<=bpp) {
                        if(match_bpp<=best_bpp) {
                            if(search&VID_LARGER_SIZE) {
                                if(xs>=xsize && ys>=ysize) {
                                    match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                    if(match<=best_match) {
                                        best_mode=mode;
                                        best_match=match;
                                        best_bpp=match_bpp;
                                    }
                                }
                            }

                            if(search&VID_SMALLER_SIZE) {
                                if(xs<=xsize && ys<=ysize) {
                                    match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                    if(match<=best_match) {
                                        best_mode=mode;
                                        best_match=match;
                                        best_bpp=match_bpp;
                                    }
                                }
                            }

                            if(search&VID_EXACT_SIZE) {
                                if(xsize==xs && ysize==ys) {
                                    best_mode=mode;
                                    best_bpp=match_bpp;
                                }
                            }
                        }
                    }
                }
                if(search&VID_LARGER_BPP) {
                    if(depth>=bpp) {
                        if(match_bpp<=best_bpp) {
                            if(search&VID_LARGER_SIZE) {
                                if(xs>=xsize && ys>=ysize) {
                                    match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                    if(match<=best_match) {
                                        best_mode=mode;
                                        best_match=match;
                                        best_bpp=match_bpp;
                                    }
                                }
                            }

                            if(search&VID_SMALLER_SIZE) {
                                if(xs<=xsize && ys<=ysize) {
                                    match=match_xsize*match_xsize+match_ysize*match_ysize+lfb;
                                    if(match<=best_match) {
                                        best_mode=mode;
                                        best_match=match;
                                        best_bpp=match_bpp;
                                    }
                                }
                            }

                            if(search&VID_EXACT_SIZE) {
                                if(xsize==xs && ysize==ys) {
                                    best_mode=mode;
                                    best_bpp=match_bpp;
                                }
                            }

                        }
                    }
                }
            }
        }
    }
    return best_mode;
}

MODE *VIDEOget_mode(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{
    return VIDEOsearch_mode(NULL, xsize, ysize, bpp, search);
}

int VIDEOset_mode(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{
    MODE    *mode;

    mode=VIDEOget_mode(xsize, ysize, bpp, search);
    if(!mode)
        return VIDERR_CANT_SET_MODE;

    mode->driver->SetMode(mode);

    current_mode = mode;

    return VIDOK;
}

int VIDEOclose_mode(void)
{
    current_mode->driver->CloseMode();
    VIDEOset_dos_mode(0x3);
    return VIDOK;;
}

MODE *VIDEOget_drvmode(VIDEODRIVER *drv, UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{

    return VIDEOsearch_mode(drv, xsize, ysize, bpp, search);

}

int VIDEOset_drvmode(VIDEODRIVER *drv, UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{
    MODE    *mode;

    mode=VIDEOget_drvmode(drv, xsize, ysize, bpp, search);
    if(!mode)
        return VIDERR_CANT_SET_MODE;

    mode->driver->SetMode(mode);

    current_mode = mode;
    return VIDOK;;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// SURFACE FUNCTIONS:                                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

UBYTE VIDEOget_blit_type(UBYTE bpp)
{
    switch(bpp) {
        case 4: return BLIT4;
        case 8: return BLIT8;
        case 15:return BLIT15;
        case 16:return BLIT16;
        case 24:return BLIT24;
        case 32:return BLIT32;
    };

    return -1;
}

void VIDEOclose_surface(SURFACE *surface)
{
    if(surface->mode)
        VIDEOclose_mode();
    if(!surface->writemode)
        MEMfree(surface->surface);
    if(surface->bpp < 15)
        MEMfree(surface->pal);
    MEMfree(surface);
    MEMset_default_tag();
}

SURFACE *VIDEOopen_surface(UWORD xsize, UWORD ysize, UBYTE bpp, UWORD search)
{
    MODE    *mode;
    SURFACE *surface;
    UBYTE   blit_type;

    mode = VIDEOget_mode(xsize, ysize, bpp, search);

    current_mode = mode;

    if(!mode)
        return NULL;

    MEMset_tag(video_tag);

    surface = (SURFACE *)MEMallocate(sizeof(SURFACE));
    if(!surface) {
        return NULL;
        MEMset_default_tag();
    }

    surface->surftype = NORMAL;
    surface->driver = mode->driver;
    surface->mode   = mode;
    surface->xsize  = mode->xsize;
    surface->ysize  = mode->ysize;
    surface->bpp    = mode->bpp;
    surface->lfb    = mode->lfb;
    surface->pal    = NULL;

    xsize=surface->xsize;
    ysize=surface->ysize;
    bpp=surface->bpp;
    surface->page_size = xsize*ysize*(bpp>>3);
    surface->num_pages = surface->mode->vram_size / surface->page_size;

    blit_type = VIDEOget_blit_type(bpp);
    surface->Blit = surface->driver->blitters[blit_type].Blit;

    if(!surface->Blit) {
        MEMfree(surface);
        MEMset_default_tag();
        return NULL;
    }

    // if direct write, surface == lfb
    if(search&VID_DIRECT_WRITE) {
        if(surface->num_pages>1) {
            if(surface->mode->flags&LFB) {
                surface->surface=surface->lfb;
                surface->writemode=VID_DIRECT_WRITE;
                surface->Blit = &VIDEOdummy_blitter;
            } else
                surface->writemode=0;
        }
    }

    // if not direct write, allocate a surface for drawing
    if(!surface->writemode)
        switch(bpp) {
            case 4: surface->surface = (UBYTE *)MEMallocate(xsize*ysize);
                    break;
            case 8: surface->surface = (UBYTE *)MEMallocate(xsize*ysize);
                    break;
            case 15:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*2);
                    break;
            case 16:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*2);
                    break;
            case 24:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*3);
                    break;
            case 32:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*4);
                    break;
        };

    if(!surface->surface) {
        MEMfree(surface);
        MEMset_default_tag();
        return NULL;
    }

    // allocate palette buffer for 8bit modes
    if(surface->bpp < 15)
        surface->pal = (UBYTE *)MEMallocate(256*3);
    
    if(!surface->pal && surface->bpp<15) {
        if(!surface->writemode)
            MEMfree(surface->surface);
        MEMfree(surface);
        MEMset_default_tag();
        return NULL;
    }

    MEMset_default_tag();
    
    return surface;
}

SURFACE *VIDEOcreate_surface(UWORD xsize, UWORD ysize, UBYTE bpp)
{
    SURFACE *surface;
    UBYTE   blit_type;


    MEMset_tag(video_tag);

    surface = (SURFACE *)MEMallocate(sizeof(SURFACE));
    if(!surface) {
        return NULL;
        MEMset_default_tag();
    }

    surface->surftype = USER;
    surface->driver = NULL;
    surface->mode   = NULL;
    surface->xsize  = xsize;
    surface->ysize  = ysize;
    surface->bpp    = bpp;
    surface->lfb    = NULL;
    surface->writemode=0;
    surface->pal    = NULL;

    blit_type = VIDEOget_blit_type(bpp);

    surface->Blit = NULL;

    switch(bpp) {
        case 4: surface->surface = (UBYTE *)MEMallocate(xsize*ysize);
                break;
        case 8: surface->surface = (UBYTE *)MEMallocate(xsize*ysize);
                break;
        case 15:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*2);
                break;
        case 16:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*2);
                break;
        case 24:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*3);
                break;
        case 32:surface->surface = (UBYTE *)MEMallocate(xsize*ysize*4);
                break;
    };


    if(!surface->surface) {
        MEMfree(surface);
        MEMset_default_tag();
        return NULL;
    }

    if(surface->bpp < 15)
        surface->pal = (UBYTE *)MEMallocate(256*3);
    
    if(!surface->pal && surface->bpp<15) {
        if(!surface->writemode)
            MEMfree(surface->surface);
        MEMfree(surface);
        MEMset_default_tag();
        return NULL;
    }

    MEMset_default_tag();
    return surface;
}

int VIDEOset_surface(SURFACE *surface)
{
    UWORD   xsize, ysize, search;
    UBYTE   bpp, err;
    MODE    *mode;

    if(surface->surftype & NORMAL) {
        surface->driver->SetMode(surface->mode);
        current_mode = surface->mode;
        return 0; 
    }

    xsize = surface->xsize;
    ysize = surface->ysize;
    bpp = surface->bpp;

    search = VID_EXACT;

    // fallback stuff

    mode=VIDEOget_mode(xsize, ysize, bpp, search);

    if(!mode) {
        search = VID_BESTMATCH + VID_EXACT_SIZE + VID_LARGER_BPP;
        mode=VIDEOget_mode(xsize, ysize, bpp, search);
    }
    if(!mode) {
        search = VID_BESTMATCH + VID_LARGER_SIZE + VID_LARGER_BPP;
        mode=VIDEOget_mode(xsize, ysize, bpp, search);
    }            
    if(!mode) {
        search = VID_BESTMATCH + VID_LARGER_SIZE + VID_SMALLER_BPP;
        mode=VIDEOget_mode(xsize, ysize, bpp, search);
    }
    if(!mode)
        return VIDERR_CANT_SET_MODE;;

    surface->mode=mode;
    err=mode->driver->SetModeBackup(surface);
    current_mode=mode;

    if(err)
        return VIDERR_CANT_SET_MODE;

    if(mode->ysize>=ysize && mode->xsize>=xsize) {
        surface->x = (mode->xsize - xsize) / 2;
        surface->y = (mode->ysize - ysize) / 2;
    } else {
        surface->x = 0;
        surface->y = 0;
    }

    surface->lfb = mode->lfb;

    return 0;
}

int VIDEOset_custom_blit(SURFACE *surface, void (*blit)(SURFACE *surface))
{
    if(!surface)
        return NULL;

    surface->Blit = blit;

    return VIDOK;;
}

int VIDEOblit_surface(SURFACE *surface)
{
    if(surface->Blit) {
        surface->Blit(surface);
    }

    return 0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// PALETTE FUNCTIONS:                                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int VIDEOset_palette(SURFACE *surface)
{
    int     i, j;

    if(surface->bpp > 8)
        return 1;
    
    for(i=0, j=0; i<256; i++) {
        OUTB(0x3C8, i);
        OUTB(0x3C9, surface->pal[j++]);
        OUTB(0x3C9, surface->pal[j++]);
        OUTB(0x3C9, surface->pal[j++]);
    }

    return 0;
}

int VIDEOget_palette(SURFACE *surface)
{
    int     i, j;

    if(surface->bpp > 8)
        return 1;
    
    for(i=0, j=0; i<256; i++) {
        OUTB(0x3C7, i);
        surface->pal[j++] = INB(0x3C9);
        surface->pal[j++] = INB(0x3C9);
        surface->pal[j++] = INB(0x3C9);
    }

    return 0;
}

int VIDEOset_colour(SURFACE *surface, UBYTE col, UBYTE r, UBYTE g, UBYTE b)
{
    if(surface->bpp > 8)
        return 1;

    surface->pal[col*3]=r;
    surface->pal[col*3+1]=g;
    surface->pal[col*3+2]=b;

    OUTB(0x3C8, col);
    OUTB(0x3C9, r);
    OUTB(0x3C9, g);
    OUTB(0x3C9, b);

    return 0;
}

int VIDEOget_colour(SURFACE *surface, UBYTE col, UBYTE *r, UBYTE *g, UBYTE *b)
{
    if(surface->bpp > 8)
        return 1;

    OUTB(0x3C7, col);
    
    *r = INB(0x3C9);
    *g = INB(0x3C9);
    *b = INB(0x3C9);
    
    surface->pal[col*3]=*r;
    surface->pal[col*3+1]=*g;
    surface->pal[col*3+2]=*b;
    
    return 0;
}
