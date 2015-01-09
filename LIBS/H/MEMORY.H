//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         Memory Managment Module                          //
//                                                                          //
//                              version 1.00a                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

#ifndef __MEMORY_H
#define __MEMORY_H

#define MAXTAGS     254         // num tags available to memory manager
#define MAXHEAP     -1

#include    "\libs\h\typedef.h"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Function Prototypes                                                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
UDWORD      MEMavail(void);
UDWORD      MEMused(void);
int         MEMinit(UDWORD heapsize);
int         MEMdeinit(void);
UBYTE       MEMget_unused_tag(void);
void        MEMclear_tags(void);
void        MEMset_tag(UBYTE tag);
void        MEMfree_tag(UBYTE tag);
void        MEMset_default_tag(void);
UWORD       MEMdos_allocate(int size, UWORD *selector);
void        MEMdos_free(UWORD selector);
void       *MEMallocate(UDWORD numbytes);
void       *MEMallocate_named(UDWORD numbytes, char *name);
void        MEMfree(void *block);
void        MEMfree_named(char *name);
void        MEMfree_taged(UDWORD tag);
void        MEMfree_all(void);
UWORD       MEMmake_selector(void *block);
void        MEMfree_selector(UWORD selector);
int         MEMresize(void *block, UDWORD newsize);
int         MEMresize_named(char *name, UDWORD newsize);
void        MEMdefrag(void);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMcopy                                                                  //
//                                                                          //
// copys one memory block to another                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMcopy(void *dest, void *source, UDWORD size);
#pragma aux MEM_copy = \
        "test   ecx,1"\
        "jz     @@write2"\
        "mov    al,[esi]"\
        "mov    [edi],al"\
        "inc    edi"\
        "inc    esi"\
"@@write2:"\
        "test   ecx,2"\
        "jz     @@write4"\
        "mov    ax,[esi]"\
        "mov    [edi],ax"\
        "add    edi,2"\
        "add    esi,2"\
"@@write4:"\
        "test   ecx,4"\
        "jz     @@write8"\
        "mov    eax,[esi]"\
        "mov    [edi],eax"\
        "add    edi,4"\
        "add    esi,4"\
"@@write8:"\
        "sar    ecx,3"\
        "jz     @@donewrite"\
"@@write8l:"\
        "mov    eax,[esi]"\
        "mov    [edi],eax"\
        "add    esi,4"\
        "add    edi,4"\
        "mov    eax,[esi]"\
        "mov    [edi],eax"\
        "add    edi,4"\
        "add    esi,4"\
        "dec    ecx"\
        "jnz    @@write8l"\
"@@donewrite:"\
parm caller [edi] [esi] [ecx]\
modify [eax esi edi ecx];

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MEMset                                                                   //
//                                                                          //
// sets a memory blocks contents to a specified value                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void MEMset(void *dest, UBYTE value, UDWORD size);
#pragma aux MEM_set = \
        "mov    ah,al"\
        "shl    eax,8"\
        "mov    al,ah"\
        "shl    eax,8"\
        "mov    al,ah"\
        "test   ecx,1"\
        "jz     @@write2"\
        "mov    [edi],al"\
        "inc    edi"\
"@@write2:"\
        "test   ecx,2"\
        "jz     @@write4"\
        "mov    [edi],ax"\
        "add    edi,2"\
"@@write4:"\
        "test   ecx,4"\
        "jz     @@write8"\
        "mov    [edi],eax"\
        "add    edi,4"\
"@@write8:"\
        "sar    ecx,3"\
        "jz     @@donewrite"\
"@@write8l:"\
        "mov    [edi],eax"\
        "add    edi,4"\
        "mov    [edi],eax"\
        "add    edi,4"\
        "dec    ecx"\
        "jnz    @@write8l"\
"@@donewrite:"\
parm caller [edi] [eax] [ecx]\
modify [eax edi ecx];

#endif