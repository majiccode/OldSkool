// vesa display driver v1.0
// ----------------------------
// frenzy, do not spread this source. thank you.

#include <i86.h>
#include <dos.h>
#include <string.h>

#pragma pack(1);

typedef struct {
  long            signature;
  unsigned short  version;
  long            oemstrptr;
  char            capabilities[4];
  unsigned long   videomodeptr;
  unsigned short  totalmemory;
  char            reserved[236];
} t_vesainfo;

typedef struct {
  unsigned short  modeattributes;
  char            winaattributes;
  char            winbattributes;
  unsigned short  wingranularity;
  unsigned short  winsize;
  unsigned short  winasegment;
  unsigned short  winbsegment;
  int             winfuncptr;
  unsigned short  bytesperscanline;

  unsigned short  xresolution;
  unsigned short  yresolution;
  char            xcharsize;
  char            ycharsize;
  char            numberofplanes;
  char            bitsperpixel;
  char            numberofbanks;
  char            memorymodel;
  char            banksize;
  char            numberofimagepages;
  char            reserved;

  char            redmasksize;
  char            redfieldposition;
  char            greenmasksize;
  char            greenfieldposition;
  char            bluemasksize;
  char            bluefieldposition;
  char            rsvdmasksize;
  char            rsvdfieldposition;
  char            directcolormodeinfo;

  int             physbaseptr;
  int             offscreenmemoffset;
  unsigned short  offscreenmemsize;
  char            reserved2[206];
} t_modeinfo;

#pragma pack();

t_modeinfo *modeinfo;
unsigned short modeinfoseg;
unsigned short modeinfosel;

t_vesainfo *vesainfo;
unsigned short vesainfoseg;
unsigned short vesainfosel;

char *screen,*realscreen;

static struct rminfo {
    long EDI;
    long ESI;
    long EBP;
    long reserved_by_system;
    long EBX;
    long EDX;
    long ECX;
    long EAX;
    short flags;
    short ES,DS,FS,GS,IP,CS,SP,SS;
} RMI;

void rmint(int num)
{
  union REGS regs;
  struct SREGS sregs;

  segread(&sregs);
   /* Use DMPI call 300h to issue the DOS interrupt */
    regs.w.ax = 0x0300;
    regs.h.bl = num;
    regs.h.bh = 0;
    regs.w.cx = 0;
    sregs.es = FP_SEG(&RMI);
    regs.x.edi = FP_OFF(&RMI);
    int386x( 0x31, &regs, &regs, &sregs );
}

int mapphys(int addr,int size)
{
  union REGS r;

  r.w.ax = 0x800;
  r.w.bx = addr >> 16;
  r.w.cx = addr & 0xffff;
  r.w.si = size >> 16;
  r.w.di = size & 0xffff;
  int386(0x31,&r,&r);
  return(r.w.bx << 16 | r.w.cx);
}

void freephys(int addr)
{
  union REGS r;

  r.w.ax = 0x801;
  r.w.bx = addr >> 16;
  r.w.cx = addr & 0xffff;
  int386(0x31,&r,&r);
}

int dosalloc(int size,unsigned short *sel)
{
  union REGS r;
  int i;

  size += 15;
  size = size >> 4;
  r.w.ax = 0x100;
  r.w.bx = size;
  int386(0x31,&r,&r);
  *sel = r.w.dx;
  i = r.w.ax;
  return(i);
}

int getvesainfo(void)
{
  RMI.EAX = 0x4f00;
  RMI.ES = vesainfoseg;
  rmint(0x10);
  return(0);
}

int getmodeinfo(int mode)
{
  RMI.EAX = 0x4f01;
  RMI.ECX = mode;
  RMI.EDI = 0;
  RMI.ES = modeinfoseg;
  rmint(0x10);
  return(0);
}

int setvesamode(int mode)
{
  getmodeinfo(mode);
  RMI.EAX = 0x4f02;
  RMI.EBX = mode;
  RMI.ES = modeinfoseg;
  rmint(0x10);
  return(0);
}

void initvesa(void)
{
  vesainfoseg = dosalloc(256,&vesainfosel);
  vesainfo = (t_vesainfo *) ((int) vesainfoseg << 4);

  getvesainfo();
  modeinfoseg = dosalloc(256,&modeinfosel);
  modeinfo = (t_modeinfo *) ((int) modeinfoseg << 4);
}

void donevesa(void)
{
  _dos_freemem(vesainfosel);
  _dos_freemem(modeinfosel);
}

void (*screendump)(void);
int currentpage;
int pagesize;
int xs,ys;

setvesastart(int n)
{
  RMI.EAX = 0x4f07;
  RMI.EBX = 0x0000;
  RMI.ECX = n % xs;
  RMI.EDX = n / xs;
  RMI.ES = modeinfoseg;
  rmint(0x10);
}

setbank(int n)
{
  RMI.EAX = 0x4f05;
  RMI.EBX = 0x0000;
  RMI.EDX = n*(64/modeinfo->wingranularity);
  RMI.ES = modeinfoseg;
  rmint(0x10);
}

dump1()
{
  memcpy(realscreen,screen,xs*ys);
}

dump2()
{
  screen = realscreen + currentpage;
  currentpage = pagesize - currentpage;
  setvesastart(currentpage);
}

dump3()
{
  int n;

  while (n < (xs*ys) >> 16)
  {

    setbank(n);
    memcpy(realscreen,screen+(n << 16),0x10000);
    n++;

  }

  setbank(n);
  memcpy(realscreen,screen+(n << 16),(xs*ys)-(n << 16));

}

setmode(int);
#pragma aux setmode = "int 10h" parm [eax] modify nomemory;

gfx_Init(int xsize,int ysize,int bits)
{

  int i,m;
  signed short *p;

  xs = xsize*(bits >> 3);
  ys = ysize;

  initvesa();

  p = (short*)((vesainfo->videomodeptr & 0xffff) +
              ((vesainfo->videomodeptr >> 16) << 4));

  i = m = 0;

  while (*(p+i) != -1)
  {

    getmodeinfo(*(p+i));

    if ((modeinfo->xresolution == xsize) &&
        (modeinfo->yresolution == ysize) &&
        (modeinfo->bitsperpixel == bits)) m = *(p+i);

    i++;

  }

  if (m)
  {

    getmodeinfo(m);

    if (modeinfo->modeattributes & 0x80)
    {

      realscreen = (char*)mapphys(modeinfo->physbaseptr,
                                  vesainfo->totalmemory << 16);
      setvesamode(m+0x4000);

      if (vesainfo->totalmemory-1 < (xsize*ysize*(bits >> 3)) >> 15)
      {

        screen = (char*)malloc(xsize*ysize*(bits >> 3));
        screendump = &dump1;

      }
      else
      {

        screen = realscreen;
        currentpage = 0;
        pagesize = (xsize*ysize*(bits >> 3) + 65535) & 0xffff0000;
        screen += pagesize;
        screendump = &dump2;

      }

    }
    else
    {

      realscreen = (char*)0xa0000;
      setvesamode(m);
      screen = (char*)malloc(xsize*ysize*(bits >> 3));
      screendump = &dump3;

    }

  }

  return (m);

}

gfx_Close()
{

  donevesa();

  setmode(3);

}
