///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// clipping functions
//      initial version:
//
////////////
#include "l3d.h"


int LQ_ClipLeft(LQ_TRIFACE_CLIP *in, LQ_TRIFACE_CLIP *out, int num)
{
    int         i, num_out;
    LQ_VERTEX   *curr, *next;
    ubyte       cin, nin;
    float       t;
    float       dx, dy, dz;

    num_out = 0;
    for(i=0; i<num; i++) {
        curr = &in[i].v;
        next = &in[(i+1)%num].v;

        cin = (curr->x >= -curr->z);
        nin = (next->x >= -next->z);

        if(cin)
            out[num_out++] = in[i];

        if(cin != nin) {
            dx = next->x - curr->x;
            dy = next->y - curr->y;
            dz = next->z - curr->z;

            t = (curr->x + curr->z) / (-dz-dx);

            out[num_out].v.x = curr->x + t*dx;
            out[num_out].v.y = curr->y + t*dy;
            out[num_out].v.z = curr->z + t*dz;
            num_out++;
        }
    }

    return num_out;
}    


int LQ_ClipRight(LQ_TRIFACE_CLIP *in, LQ_TRIFACE_CLIP *out, int num)
{
    int         i, num_out;
    LQ_VERTEX   *curr, *next;
    ubyte       cin, nin;
    float       t;
    float       dx, dy, dz;

    num_out = 0;
    for(i=0; i<num; i++) {
        curr = &in[i].v;
        next = &in[(i+1)%num].v;

        cin = (curr->x <= curr->z);
        nin = (next->x <= next->z);

        if(cin)
            out[num_out++] = in[i];

        if(cin != nin) {
            dx = next->x - curr->x;
            dy = next->y - curr->y;
            dz = next->z - curr->z;

            t = (curr->x - curr->z) / (-dx+dz);

            out[num_out].v.x = curr->x + t*dx;
            out[num_out].v.y = curr->y + t*dy;
            out[num_out].v.z = curr->z + t*dz;
            num_out++;
        }
    }

    return num_out;
}    

int LQ_ClipTop(LQ_TRIFACE_CLIP *in, LQ_TRIFACE_CLIP *out, int num)
{
    int         i, num_out;
    LQ_VERTEX   *curr, *next;
    ubyte       cin, nin;
    float       t;
    float       dx, dy, dz;

    num_out = 0;
    for(i=0; i<num; i++) {
        curr = &in[i].v;
        next = &in[(i+1)%num].v;

        cin = (curr->y <= curr->z);
        nin = (next->y <= next->z);

        if(cin)
            out[num_out++] = in[i];

        if(cin != nin) {
            dx = next->x - curr->x;
            dy = next->y - curr->y;
            dz = next->z - curr->z;

            t = (curr->y - curr->z) / (-dy+dz);

            out[num_out].v.x = curr->x + t*dx;
            out[num_out].v.y = curr->y + t*dy;
            out[num_out].v.z = curr->z + t*dz;
            num_out++;
        }
    }

    return num_out;
}    


int LQ_ClipBottom(LQ_TRIFACE_CLIP *in, LQ_TRIFACE_CLIP *out, int num)
{
    int         i, num_out;
    LQ_VERTEX   *curr, *next;
    ubyte       cin, nin;
    float       t;
    float       dx, dy, dz;

    num_out = 0;
    for(i=0; i<num; i++) {
        curr = &in[i].v;
        next = &in[(i+1)%num].v;

        cin = (curr->y >= -curr->z);
        nin = (next->y >= -next->z);

        if(cin)
            out[num_out++] = in[i];

        if(cin != nin) {
            dx = next->x - curr->x;
            dy = next->y - curr->y;
            dz = next->z - curr->z;

            t = (curr->y + curr->z) / (-dz-dy);

            out[num_out].v.x = curr->x + t*dx;
            out[num_out].v.y = curr->y + t*dy;
            out[num_out].v.z = curr->z + t*dz;
            num_out++;
        }
    }

    return num_out;
}    

int LQ_ClipZNear(LQ_TRIFACE_CLIP *in, LQ_TRIFACE_CLIP *out, int num)
{
    int         i, num_out;
    LQ_VERTEX   *curr, *next;
    ubyte       cin, nin;
    float       t;
    float       dx, dy, dz;

    num_out = 0;
    for(i=0; i<num; i++) {
        curr = &in[i].v;
        next = &in[(i+1)%num].v;

        cin = (curr->z > 50);
        nin = (next->z > 50);

        if(cin)
            out[num_out++] = in[i];

        if(cin != nin) {
            dx = next->x - curr->x;
            dy = next->y - curr->y;
            dz = next->z - curr->z;

            t = (50.0 - curr->z) / dz;

            out[num_out].v.x = curr->x + t*dx;
            out[num_out].v.y = curr->y + t*dy;
            out[num_out].v.z = curr->z + t*dz;
            num_out++;
        }
    }

    return num_out;
}    


LQ_TRIFACE_CLIP *LQ_ClipFace(LQ_TRIFACE *face, int *num_verts)
{
    int                 n = 3;
    LQ_TRIMESH          *obj = face->obj;
    LQ_TRIFACE_CLIP     *in, *out, *swap;

    clip_in[0].v = obj->vertexR[face->v1];
    clip_in[1].v = obj->vertexR[face->v2];
    clip_in[2].v = obj->vertexR[face->v3];
  

    in = clip_in;
    out = clip_out;

//        n = LQ_ClipZNear(in, out, n);
//        swap = in;
//        in = out;
//        out = swap;


    if(LQ_ISFLAG(face->flags, LQ_FACE_CLIP_LEFT)) {
        n = LQ_ClipLeft(in, out, n);
        swap = in;
        in = out;
        out = swap;
    }

    if(LQ_ISFLAG(face->flags, LQ_FACE_CLIP_RIGHT)) {
        n = LQ_ClipRight(in, out, n);
        swap = in;
        in = out;
        out = swap;
    }

    if(LQ_ISFLAG(face->flags, LQ_FACE_CLIP_TOP)) {
        n = LQ_ClipTop(in, out, n);
        swap = in;
        in = out;
        out = swap;
    }

    if(LQ_ISFLAG(face->flags, LQ_FACE_CLIP_BOTTOM)) {
        n = LQ_ClipBottom(in, out, n);
        swap = in;
        in = out;
        out = swap;
    }

    *num_verts = n;
    return in;
}
