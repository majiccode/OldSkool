//
// Video Interface TestBed
//
//
//

#include <conio.h>

#include "video.h"
#include "vesa2.h"


main(void)
{
    SURFACE     *myscreen;
    int         x, y, err;
    UWORD       search;
    UWORD       p, *lfb;
    UDWORD      offset;
    MODE *mode;

    // Initalise the Video Interface:
    printf("\nInitalising Video Interface...\n");
    err=VIDEOopen();
    if(err) {
        printf("\nVIDERR: %s", VIDEOget_error(err));
        exit(1);
    }
        

    // Open an inline driver ready for use:
    printf("Opening Video Driver...\n");
    err=VIDEOopen_driver(&vesa2_driver);
    if(err) {
        printf("\nVIDERR: %s", VIDEOget_error(err));
        exit(1);
    }

    printf("Opening Surface...\n");

    search = VID_EXACT | VID_DIRECT_WRITE; //VID_BESTMATCH | VID_SMALLER_BPP | VID_LARGER_SIZE;

    myscreen = VIDEOopen_surface(640, 480, 16, search);

//    myscreen = VIDEOcreate_surface(640, 400, 15);

    if(!myscreen) {
        VIDEOclose();
        printf("\nVIDERR: cant open surface\n\n");
        exit(1);
    }


    err=VIDEOset_surface(myscreen);

    if(err) {
        VIDEOclose_surface(myscreen);
        VIDEOclose();
        printf("Driver does not support required blit conversion!!\n");
        exit(1);
    }
    

    mode=myscreen->mode;


    for(y=0; y<myscreen->ysize; y++)
        for(x=0; x<myscreen->xsize; x++) {
            offset = y*myscreen->xsize*2 + x*2;
            myscreen->surface[offset] = 0xFF;
            myscreen->surface[offset+1] = 0x80;

        }


    getch();

    VIDEOblit_surface(myscreen);

    getch();

/*

    VIDEOset_surface(myscreen);

 
    p=PACKRGB15(31,0,0);

    lfb = (UWORD *)myscreen->surface;

    lfb[100*(320) + 160] = p;

    myscreen->Blit(myscreen);
  
    getch();

*/

    printf("Closing Surface...\n");
    VIDEOclose_surface(myscreen);

    printf("X=%d, Y=%d, BPP=%d\n\n",mode->xsize,mode->ysize,mode->bpp);
    
    // Close the Video Interface:
    printf("Closing Interface....\n");
    VIDEOclose();

    
    return 0;
}
