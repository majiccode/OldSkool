//
// Example Code:
//
//
//


#include "vesa.h"


void VESAerror(int err)
{
    switch(err) {
        case VESAERR_NO_DOS_MEM:

            printf("Not enough base memory!!!\n");
            break;

        case VESAERR_NO_VESA:

            printf("No VESA driver found, install UNIVBE!!!\n");
            break;

        case VESAERR_BAD_VERSION:

            printf("You require VESA2.0+ to run this program!!!\n");
            break;

        case VESAERR_NO_MEM:

            printf("Not enough memory!!!\n");
            break;

        default:

            printf("Internal Error\n");
            break;
    }

    exit(1);
}

main(void)
{
    int     err;
    SURFACE *screen;

    // initalise VESA driver:
    err=VESAdetect();

    if(err)
        VESAerror(err);

    // open a surface:
    screen=VESAopen_surface(320, 200, 8, LINEAR_MODE);
    if(!screen) {
        printf("640x480x16bits (LFB) not present!!!\n");
        exit(1);
    }                


    screen->lfb[100*320 + 160] = 50;

    getch();

    //
    // mode is now set! we have our pointer to video ram at:
    //      myscreen->lfb
    //
    // you can now put some pixels!! :)
    //


    // close surface:
    VESAclose_surface(screen);

    // shutdown VESA:
    VESAshutdown();

    // set mode back to dos:
    VESAset_mode(0x3);

    return 0;
}
