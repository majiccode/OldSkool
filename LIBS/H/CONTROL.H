//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//                         SYSTEM CONTROL FUNCTIONS                         //
//                               version 1.0                                //
//                                                                          //
//                       Copyright (c)1997 Paul Adams                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


#ifndef __CONTROL_H
#define __CONTROL_H

#include    "\libs\h\typedef.h"

#define PENTIUM_TIMER   0     
#define PIT_TIMER       1

extern volatile uint    VRItime;
extern volatile uint    VRIactive;
extern                  void (*VRIfunc)(void);
extern long double      TIME_CONSTANT;
extern uchar            *KBDbuffer, *KBDkeys;
extern uchar            KBDhit;

#define SECONDS(a)      (a/TIME_CONSTANT)

#define KEY_ESC            0x01
#define KEY_F1             0x3b
#define KEY_F2             0x3c
#define KEY_F3             0x3d
#define KEY_F4             0x3e
#define KEY_F5             0x3f
#define KEY_F6             0x40
#define KEY_F7             0x41
#define KEY_F8             0x42
#define KEY_F9             0x43
#define KEY_F10            0x44
#define KEY_F11            0x57
#define KEY_F12            0x58
#define KEY_SYSRQ          0xb7
#define KEY_SCROLLLOCK     0x46 
#define KEY_TICK           0x29 
#define KEY_1              0x02
#define KEY_2              0x03
#define KEY_3              0x04
#define KEY_4              0x05
#define KEY_5              0x06
#define KEY_6              0x07
#define KEY_7              0x08
#define KEY_8              0x09
#define KEY_9              0x0a
#define KEY_0              0x0b
#define KEY_MINUS          0x0c
#define KEY_EQUAL          0x0d
#define KEY_BACKSPACE      0x0e
#define KEY_INSERT         0xd2
#define KEY_HOME           0xc7
#define KEY_PAGEUP         0xc9
#define KEY_NUMLOCK        0x45 
#define KEY_PADSLASH       0xb5
#define KEY_PADSTAR        0x37
#define KEY_PADMINUS       0x4a
#define KEY_TAB            0x0f
#define KEY_Q              0x10
#define KEY_W              0x11
#define KEY_E              0x12
#define KEY_R              0x13
#define KEY_T              0x14
#define KEY_Y              0x15
#define KEY_U              0x16
#define KEY_I              0x17
#define KEY_O              0x18
#define KEY_P              0x19
#define KEY_LEFTBRACKET    0x1a
#define KEY_RIGHTBRACKET   0x1b
#define KEY_BACKSLASH      0x2b
#define KEY_DELETE         0xd3
#define KEY_END            0xcf
#define KEY_PAGEDOWN       0xd1
#define KEY_PAD7           0x47
#define KEY_PAD8           0x48
#define KEY_PAD9           0x49
#define KEY_PADPLUS        0x4e
#define KEY_CAPSLOCK       0x3a
#define KEY_A              0x1e
#define KEY_S              0x1f
#define KEY_D              0x20
#define KEY_F              0x21
#define KEY_G              0x22
#define KEY_H              0x23
#define KEY_J              0x24
#define KEY_K              0x25
#define KEY_L              0x26
#define KEY_SEMICOLON      0x27
#define KEY_APOSTROPHE     0x28
#define KEY_ENTER          0x1c
#define KEY_PAD4           0x4b
#define KEY_PAD5           0x4c
#define KEY_PAD6           0x4d
#define KEY_LEFTSHIFT      0x2a
#define KEY_Z              0x2c 
#define KEY_X              0x2d
#define KEY_C              0x2e
#define KEY_V              0x2f
#define KEY_B              0x30
#define KEY_N              0x31
#define KEY_M              0x32
#define KEY_COMMA          0x33
#define KEY_PERIOD         0x34
#define KEY_SLASH          0x35
#define KEY_RIGHTSHIFT     0x36
#define KEY_UPARROW        0xc8
#define KEY_PAD1           0x4f
#define KEY_PAD2           0x50
#define KEY_PAD3           0x51
#define KEY_PADENTER       0x9c
#define KEY_LEFTCTRL       0x1d
#define KEY_LEFTWINDOW     0xdb
#define KEY_LEFTALT        0x38 
#define KEY_SPACE          0x39
#define KEY_RIGHTALT       0xb8 
#define KEY_RIGHTWINDOW    0xdc
#define KEY_KEYBOARDMOUSE  0xdd
#define KEY_RIGHTCTRL      0x9d
#define KEY_LEFTARROW      0xcb
#define KEY_DOWNARROW      0xd0
#define KEY_RIGHTARROW     0xcd
#define KEY_PAD0           0x52
#define KEY_PADPERIOD      0x53


typedef enum {
    CPU8086,
    CPU80286,
    CPU80386,
    CPU80486,
    PENTIUM
}   CPUID;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// MISC functions                                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
CPUID       SYScpuid(void);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// VRI functions                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void        VRIinit(void);
void        VRIhook(void);
void        VRIremove(void);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// TMR functions                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
int         TMRinit(int timer_type);
#pragma aux TMRinit parm caller [eax] value [eax]
void        TMRremove(void);
long double TMRgettime(void);
#pragma aux TMRgettime value [8087]

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// IRQ functions                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void        IRQmaskon(int irqnum);
#pragma aux IRQmaskon =         \
            "mov    ah,1"       \
            "shl    ah,cl"      \
            "xor    ah,0FFh"    \
            "in     al,21h"     \
            "and    al,ah"      \
            "out    21h,al"     \
parm caller [ecx] modify [eax];

void        IRQmaskoff(int irqnum);
#pragma aux IRQmaskoff =        \
            "mov    ah,1"       \
            "shl    ah,cl"      \
            "in     al,21h"     \
            "or     al,ah"      \
            "out    21h,al"     \
parm caller [ecx] modify [eax];

void        CLI(void);
#pragma aux CLI =               \
            "pushad"            \
            "mov    ax,900h"    \
            "int    31h"        \
            "popad";

void        STI(void);
#pragma aux STI =               \
            "pushad"            \
            "mov    ax,901h"    \
            "int    31h"        \
            "popad";

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// I/O functions                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
uchar       INB(int port);
#pragma aux INB =               \
            "in     al,dx"      \
parm caller [edx] value [al];

void        OUTB(int port, uchar value);
#pragma aux OUTB =              \
            "out    dx,al"      \
parm caller [edx] [eax];

int         INW(int port);
#pragma aux INW =               \
            "in     ax,dx"      \
parm caller [edx] value [eax];

void        OUTW(int port, int value);
#pragma aux OUTW =              \
            "out    dx,ax"      \
parm caller [edx] [eax];


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// KBD functions                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
void        KBDhook(void);
void        KBDremove(void);
int         KBDpressed(int key);
#pragma aux KBDpressed parm caller [eax] value [eax]
int         KBDgetkey(int key);
#pragma aux KBDpressed parm caller [eax] value [eax]
void        KBDflush(void);

#endif
