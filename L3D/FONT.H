#ifndef __FONT_H__
#define __FONT_H__

#include <string.h>

#define FONT_HEIGHT 6

typedef struct {
    char    c;
    int     x1, y1, x2, y2;
}   FONTTAB;

FONTTAB fonttab[] = {
    {'a', 0,    0,  3,  4},
    {'b', 5,    0,  8,  4},
    {'c', 10,   0,  13, 4},
    {'d', 15,   0,  18, 4},
    {'e', 20,   0,  23, 4},
    {'f', 25,   0,  28, 4},
    {'g', 30,   0,  33, 4},
    {'h', 35,   0,  38, 4},
    {'i', 40,   0,  42, 4},
    {'j', 44,   0,  47, 4},
    {'k', 49,   0,  52, 4},
    {'l', 54,   0,  57, 4},
    {'m', 59,   0,  63, 4},
    {'n', 65,   0,  68, 4},
    {'o', 70,   0,  73, 4},
    {'p', 75,   0,  78, 4},
    {'q', 80,   0,  83, 4},
    {'r', 85,   0,  88, 4},
    {'s', 90,   0,  93, 4},
    {'t', 95,   0,  99, 4},
    {'u', 101,  0,  104,4},
    {'v', 106,  0,  110,4},
    {'w', 112,  0,  116,4},
    {'x', 118,  0,  122,4},
    {'y', 124,  0,  128,4},
    {'z', 130,  0,  134,4},
    {' ', 0,    0,  4,  0},     // 26
    {'0', 136,  0,  139,4},     // 27
    {'1', 141,  0,  143,4},     //
    {'2', 145,  0,  148,4},
    {'3', 150,  0,  153,4},
    {'4', 155,  0,  159,4},
    {'5', 161,  0,  164,4},
    {'6', 166,  0,  169,4},
    {'7', 171,  0,  174,4},
    {'8', 176,  0,  179,4},
    {'9', 181,  0,  184,4},     // 36

    {'!', 188,  0,  188,4},     // 37
    {'?', 190,  0,  193,4},     // 
    {':', 195,  0,  195,4},     // 
    {';', 197,  0,  198,4},     //
    {'.', 200,  0,  200,4},     // 
    {'(', 202,  0,  203,4},     // 
    {')', 205,  0,  206,4},     // 
    {'-', 208,  0,  210,4},     // 
    {'+', 212,  0,  214,4},     // 
    {'=', 216,  0,  219,4},     // 47

    };

int num_fonttab_entries = sizeof(fonttab) / sizeof(FONTTAB);

unsigned char font[]={
    0,15,15,0,0,15,15,15,0,0,0,15,15,15,0,15,15,15,0,
    0,15,15,15,15,0,15,15,15,15,0,0,15,15,15,0,15,0,0,
    15,0,15,15,15,0,0,15,15,15,0,15,0,0,15,0,15,0,0,0,
    0,0,15,0,15,0,0,15,0,0,15,0,0,15,15,0,0,15,15,15,
    0,0,0,15,15,0,0,15,15,15,0,0,0,15,15,15,0,15,15,15,
    15,15,0,15,0,0,15,0,15,0,0,0,15,0,15,0,0,0,15,0,15,
    0,0,0,15,0,15,0,0,0,15,0,15,15,15,15,15,0,0,15,15,
    0,0,15,15,0,0,0,15,15,0,0,0,15,15,0,0,0,0,0,15,0,0,
    15,15,15,15,0,0,15,15,15,0,15,15,15,15,0,0,15,15,0,
    0,0,15,15,0,0,0,0,15,0,0,15,15,0,0,0,0,0,0,0,0,0,0,
    15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,15,0,15,0,0,15,0,
    15,0,0,0,0,15,0,0,15,0,15,0,0,0,0,15,0,0,0,0,15,0,0,
    0,0,15,0,0,15,0,0,15,0,0,0,0,0,15,0,15,0,15,0,0,15,0,
    0,0,0,15,0,15,0,15,0,15,15,0,15,0,15,0,0,15,0,15,0,0,
    15,0,15,0,0,15,0,15,0,0,15,0,15,0,0,0,0,0,0,15,0,0,0,
    15,0,0,15,0,15,0,0,0,15,0,15,0,0,0,15,0,0,15,0,15,0,0,
    15,0,0,0,15,0,0,0,0,15,0,0,15,0,0,15,0,0,15,0,0,15,0,
    0,15,0,15,0,0,15,0,0,0,15,15,0,0,15,0,0,0,0,15,0,0,0,
    0,0,0,15,0,0,15,0,0,15,0,15,0,0,15,0,0,0,15,0,15,0,0,
    15,0,15,0,0,15,0,0,0,15,0,0,0,15,0,0,0,0,0,0,15,0,0,15,
    15,15,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,15,15,15,0,
    15,15,15,0,0,15,0,0,0,0,15,0,0,15,0,15,15,15,0,0,15,15,
    15,0,0,15,0,15,15,0,15,15,15,15,0,0,15,0,0,0,0,0,15,0,15,
    15,0,0,0,15,0,0,0,0,15,0,0,0,15,0,15,0,15,15,0,15,0,0,15,
    0,15,15,15,0,0,15,0,0,15,0,15,15,15,0,0,0,15,15,0,0,0,0,
    15,0,0,0,15,0,0,15,0,15,0,0,0,15,0,15,0,0,0,15,0,0,0,15,0,
    0,0,0,15,0,15,0,0,0,0,15,0,0,0,15,0,0,15,0,0,15,0,0,0,0,15,
    0,0,0,0,15,0,0,0,15,0,15,0,0,15,15,15,0,0,15,15,15,0,0,0,15,
    0,0,0,0,15,15,0,0,0,15,15,15,0,0,0,15,0,0,0,15,0,0,0,0,0,0,
    0,0,0,15,0,0,0,15,0,15,15,15,0,15,15,15,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,15,0,0,15,0,15,0,0,15,0,15,0,0,0,0,15,0,0,15,0,15,
    0,0,0,0,15,0,0,0,0,15,0,0,15,0,15,0,0,15,0,0,15,0,0,15,0,0,15,
    0,15,0,15,0,0,15,0,0,0,0,15,0,0,0,15,0,15,0,0,15,0,15,0,0,15,0,
    15,0,0,0,0,15,0,15,0,0,15,0,0,15,0,0,0,0,15,0,0,0,15,0,0,0,15,0,
    0,15,0,0,15,0,15,0,0,15,0,15,0,15,0,0,15,0,15,0,0,0,0,15,0,0,0,0,
    15,0,0,0,0,15,0,0,15,0,0,15,0,0,0,15,0,0,0,15,0,0,15,0,15,15,15,
    15,15,0,0,0,0,15,0,15,0,0,15,0,0,15,0,0,0,15,0,0,15,0,0,0,0,15,0,
    0,0,0,0,0,0,0,0,0,15,0,0,15,0,0,0,15,0,0,0,15,0,0,0,0,0,0,15,0,0,
    15,15,15,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,15,0,0,15,0,15,15,15,0,0,0,15,15,15,0,15,15,15,0,0,15,
    15,15,15,0,15,0,0,0,0,0,15,15,0,0,15,0,0,15,0,15,15,15,0,0,15,15,0,
    0,15,0,0,15,0,15,15,15,15,0,15,0,0,0,15,0,15,0,0,15,0,0,15,15,0,0,
    15,0,0,0,0,0,15,0,15,0,15,0,0,15,0,15,15,15,0,0,0,0,15,0,0,0,0,15,
    15,0,0,0,0,15,0,0,0,0,15,0,15,0,0,15,0,0,0,15,0,0,0,15,0,0,0,15,15,
    15,15,15,0,0,15,15,0,0,15,15,15,0,15,15,15,15,0,0,15,15,0,0,0,0,0,15,
    0,0,15,15,15,0,0,0,15,15,0,0,0,15,0,0,0,0,15,15,0,0,0,0,0,15,0,0,0,15,
    0,0,0,15,0,0,0,0,15,0,0,15,0,0,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int LQ_PutChar(int x, int y, char c, ubyte *buf)
{
    int     i, j, k;
    int     idx;
    int     offset, foffset;

    if(c == ' ')
        return 26;
    else if(c >= 'a' && c <= 'z')
            idx = (int)(c - 'a');
         else if(c >= '0' && c <= '9')
            idx = (int)(c - '0') + 27;
              else {
                for(i=37; i<num_fonttab_entries; i++)
                    if(c == fonttab[i].c) {
                        idx = i;
                        break;
                    }
              }

    offset = y*320 + x;
    foffset = fonttab[idx].y1 * 320;

    for(j=fonttab[idx].y1; j<=fonttab[idx].y2; j++) {

        for(i=fonttab[idx].x1,k=0; i<=fonttab[idx].x2; i++,k++)
            if(font[foffset+i]) 
                buf[offset + k] = font[foffset + i];

        offset += 320;
        foffset += 320;
    }

    return idx;
}

int LQ_PutStr(int x, int y, char *s, ubyte *buf)
{
    int     idx;

    while(*s) {
        idx = LQ_PutChar(x, y, *s++, buf);
        x += fonttab[idx].x2 - fonttab[idx].x1 + 2;
    }
    return x;
}

#endif
