/* 
 * raytracing plane/tunnel
 *
 *
 * u,v coords at each vertex are scaled by 256 before entering the renderer
 * to simplify delta calculations
 *
 *
 * some shitty c code for you all...
 *
 *
 * hiya... since this is such an old effect.. infact this code dates back
 * to 1997 or sometime around then i thought i'd put it up on my www page :)
 *
 * some unused stuff in here but well, you never know.. if i remember 
 * correctly i was gona make something with this.. i never did however as
 * always :)
 *
 * oh yeah, to bring it up to date i ripped a cool texture map from 303
 * demo. now you can add some metaballs and recreate the entire scene
 * yourself ;)
 *
 *
 *                                                         frenzy^LiQUiD
 */

#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <time.h>


#include "\libs\h\memory.h"
#include "\libs\h\fmaths.h"
#include "\libs\h\vga.h"
#include "\libs\h\control.h"


#define BYTE(a)     (a & 255)
#define INDEX(x,y)  ((BYTE(y) << 8) + BYTE(x))
#define RANDOM(a)   (rand()%a)

#define XSIZE       320
#define YSIZE       200

#define BLOCK       3
#define BLOCKSIZE   (1<<BLOCK)

#define XGRID_SIZE  (XSIZE / BLOCKSIZE)+1
#define YGRID_SIZE  (YSIZE / BLOCKSIZE)+1

typedef struct {
    float   x, y, z;
}   VECTOR3;


typedef float MATRIX3[3*3];

typedef struct {
    float   px, py, pz;
    float   tx, ty, tz;
    MATRIX3 mat;
}   CAMERA;

MATRIX3 mat;

typedef struct {
    int     u, v, z, c;
}   UVCOORDS;


UVCOORDS    tunnel_grid[XGRID_SIZE][YGRID_SIZE];
ubyte       *screen;
char        shadetable[256][256];
char        shadetable2[256][256];


void VEClerp(VECTOR3 *a, VECTOR3 *b, VECTOR3 *c, float t)
{
    a->x = (1-t)*b->x + t*c->x;
    a->y = (1-t)*b->y + t*c->y;
    a->z = (1-t)*b->z + t*c->z;
}

void GetMouseMove(short int *xmove,short int *ymove)
{
    union REGS regs;

    regs.w.ax = 0x0B;
    int386(0x33, &regs, &regs);
    *xmove = (signed int)regs.w.cx;
    *ymove = (signed int)regs.w.dx;
}


void GetMouseButtons(int *lbutton, int *mbutton, int*rbutton)
{
    union REGS regs;
    short int temp;
    
    regs.w.ax = 0x03;
    int386(0x33, &regs, &regs);
    temp = regs.w.bx;

    *lbutton = temp & 0x0001;
    temp = temp >> 1;
    *rbutton = temp & 0x0001;
    temp = temp >> 1;
    *mbutton = temp & 0x0001;
}


void makeshades(char *palette, char shadetab[][256])
{
    int           r, g, b;
    int           i, j, k;
    unsigned int  bestmatch, shade, bestshade;


    for(i=0; i<256; i++)
        for(j=0; j<256; j++) {

            // set to imposible value
            bestshade=-1; 

            r = (palette[j*3] * i) / 256;
            g = (palette[j*3+1] * i) / 256;
            b = (palette[j*3+2] * i) / 256;

            for(k=0; k<256; k++) {
                shade =abs(r - palette[k*3]);
                shade+=abs(g - palette[k*3+1]);
                shade+=abs(b - palette[k*3+2]);

                if(shade<bestshade) {
                    bestmatch=k;
                    bestshade=shade;
                }
            }
            shadetab[j][i]=bestmatch;
        }
}

char value(int c, int val, int d)
{
    int p;
    if(val==0)
     val=1;
    p = (c + val - RANDOM(val<<1) ) / d - 1;
    p = (p>255) ? 255 : p;
    p = (p<0) ? 0 : p;
  
    return p;
}

// notice, i dont use recursion ;)
void gen_plasma(ubyte *map, int seed, float scale)
{
    int     x, y, x2, y2, i;
    int     xm, ym, p1, p2, p3, p4;
    int     val;

    memset(map, 0, 256*256);

    srand(seed);
    map[INDEX(RANDOM(255),RANDOM(255))] = RANDOM(255);

    for(i=256; i>=1; i>>=1)          
        for(y=0; y<=256; y+=i)       
            for(x=0; x<=256; x+=i) { 
                x2 = x+i;
                y2 = y+i;
                xm = (i>>1) + x;
                ym = (i>>1) + y;
                val = (x2-x + y2-y)*scale;
                p1=map[INDEX(x,y)];
                p2=map[INDEX(x,y2)];
                p3=map[INDEX(x2,y)];
                p4=map[INDEX(x2,y2)];
                map[INDEX(xm,y)]=value(p1+p3, val, 2);
                map[INDEX(x,ym)]=value(p1+p2, val, 2);
                map[INDEX(x2,ym)]=value(p3+p4, val, 2);
                map[INDEX(xm,y2)]=value(p2+p4, val, 2);
                map[INDEX(xm,ym)]=value(p1+p2+p3+p4, val, 4);
            }
}

void build_rot_matrix(float xan, float yan, float zan)
{
    float       cx, cy, cz, sx, sy, sz;

    xan = xan * PI / 180.0;
    yan = yan * PI / 180.0;
    zan = zan * PI / 180.0;

    cx=fcos(xan); cy=fcos(yan); cz=fcos(zan);
    sx=fsin(xan); sy=fsin(yan); sz=fsin(zan);

//       cy*cz              cy*sz          -sy         Ax  Bx  Cx
// sx*sy*cz - cx*sz   sx*sy*sz + cx*cz    sx*cy  ==    Ay  By  Cy
// cx*sy*cz + sx*sz   cx*sy*sz - sx*cz    cx*cy        Az  Bz  Cz

    mat[0] = cy*cz;
    mat[1] = cy*sz;
    mat[2] = -sy;

    mat[3] = sx*sy*cz - cx*sz;
    mat[4] = sx*sy*sz + cx*cz;
    mat[5] = sx*cy;


    mat[6] = cx*sy*cz + sx*sz;
    mat[7] = cx*sy*sz - sx*cz;
    mat[8] = cx*cy;
}

void update_camera(CAMERA *camera)
{
    float   nx, ny, nz;
    float   vx, vy, vz;
    float   ux, uy, uz;
    float   l;

    nx = camera->tx - camera->px;
    ny = camera->ty - camera->py;
    nz = camera->tz - camera->pz;

    l = fsqrt(nx*nx + ny*ny + nz*nz);
    if(l==0.0)
        l = 1.0;
    l=1/l;
    nx *= l;
    ny *= l;
    nz *= l;
    vx = -nx*ny;
    vy = 1-(ny*ny); 
    vz = -nz*ny;
    l = fsqrt(vx*vx + vy*vy + vz*vz);
    if(l==0.0)
        l = 1.0;
    l=1/l;
    vx *= l;
    vy *= l;
    vz *= l;
    ux = vy*nz - vz*ny;
    uy = vz*nx - vx*nz;
    uz = vx*ny - vy*nx;
    camera->mat[0]=ux; camera->mat[1]=uy; camera->mat[2]=uz;
    camera->mat[3]=vx; camera->mat[4]=vy; camera->mat[5]=vz;
    camera->mat[6]=nx; camera->mat[7]=ny; camera->mat[8]=nz;
}


/////////////////////////////////////////////////////////////////////////////


void calc_tunnel(CAMERA *cam)
{
    int     i, j;
    float   l;
    float   x, y, z;
    float   nx, ny, nz;
    float   ox, oy, oz;
    float   ix, iy, iz;
    float   a, b, c, d, r, t, t1, t2, s;
    ubyte   col;
    int     u, v;

    r = 256;
    for(j=0; j<YGRID_SIZE; j++)
        for(i=0; i<XGRID_SIZE; i++) {
            x = (i*BLOCKSIZE) - 160;
            y = (j*BLOCKSIZE) - 100;
            z = 256;
            nx = x*mat[0] + y*mat[3] + z*mat[6];
            ny = x*mat[1] + y*mat[4] + z*mat[7];
            nz = x*mat[2] + y*mat[5] + z*mat[8];
            l = nx*nx + ny*ny + nz*nz;
            if(l==0.0) l=1.0;
            l = fsqrt(l);
            nx /= l;
            ny /= l;
            nz /= l;

            ox = cam->px;
            oy = cam->py;
            oz = cam->pz;

            a = nx*nx + ny*ny;
            b = 2*(ox*nx + oy*ny);
            c = ox*ox + oy*oy - r*r;

            d = (b*b) - (4*a*c);

            if(d < 0) {
                u = 128;
                v = 128;
            } else {

                t1 = (-b + fsqrt(d))/(2*a);
                t2 = (-b - fsqrt(d))/(2*a);
                t = fmin(t1, t2);               
                ix = ox + t*nx;
                iy = oy + t*ny;
                iz = oz + t*nz;
                u = (int)(fabs(iz)*0.2);
                v = (int)(fabs(fatan(iy, ix)*256/PI));
            }

            ix-=ox;
            iy-=oy;
            iz-=oz;
            s = fsqrt(ix*ix + iy*iy + iz*iz);
            tunnel_grid[i][j].u = u*256;
            tunnel_grid[i][j].v = v*256;
            tunnel_grid[i][j].z = iz;
            tunnel_grid[i][j].c = (int)(  256 - (255.0*s / 2000.0) );
            if(tunnel_grid[i][j].c > 255)
                tunnel_grid[i][j].c = 255;
            if(tunnel_grid[i][j].c < 0)
                tunnel_grid[i][j].c = 0;
            tunnel_grid[i][j].c *= 256;


        }
}

void calc_plane(CAMERA *cam)
{
    int     i, j;
    float   l;
    float   x, y, z;
    float   nx, ny, nz;
    float   ox, oy, oz;
    float   ix, iy, iz;
    float   d, t, s;
    int     u, v;

    ox = cam->px;
    oy = cam->py;
    oz = cam->pz;
    d = 20000;
    for(j=0; j<YGRID_SIZE; j++)
        for(i=0; i<XGRID_SIZE; i++) {
            x = (float) (i<<3) - 160;
            y = (float) (j<<3) - 100;
            z = 256;
            nx = x*mat[0] + y*mat[3] + z*mat[6];
            ny = x*mat[1] + y*mat[4] + z*mat[7];
            nz = x*mat[2] + y*mat[5] + z*mat[8];

            l = nx*nx + ny*ny + nz*nz;
            if(l==0.0) l=1.0;
            l = fsqrt(l);
            nx /= l;
            ny /= l;
            nz /= l;

            if(ny>0.0) {
                t = -(oy+d) / ny;
                ix = ox + t*nx;
                iy = oy + t*ny;
                iz = oz + t*nz;
                u = (int)((iz)*0.01);
                v = (int)((ix)*0.01);
            } else {
                ny=-ny;
                t = (oy-d) / ny;
                ix = ox + t*nx;
                iy = oy + t*ny;
                iz = oz + t*nz;
                u = (int)((iz)*0.01);
                v = (int)((ix)*0.01);
            }
            ix -= ox;
            iy -= oy;
            iz -= oz;

            s = 256 - (fabs(t)/1000);
            if(s > 255)
                s = 255;
            if(s < 0)
                s = 0;

            tunnel_grid[i][j].u = u<<8;
            tunnel_grid[i][j].v = v<<8;
            tunnel_grid[i][j].c = (int)(s*256);
        }
}


//!put in assembler!
void render_grid(ubyte *dst, ubyte *texture)
{
    int     i, j;
    int     tlu, tlv, tru, trv, blu, blv, bru, brv, tlc, trc, blc, brc;
    int     ldu, rdu, ldv, rdv, ldc, rdc, du, dv, dc, tmp;
    int     u, v, c, startu1, startv1, startu2, startv2, startc1, startc2;
    int     x, y;
    int     pos, pos2, shade;
    ubyte   col;

    for(j=0; j<YGRID_SIZE-1; j++)
        for(i=0; i<XGRID_SIZE-1; i++) {
            tlu = tunnel_grid[i][j].u;
            tlv = tunnel_grid[i][j].v;
            tlc = tunnel_grid[i][j].c;

            tru = tunnel_grid[i+1][j].u;
            trv = tunnel_grid[i+1][j].v;
            trc = tunnel_grid[i+1][j].c;

            bru = tunnel_grid[i+1][j+1].u;
            brv = tunnel_grid[i+1][j+1].v;
            brc = tunnel_grid[i+1][j+1].c;
    
            blu = tunnel_grid[i][j+1].u;
            blv = tunnel_grid[i][j+1].v;
            blc = tunnel_grid[i][j+1].c;

            ldu = (blu-tlu) >> BLOCK;
            ldv = (blv-tlv) >> BLOCK;
            ldc = (blc-tlc) >> BLOCK;

            rdu = (bru-tru) >> BLOCK;
            rdv = (brv-trv) >> BLOCK;
            rdc = (brc-trc) >> BLOCK;

            startu1 = tlu;
            startv1 = tlv;
            startc1 = tlc;

            startu2 = tru;
            startv2 = trv;
            startc2 = trc;


            pos=j*BLOCKSIZE*320 + i*BLOCKSIZE;
            for(y=0; y<BLOCKSIZE; y++) {
                u = startu1;
                v = startv1;
                c = startc1;

                du = (startu2 - startu1) >> BLOCK;
                dv = (startv2 - startv1) >> BLOCK;
                dc = (startc2 - startc1) >> BLOCK;

                pos2 = pos;
                for(x=0; x<BLOCKSIZE; x++) {
                    col = texture[(v&0xFF00) + (u>>8&0xFF)];
                    col = shadetable[col][(c>>8)];

                    dst[pos2++] = col;
                    u+=du; v+=dv; c+=dc;
                }
                pos+=320;
                startu1 += ldu;
                startv1 += ldv;
                startc1 += ldc;
                startu2 += rdu;
                startv2 += rdv;
                startc2 += rdc;
            }
        }
}

/////////////////////////////////////////////////////////////////////////////

void main(void)
{
    CAMERA  cam;
    ubyte   *texture;
    int     i,j,x,y;
    short   mx,my,oldx,oldy;
    int     b1, b2, b3;
    float   xan, yan, zan;
    float   rad, ang;
    char    palette[768], palette2[768];
    FILE    *fp;
    VECTOR3 dir;
    float   dx,dy,dz,vel;
    int     temps, frames=0;
    int     temps2, frames2=0;

    const char *banner =
    "\n\n"
    "Plane/Tunnel effect with Depth Cue, Paul Adams 1997\n\n"
    "Use mouse to move around, left button moves forwards, right mouse button rotate z-axis\n"
    "Press any key to move to next effect.\n\n"
    "Please wait while I calculate some lookup tables....";


    MEMinit(MAXHEAP);

    screen = (ubyte *)MEMallocate(320*200);
    texture = (ubyte *)MEMallocate(0x20000);
    texture = (ubyte *)(((unsigned long)texture + 0xFFFF) & ~0xFFFF);


    VGAclear_screen(screen);

    puts(banner);

    for(i=0; i<256; i++) {
        palette2[i*3+0] = i/4;
        palette2[i*3+1] = i/5;
        palette2[i*3+2] = i/7;
    }
  
    fp=fopen("a.raw", "rb");
    fread(palette, 768, 1, fp);
    fread(texture, 256*256, 1, fp);
  
    makeshades(palette, shadetable);
    makeshades(palette2, shadetable2);

    VGAset_mode(0x13);

    VGAset_palette(palette);


    cam.px = 0.0; cam.py = 0.0; cam.pz = -128.0;
    cam.tx = 0.0; cam.ty = 0.0; cam.tz = 128.0;

    dir.x = 0;
    dir.y = 0;
    dir.z = 1;

    GetMouseMove(&oldx, &oldy);
    oldx>>=2;
    oldy>>=2;
    xan = 0.0;
    yan = 0.0;
    zan = 0.0;


    temps = clock();
    while(!kbhit()) {
        GetMouseButtons(&b1, &b2, &b3);
        GetMouseMove(&mx, &my);
        mx>>=2; my>>=2;
        if(mx!=oldx) {
            yan+=mx;
            oldx=yan;
        }
        if(my!=oldy) {
            xan+=my;
            oldy=xan;
        }
        if(b3) zan+=2.0;
        
        build_rot_matrix(xan, yan, zan);
        dx = dir.x*mat[0] + dir.y*mat[3] + dir.z*mat[6];
        dy = dir.x*mat[1] + dir.y*mat[4] + dir.z*mat[7];
        dz = dir.x*mat[2] + dir.y*mat[5] + dir.z*mat[8];

        if(b1) {
            cam.px -= 256*dx;
            cam.py -= 256*dy;
            cam.pz -= 256*dz;
        }

        calc_plane(&cam);

        render_grid(screen, texture);

        VGAcopy_screen(screen, VGAbuffer);
        frames++;
        if(frames==5000)
            break;
    }
    temps = clock() - temps;

    getch();
    for(j=0; j<256; j++)
        for(i=0; i<256; i++)
            shadetable[i][j] = shadetable2[i][j];

    gen_plasma(texture, 897232, 2.8);
    VGAset_palette(palette2);


    cam.px = 0.0; cam.py = 0.0; cam.pz = -128.0;
    cam.tx = 0.0; cam.ty = 0.0; cam.tz = 128.0;

    dir.x = 0;
    dir.y = 0;
    dir.z = 1;

    GetMouseMove(&oldx, &oldy);
    oldx>>=2;
    oldy>>=2;
    xan = 0.0;
    yan = 0.0;
    zan = 0.0;


    temps2 = clock();
    while(!kbhit()) {
        GetMouseButtons(&b1, &b2, &b3);
        GetMouseMove(&mx, &my);
        mx>>=2; my>>=2;
        if(mx!=oldx) {
            yan+=mx;
            oldx=yan;
        }
        if(my!=oldy) {
            xan+=my;
            oldy=xan;
        }
        if(b3) zan+=2.0;
        
        build_rot_matrix(xan, yan, zan);
        dx = dir.x*mat[0] + dir.y*mat[3] + dir.z*mat[6];
        dy = dir.x*mat[1] + dir.y*mat[4] + dir.z*mat[7];
        dz = dir.x*mat[2] + dir.y*mat[5] + dir.z*mat[8];
        if(b1) {
            cam.px -= 5*dx;
            cam.py -= 5*dy;
            cam.pz -= 20*dz;

            if(cam.py>128)  cam.py=128;
            if(cam.py<-128) cam.py=-128;
            if(cam.px>128)  cam.px=128;
            if(cam.px<-128) cam.px=-128;
        }


        calc_tunnel(&cam);

        render_grid(screen, texture);

        VGAcopy_screen(screen, VGAbuffer);
        frames2++;
    }
    temps2 = clock() - temps;

    VGAset_mode(3);

    MEMdeinit();

    printf("%f frames per seconds for plane \n",((float)frames*CLOCKS_PER_SEC)/temps);
    printf("%f frames per seconds for tunnel \n",((float)frames2*CLOCKS_PER_SEC)/temps2);

}
