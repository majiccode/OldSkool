#include "l3d.h"
#include <time.h>
#include <dos.h>
#include "font.h"
#include <math.h>

ubyte   *vid;

void ClearMMX(void *where, long size) {
	__asm {
		mov edi,[where]
		pxor mm0,mm0
		pxor mm1,mm1
		pxor mm2,mm2
		pxor mm3,mm3
		pxor mm4,mm4
		pxor mm5,mm5
		pxor mm6,mm6
		pxor mm7,mm7
		mov ecx, [size]    // 64000*4/64 = 4000
		mov ebx, ecx
		shr ecx, 4         // 64000*1/16 = 4000
		jz ClearSlow
      ClearIt64:
		movq [edi+0], mm0
		movq [edi+8], mm1
		movq [edi+16], mm2
		movq [edi+24], mm3
		movq [edi+32], mm4
		movq [edi+40], mm5
		movq [edi+48], mm6
		movq [edi+56], mm7
		add edi, 64
		dec ecx
		jnz ClearIt64

     ClearSlow:
		and ebx,0xf
		jz Quit
      ClearIt4:
	       movd [edi], mm0
	       add edi, 4
	       dec ebx
	       jnz ClearIt4
	  Quit:
		emms
	};
}

void CopyMMX(void *dest, void *source, long size) {
	__asm {
		mov esi,[source]
		mov edi,[dest]
		mov ecx, [size]
		mov ebx, ecx
		shr ecx, 4
		jz CopySlow
      CopyIt64:
		movq mm0, [esi]
		movq mm1, [esi+8]
		movq mm2, [esi+16]
		movq mm3, [esi+24]
		movq mm4, [esi+32]
		movq mm5, [esi+40]
		movq mm6, [esi+48]
		movq mm7, [esi+56]
		movq [edi+0], mm0
		movq [edi+8], mm1
		movq [edi+16], mm2
		movq [edi+24], mm3
		movq [edi+32], mm4
		movq [edi+40], mm5
		movq [edi+48], mm6
		movq [edi+56], mm7
		add esi, 64
		add edi, 64
		dec ecx
		jnz CopyIt64
      CopySlow:
		and ebx, 0xf
		jz Quit
		lea esi,[esi+ebx*4]
		lea edi,[edi+ebx*4]
		neg ebx
       CopyIt4:
		movd mm0, [esi+ebx*4]
		movd [edi+ebx*4], mm0
		inc ebx
		jnz CopyIt4
	  Quit:
		emms
	};
}



void show_dbg_panel(LQ_SCENE *scene, int frame, int duration)
{
    int     x, y;
    char    info[20];
    int     fps;

    if(!duration) duration = 1;
    fps = (int)((float)frame*CLOCKS_PER_SEC/duration);

    y = 10;
    x = LQ_PutStr(10,y,"frame = ", vid);
    itoa(frame, info, 10);
    LQ_PutStr(10+x,y,info,vid);

    y+=FONT_HEIGHT;
    x = LQ_PutStr(10,y,"frames per second = ", vid);
    itoa(fps, info, 10);
    LQ_PutStr(10+x,y,info,vid);
    
    y+=FONT_HEIGHT;
    x = LQ_PutStr(10,y,"faces = ", vid);
    itoa(scene->num_faces, info, 10);
    LQ_PutStr(10+x,y,info, vid);

    y+=FONT_HEIGHT;
    x = LQ_PutStr(10,y,"visable faces = ", vid);
    itoa(scene->num_vis, info, 10);
    LQ_PutStr(10+x,y,info, vid);
}


void init_fpu(void)
{
    unsigned short control_word;

    __asm {
        finit
        fstcw [control_word]
        mov bx,[control_word]
        and bh,0fch  // 24bits precision, no overflow, no divide by zero exceptions
        mov [control_word],bx
        fldcw [control_word]
    };
}



void main(int argc, char *argv[])
{
    int             start, end, frame, kf_frame;
    LQ_SCENE        *scene;
    LQ_KEYFRAMER    keyframer;
    int             i;



    init_fpu();

    vid = (UBYTE *)malloc(320*200);

    scene = LQ_SCENE_Create();

    if(argc < 2) {
        printf("Mode13h DEBUG VERSION\nUsage: test <myfile.3ds>\n");
        exit(1);
    }
    LQ_LoadScene3DS(scene, &keyframer, argv[1]);
    scene->flags    = LQ_SCENE_FRONTBACK;



    VGAclear_screen(vid);
    VGAset_mode(0x13);


    frame = 0;
    kf_frame = 0;
    start = clock();



    while(!kbhit()) {




        if(kf_frame>keyframer.frames)
            kf_frame = 0;
        LQ_SetFrame(scene, &keyframer, kf_frame);
        kf_frame++;


        LQ_RenderScene(scene, scene->camera_list, vid, frame);

       
        show_dbg_panel(scene, frame, clock()-start);

      //  VGAcopy_screen(vid, VGAbuffer);
      //  VGAclear_screen(vid);

        CopyMMX(VGAbuffer, vid, 64000/4);


        ClearMMX(vid, 64000/4);

        frame++;

    }

    VGAset_mode(0x3);


    printf("Mode13h DEBUG VERSION\n\nFaces are given unique colours for debug purposes.  Do not release !!!\n-Paul");
}
