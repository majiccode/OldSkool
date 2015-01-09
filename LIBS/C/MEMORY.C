#include    <dos.h>
#include    <i86.h>
#include    <stdio.h>
#include    <string.h>
#include    "\libs\h\memory.h"

typedef struct MEMBLOCK {
    struct MEMBLOCK *next;
    void            *memptr;
    UDWORD          size;
    char            name[40];
    char            used;          
    UDWORD          tag;
}   MEMBLOCK;

struct meminfo {                        
    UDWORD          LargestBlockFree;
    UDWORD          MaxUnlocked;
    UDWORD          MaxLocked;
    UDWORD          LinearAddressSize;
    UDWORD          NumUnlockedPages;
    UDWORD          NumFreePages;
    UDWORD          NumPhysicalPages;
    UDWORD          FreeLinearAddressSpace;
    UDWORD          PagingFileSize;
    UDWORD          Reserved[3];
}   MEMINFO;

struct heapinfo {
    UDWORD          heapsize;
    void            *heap;
    UDWORD          freemem;
    UDWORD          handle;
    UDWORD          numallocs;
}   HEAPINFO;

UBYTE               currenttag;    
UBYTE               taglist[MAXTAGS];
UBYTE               errorvalue;
int                 initalised = 0;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMavail                                                                 //
//                                                                          //
// returns the amount of free memory available                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UDWORD MEMavail(void)
{
    union REGS      r;
    struct SREGS    sr;

    memset(&r, 0, sizeof(r));

    segread(&sr);               

    r.w.ax =0x0500;
    sr.es  =FP_SEG(&MEMINFO);    
    r.x.edi=FP_OFF(&MEMINFO);     
    int386x(0x31, &r, &r, &sr);

    return MEMINFO.LargestBlockFree;
}    

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMused                                                                  //
//                                                                          //
// returns memory used currently from heap                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UDWORD MEMused(void)
{
    return (HEAPINFO.heapsize - HEAPINFO.freemem);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMinit                                                                  //
//                                                                          //
// initalises memory manager                                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int MEMinit(UDWORD heapsize)
{
    union REGS      r;
    struct SREGS    sr;
    int             i;

    if(!initalised) {
        memset(&r, 0, sizeof(r));
        segread(&sr);               

        r.w.ax =0x0500;
        sr.es  =FP_SEG(&MEMINFO);     
        r.x.edi=FP_OFF(&MEMINFO);       
        int386x(0x31, &r, &r, &sr);

        if(heapsize == MAXHEAP)
            heapsize = MEMINFO.LargestBlockFree;

        do {
            r.w.ax =0x0501;
            r.w.cx =heapsize & 0x0000FFFF;
            r.w.bx =heapsize >> 16;
            int386(0x31, &r, &r);

            if(r.x.cflag)
                heapsize-=4096;

            if(heapsize < 4096)
                return 0;

        } while(r.x.cflag);

        HEAPINFO.heapsize = heapsize;
        HEAPINFO.handle=(r.w.si << 16) + r.w.di;
        HEAPINFO.heap=(void *) ((r.w.bx << 16) + r.w.cx);
        HEAPINFO.freemem=HEAPINFO.heapsize;
        HEAPINFO.numallocs=0;

        for(i=0; i<MAXTAGS; i++)
            taglist[i]=0;

        currenttag=0;
        initalised=1;
    }

    return 1;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMdeinit                                                                //
//                                                                          //
// de-initalises the memory manager                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int MEMdeinit(void)
{
    union REGS      r;

    initalised=0;

    memset(&r, 0, sizeof(r));

    r.w.ax =0x0502;
    r.w.di =HEAPINFO.handle & 0x0000FFFF;
    r.w.si =HEAPINFO.handle >> 16;
    int386(0x31, &r, &r);

    return(r.x.cflag);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMget_unused_tag                                                        //
//                                                                          //
// returns the next tag available                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UBYTE MEMget_unused_tag(void)
{
    int     i;
   
    for(i=0; i<MAXTAGS; i++)
        if(!taglist[i]) {
            taglist[i]=1;
            return(i+1);
        }

    return 0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMclear_tags                                                            //
//                                                                          //
// clears all tags                                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMclear_tags(void)
{
    int     i;
   
    for(i=0; i<MAXTAGS+1; i++)
        taglist[i]=0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMset_tag                                                               //
//                                                                          //
// sets all memory allocations following to use specified tag id            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMset_tag(UBYTE tag)
{
    currenttag=tag;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree_tage                                                             //
//                                                                          //
// free's a tag id for use again                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree_tag(UBYTE tag)
{
    taglist[tag+1]=0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMset_default_tag                                                       //
//                                                                          //
// sets all memory allocations following to use default tag id              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMset_default_tag(void)
{
    currenttag=0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Allocates Dos Memory Block                                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UWORD MEMdos_allocate(int size, UWORD *selector)
{
    union REGS      r;
    UWORD           ptr = NULL;

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
void MEMdos_free(UWORD selector)
{
    union REGS      r;

    r.w.ax=0x101;
    r.w.dx=selector;
    int386(0x31, &r, &r);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMallocate                                                              //
//                                                                          //
// allocate some memory                                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void *MEMallocate(UDWORD numbytes)
{
    MEMBLOCK    *memblock, *curr, *prev, *next, *tmp;
    UDWORD      size, totalsize;


    if(HEAPINFO.freemem < numbytes)
        MEMdefrag();

    if(HEAPINFO.freemem < numbytes)
        return NULL;

    if(!HEAPINFO.numallocs) {
        memblock=(MEMBLOCK *)HEAPINFO.heap;
        memblock->next=NULL;
        memblock->tag=currenttag;
        memblock->used=1;
        memblock->size=numbytes;
        memblock->memptr=(void *)((char *)HEAPINFO.heap + sizeof(MEMBLOCK));
        HEAPINFO.numallocs=1;
        HEAPINFO.freemem-=numbytes + sizeof(MEMBLOCK);
        return memblock->memptr;
    }

    memblock=(MEMBLOCK *)HEAPINFO.heap;
    curr=memblock;

    while(curr) {
        if(!curr->used) {
            if(curr->size >= numbytes) {
                curr->used=1;
                curr->tag=currenttag;
                size=curr->size - numbytes;
                totalsize=numbytes;
                if(size > sizeof(MEMBLOCK)) {
                    curr->size=numbytes;
                    tmp=curr->next;
                    curr->next=(MEMBLOCK *)((char *)curr->memptr + numbytes);
                    next=curr->next;
                    next->next=tmp;
                    next->tag=currenttag;
                    next->used=0;
                    next->size=size - sizeof(MEMBLOCK);
                    next->memptr=(void *)((char *)next + sizeof(MEMBLOCK));
                    totalsize+=sizeof(MEMBLOCK);
                }

                if((size>0) && (size<=sizeof(MEMBLOCK)))
                    totalsize+=size;

                HEAPINFO.freemem-=totalsize;
                HEAPINFO.numallocs++;
                return curr->memptr;
            }
        }
        prev=curr;
        curr=curr->next;
    }

    next=(MEMBLOCK *)((char *)prev->memptr + prev->size);
    next->used=1;
    next->tag=currenttag;
    next->size=numbytes;
    next->memptr=(void *)((char *)next + sizeof(MEMBLOCK));
    next->next=NULL;
    prev->next=next;
    HEAPINFO.freemem-=numbytes + sizeof(MEMBLOCK);
    HEAPINFO.numallocs++;
    return next->memptr;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMallocate_named                                                        //
//                                                                          //
// allocates a memory block and gives it a name                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void *MEMallocate_named(UDWORD numbytes, char *name)
{
    MEMBLOCK    *memblock, *curr, *prev, *next, *tmp;
    UDWORD      size, totalsize;


    if(HEAPINFO.freemem < numbytes)
        MEMdefrag();

    if(HEAPINFO.freemem < numbytes)
        return NULL;

    if(!HEAPINFO.numallocs) {
        memblock=(MEMBLOCK *)HEAPINFO.heap;
        memblock->next=NULL;
        memblock->tag=currenttag;
        memblock->used=1;
        strcpy(memblock->name, name);

        memblock->size=numbytes;
        memblock->memptr=(void *)((char *)HEAPINFO.heap + sizeof(MEMBLOCK));
        HEAPINFO.numallocs=1;
        HEAPINFO.freemem-=numbytes + sizeof(MEMBLOCK);
        return memblock->memptr;
    }

    memblock=(MEMBLOCK *)HEAPINFO.heap;
    curr=memblock;

    while(curr) {
        if(!curr->used) {
            if(curr->size >= numbytes) {
                curr->used=1;
                strcpy(curr->name, name);
                curr->tag=currenttag;
                size=curr->size - numbytes;
                totalsize=numbytes;
                if(size > sizeof(MEMBLOCK)) {
                    curr->size=numbytes;
                    tmp=curr->next;
                    curr->next=(MEMBLOCK *)((char *)curr->memptr + numbytes);
                    next=curr->next;
                    next->next=tmp;
                    next->tag=currenttag;
                    next->used=0;
                    next->size=size - sizeof(MEMBLOCK);
                    next->memptr=(void *)((char *)next + sizeof(MEMBLOCK));
                    totalsize+=sizeof(MEMBLOCK);
                }

                if((size>0) && (size<=sizeof(MEMBLOCK)))
                    totalsize+=size;

                HEAPINFO.freemem-=totalsize;
                HEAPINFO.numallocs++;
                return curr->memptr;
            }
        }
        prev=curr;
        curr=curr->next;
    }

    next=(MEMBLOCK *)((char *)prev->memptr + prev->size);
    next->used=1;
    next->tag=currenttag;
    next->size=numbytes;
    strcpy(next->name, name);
    next->memptr=(void *)((char *)next + sizeof(MEMBLOCK));
    next->next=NULL;
    prev->next=next;
    HEAPINFO.freemem-=numbytes + sizeof(MEMBLOCK);
    HEAPINFO.numallocs++;
    return next->memptr;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree                                                                  //
//                                                                          //
// free's a specified memory block and gives memory back to heap            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree(void *block)
{
    MEMBLOCK    *memblock;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(memblock->memptr == block) {
            if(memblock->used) {
                memblock->used=0;
                HEAPINFO.freemem+=memblock->size;
                HEAPINFO.numallocs--;
                if(!HEAPINFO.numallocs)
                    HEAPINFO.freemem=HEAPINFO.heapsize;
                return;
            } else
                return;
        }
        memblock=memblock->next;
    }
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree_named                                                            //
//                                                                          //
// free's a named memory block and gives all memory back to heap            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree_named(char *name)
{
    MEMBLOCK    *memblock;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(!strcmp(memblock->name, name)) {
            if(memblock->used) {
                memblock->used=0;
                HEAPINFO.freemem+=memblock->size;
                HEAPINFO.numallocs--;
                if(!HEAPINFO.numallocs)
                    HEAPINFO.freemem=HEAPINFO.heapsize;
                return;
            } else
                return;
        }
        memblock=memblock->next;
    }
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree_taged                                                            //
//                                                                          //
// free's a group of memory blocks that have the specified tag id           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree_taged(UDWORD tag)
{
    MEMBLOCK    *memblock;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(memblock->tag == tag) {
            if(memblock->used) {
                memblock->used=0;
                HEAPINFO.freemem+=memblock->size;
                HEAPINFO.numallocs--;
                if(!HEAPINFO.numallocs)
                    HEAPINFO.freemem=HEAPINFO.heapsize;
            }
        }
        memblock=memblock->next;
    }
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree_all                                                              //
//                                                                          //
// free's all memory that was previously allocated                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree_all(void)
{
    HEAPINFO.freemem=HEAPINFO.heapsize;
    HEAPINFO.numallocs=0;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMmake_selector                                                         //
//                                                                          //
// makes a selector to a memory block                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UWORD MEMmake_selector(void *block)
{
    union REGS      r;
    struct SREGS    sr;
    UWORD           selector;
    UDWORD          address;

    memset(&r, 0, sizeof(r));
    address=(UDWORD)block;

    r.w.ax =0x0000;
    r.w.cx =0x0001;
    int386(0x31, &r, &r);
    selector = r.w.ax;

    r.w.ax =0x0007;
    r.w.bx =selector;
    r.w.cx =address >> 16;
    r.w.dx =address & 0x0000FFFF;
    int386(0x31, &r, &r);

    r.w.ax =0x0008;
    r.w.bx =selector;
    r.w.cx =0xFFFF;
    r.w.dx =0xFFFF;
    int386(0x31, &r, &r);

    return(selector);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMfree_selector                                                         //
//                                                                          //
// free's up the selector to a block of memory                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMfree_selector(UWORD selector)
{
    union REGS      r;

    memset(&r, 0, sizeof(r));

    r.w.ax =0x0001;
    r.w.bx =selector;
    int386(0x31, &r, &r);
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMresize                                                                //
//                                                                          //
// try's to resize a previously allocated memory block                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int MEMresize(void *block, UDWORD newsize)
{
    MEMBLOCK    *memblock, *nextblock, *newblock;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(memblock->memptr == block) {
            if(memblock->size == newsize)
                return 0;    

            if(memblock->next==NULL) {
                if(memblock->size > newsize)
                    HEAPINFO.freemem+=memblock->size-newsize;
                if(memblock->size < newsize)
                    HEAPINFO.freemem-=newsize-memblock->size;
                memblock->size=newsize;
                return 1;
            }

            if(memblock->size < newsize)
                return 0;

            if((memblock->size-newsize) > sizeof(MEMBLOCK)) {
                memblock->size=newsize;
                nextblock=memblock->next;
                memblock->next=(MEMBLOCK *)((char *)memblock->memptr + newsize);
                newblock=memblock->next;
                newblock->used=0;
                newblock->memptr=(char *)newblock + sizeof(MEMBLOCK);
                newblock->next=nextblock;
                HEAPINFO.freemem+=memblock->size-newsize-sizeof(MEMBLOCK);
            }

            return 0;
        }
        memblock=memblock->next;
    }

    return 1;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMresize_named                                                          //
//                                                                          //
// try's to resize a previously allocated memory block                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int MEMresize_named(char *name, UDWORD newsize)
{
    MEMBLOCK    *memblock, *nextblock, *newblock;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(!strcmp(memblock->name, name)) {
            if(memblock->size == newsize)
                return 0;

            if(memblock->next==NULL) {
                if(memblock->size > newsize)
                    HEAPINFO.freemem+=memblock->size-newsize;
                if(memblock->size < newsize)
                    HEAPINFO.freemem-=newsize-memblock->size;
                memblock->size=newsize;
                return 1;
            }

            // adjacent block so, cant expand, only shrink!
            if(memblock->size < newsize)
                return 0;

            // shrink memory block
            if((memblock->size-newsize) > sizeof(MEMBLOCK)) {
                memblock->size=newsize;
                nextblock=memblock->next;
                memblock->next=(MEMBLOCK *)((char *)memblock->memptr + newsize);
                newblock=memblock->next;
                newblock->used=0;
                newblock->memptr=(char *)newblock + sizeof(MEMBLOCK);
                newblock->next=nextblock;
                HEAPINFO.freemem+=memblock->size-newsize-sizeof(MEMBLOCK);
            }

            return 0;
        }
        memblock=memblock->next;
    }
    return 1;
}

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMdefrag                                                                //
//                                                                          //
// trys to defragment allocated memory blocks                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMdefrag(void)
{
    MEMBLOCK    *memblock, *nextblock;
    int         numadjacent, totalsize, memgained;

    memblock=(MEMBLOCK *)HEAPINFO.heap;

    while(memblock) {
        if(!memblock->used) {
                nextblock=memblock->next;
                numadjacent=0;
                totalsize=0;
                while(!nextblock->used) {
                    numadjacent++;
                    totalsize+=nextblock->size + sizeof(MEMBLOCK);
                }

                memgained=numadjacent * sizeof(MEMBLOCK);
                HEAPINFO.freemem += memgained;

                if(numadjacent > 0) {
                    memblock->size += totalsize;
                    memblock->next = nextblock;
                }
                
        }
        memblock=memblock->next;
    }
}
