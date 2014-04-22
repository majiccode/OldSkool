#include "l3d.h"   
#include <math.h>
// uncomment all lines for zbuffering

// test filler to check engine output.. subpixel accuracy to make sure screen
// clipping is perfect.. 
void LQ_POLY_FlatFill(LQ_TRIPOINT *p1, LQ_TRIPOINT *p2, LQ_TRIPOINT *p3, ubyte col)
{
    LQ_TRIPOINT *p;
    LQ_EDGE     left_edge, right_edge, edgeA, edgeB;
    int         a, b, c, d;
    int         iY1, iY2, iY3, y;
    int         left_side_longest;
    int         h1, h2, h3;
    float       tmp, subpix, length;
    float       h;
    float       doozdx;

    ubyte       *outbuf, *span;
    float       *outzbuf, *spanz, *endspanz;
    int         start, end;
    float       z, endz;

#define SWAP_POINT(a,b) {p=b; b=a; a=p;}

    // sort vertices in y order:
    if(p2->y < p1->y)
        SWAP_POINT(p1, p2)
    if(p3->y < p1->y)
        SWAP_POINT(p1, p3)
    if(p3->y < p2->y)
        SWAP_POINT(p2, p3)

#undef SWAP_POINT


    // snap vertices on pixels:
    iY1 = ceil(p1->y);
    iY2 = ceil(p2->y);
    iY3 = ceil(p3->y);

    outbuf = active_surface + (iY1 * 320);

    outzbuf = zbuffer + (iY1 * 320);
    
    // calculate longest scanline:
    h1                  = iY3 - iY1;
    h                   = p3->y - p1->y;
    if(!h1) return;
    tmp                 = (p2->y - p1->y) / h;
    length              = ((p3->x - p1->x) * tmp) + (p1->x - p2->x);
    left_side_longest   = (length <= 0);

    // calculate any deltas for moving across polygon:
    doozdx = (tmp * (p3->ooz - p1->ooz) + (p1->ooz - p2->ooz)) / length;


    // calculations for deltas on edge y3y1
    edgeA.dx        = (p3->x - p1->x) / h;
    subpix          = iY1 - p1->y;
    edgeA.x         = p1->x + edgeA.dx*subpix;
    if(left_side_longest) {
        left_edge   = edgeA;

        left_edge.dooz = (p3->ooz - p1->ooz) / h;
        left_edge.ooz = p1->ooz + left_edge.dooz*subpix;
    } else
        right_edge  = edgeA;


    // calculations for deltas on edge y2y1
    h2              = iY2 - iY1;
    if(!h2) goto do_section_2;
    h               = p2->y - p1->y;
    edgeB.dx        = (p2->x - p1->x) / h;
    edgeB.x         = p1->x + edgeB.dx*subpix;
    if(left_side_longest)
        right_edge  = edgeB;
    else {
        left_edge   = edgeB;

        left_edge.dooz = (p2->ooz - p1->ooz) / h;
        left_edge.ooz = p1->ooz + left_edge.dooz*subpix;
    }


///////////////////////////////////////////////////
//                                               //
//                 SECTION 1:                    //
//                                               //
///////////////////////////////////////////////////

    for(y=0; y<h2; y++) {
        start   = ceil(left_edge.x);
        end     = ceil(right_edge.x);
        z       = left_edge.ooz;
        span    = outbuf + start;
        spanz   = outzbuf + start;


        for(; start<end; start++) {
            if(z+LQ_frame>*spanz) {
                *span = col;
                *spanz = z+LQ_frame;
            }
            span++;
            spanz++;
            z += doozdx;
        }

        left_edge.x     += left_edge.dx;
        left_edge.ooz   += left_edge.dooz;
        right_edge.x    += right_edge.dx;

        outbuf += 320;
        outzbuf += 320;
    }


///////////////////////////////////////////////////
//                                               //
//                 SECTION 2:                    //
//                                               //
///////////////////////////////////////////////////
do_section_2:

    h3              = iY3 - iY2;
    if(!h3) return;
    h               = p3->y - p2->y;
    edgeB.dx        = (p3->x - p2->x) / h;
    subpix          = iY2 - p2->y;
    edgeB.x         = p2->x + edgeB.dx*subpix;

    if(left_side_longest)
        right_edge  = edgeB;
    else {
        left_edge   = edgeB;
        left_edge.dooz = (p3->ooz - p2->ooz) / h;
        left_edge.ooz = p2->ooz + left_edge.dooz*subpix;
    }

    for(y=0; y<h3; y++) {
        start   = ceil(left_edge.x);
        end     = ceil(right_edge.x);
        z       = left_edge.ooz;
        span    = outbuf + start;
        spanz   = outzbuf + start;


        for(; start<end; start++) {
            if(z+LQ_frame>*spanz) {
                *span = col;
                *spanz = z + LQ_frame;
            }
            span++;
            spanz++;
            z += doozdx;
        }


        left_edge.x     += left_edge.dx;
        left_edge.ooz   += left_edge.dooz;
        right_edge.x    += right_edge.dx;

        outbuf += 320;
        outzbuf += 320;
    }

}
