///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// maths module:
//      initial version:
//
////////////
#include "l3d.h"
#include "sqrt.h"
#include <math.h>

void LQ_MatrixIdent(LQ_MATRIX4 m)
{
    m[XX] = 1.0; m[XY] = 0.0; m[XZ] = 0.0; m[WX] = 0.0;
    m[YX] = 0.0; m[YY] = 1.0; m[YZ] = 0.0; m[WY] = 0.0;
    m[ZX] = 0.0; m[ZY] = 0.0; m[ZZ] = 1.0; m[WZ] = 0.0;
    m[TX] = 0.0; m[TY] = 0.0; m[TZ] = 0.0; m[WW] = 1.0;
}    

void LQ_MatrixScale(LQ_MATRIX4 m, float sx, float sy, float sz)
{
    LQ_MatrixIdent(m);
    m[XX] = sx;
    m[YY] = sy;
    m[ZZ] = sz;
}

void LQ_MatrixTranslate(LQ_MATRIX4 m, float x, float y, float z)
{
    LQ_MatrixIdent(m);
    m[TX] = x;
    m[TY] = y;
    m[TZ] = z;
}

void LQ_MatrixMul(LQ_MATRIX4 a, LQ_MATRIX4 b, LQ_MATRIX4 o)
{
    o[XX] = a[XX]*b[XX] + a[XY]*b[YX] + a[XZ]*b[ZX] + a[TX]*b[WX];
    o[XY] = a[XX]*b[XY] + a[XY]*b[YY] + a[XZ]*b[ZY] + a[TX]*b[WY];
    o[XZ] = a[XX]*b[XZ] + a[XY]*b[YZ] + a[XZ]*b[ZZ] + a[TX]*b[WZ];
    o[TX] = a[XX]*b[TX] + a[XY]*b[TY] + a[XZ]*b[TZ] + a[TX]*b[WW];

    o[YX] = a[YX]*b[XX] + a[YY]*b[YX] + a[YZ]*b[ZX] + a[TY]*b[WX];
    o[YY] = a[YX]*b[XY] + a[YY]*b[YY] + a[YZ]*b[ZY] + a[TY]*b[WY];
    o[YZ] = a[YX]*b[XZ] + a[YY]*b[YZ] + a[YZ]*b[ZZ] + a[TY]*b[WZ];
    o[TY] = a[YX]*b[TX] + a[YY]*b[TY] + a[YZ]*b[TZ] + a[TY]*b[WW];

    o[ZX] = a[ZX]*b[XX] + a[ZY]*b[YX] + a[ZZ]*b[ZX] + a[TZ]*b[WX];
    o[ZY] = a[ZX]*b[XY] + a[ZY]*b[YY] + a[ZZ]*b[ZY] + a[TZ]*b[WY];
    o[ZZ] = a[ZX]*b[XZ] + a[ZY]*b[YZ] + a[ZZ]*b[ZZ] + a[TZ]*b[WZ];
    o[TZ] = a[ZX]*b[TX] + a[ZY]*b[TY] + a[ZZ]*b[TZ] + a[TZ]*b[WW];

    o[WX] = a[WX]*b[XX] + a[WY]*b[YX] + a[WZ]*b[ZX] + a[WW]*b[WX];
    o[WY] = a[WX]*b[XY] + a[WY]*b[YY] + a[WZ]*b[ZY] + a[WW]*b[WY];
    o[WZ] = a[WX]*b[XZ] + a[WY]*b[YZ] + a[WZ]*b[ZZ] + a[WW]*b[WZ];
    o[WW] = a[WX]*b[TX] + a[WY]*b[TY] + a[WZ]*b[TZ] + a[WW]*b[WW];
}

void LQ_MatrixMul3(LQ_MATRIX4 a, LQ_MATRIX4 b, LQ_MATRIX4 o)
{
    o[XX] = a[XX]*b[XX] + a[XY]*b[YX] + a[XZ]*b[ZX];
    o[XY] = a[XX]*b[XY] + a[XY]*b[YY] + a[XZ]*b[ZY];
    o[XZ] = a[XX]*b[XZ] + a[XY]*b[YZ] + a[XZ]*b[ZZ];

    o[YX] = a[YX]*b[XX] + a[YY]*b[YX] + a[YZ]*b[ZX];
    o[YY] = a[YX]*b[XY] + a[YY]*b[YY] + a[YZ]*b[ZY];
    o[YZ] = a[YX]*b[XZ] + a[YY]*b[YZ] + a[YZ]*b[ZZ];

    o[ZX] = a[ZX]*b[XX] + a[ZY]*b[YX] + a[ZZ]*b[ZX];
    o[ZY] = a[ZX]*b[XY] + a[ZY]*b[YY] + a[ZZ]*b[ZY];
    o[ZZ] = a[ZX]*b[XZ] + a[ZY]*b[YZ] + a[ZZ]*b[ZZ];
}

void LQ_MatrixTranspose(LQ_MATRIX4 m, LQ_MATRIX4 o)
{
    o[XX] = m[XX]; o[XY] = m[YX]; o[XZ] = m[ZX];
    o[YX] = m[XY]; o[YY] = m[YY]; o[YZ] = m[ZY];
    o[ZX] = m[XZ]; o[ZY] = m[YZ]; o[ZZ] = m[ZZ];
    o[TX] = m[WX]; o[TY] = m[WY]; o[TZ] = m[WZ];
    o[WX] = m[TX]; o[WY] = m[TY]; o[WZ] = m[TZ];
    o[WW] = m[WW];
}

void LQ_MatrixCopy(LQ_MATRIX4 in, LQ_MATRIX4 out)
{
    int     i;

    for(i=0; i<16; i++)
        out[i] = in[i];
}

void LQ_MatrixInverse3(LQ_MATRIX4 m, LQ_MATRIX4 o)
{
    o[XX] = m[XX]; o[XY] = m[YX]; o[XZ] = m[ZX];
    o[YX] = m[XY]; o[YY] = m[YY]; o[YZ] = m[ZY];
    o[ZX] = m[XZ]; o[ZY] = m[YZ]; o[ZZ] = m[ZZ];
    o[TX] = 0.0;   o[TY] = 0.0;   o[TZ] = 0.0;
    o[WX] = 0.0;   o[WY] = 0.0;   o[WZ] = 0.0;
    o[WW] = 1.0;
}

void LQ_SetMatrixPreTrans(LQ_MATRIX4 m, LQ_VECTOR *v)
{
    m[TX] = v->x*m[XX] + v->y*m[XY] + v->z*m[XZ];
    m[TY] = v->x*m[YX] + v->y*m[YY] + v->z*m[YZ];
    m[TZ] = v->x*m[ZX] + v->y*m[ZY] + v->z*m[ZZ];
    m[WW] = 1.0;
}

void LQ_SetMatrixPostTrans(LQ_MATRIX4 m, LQ_VECTOR *v)
{
    m[TX] += v->x;
    m[TY] += v->y;
    m[TZ] += v->z;
    m[WW] = 1.0;
}

void LQ_SetMatrixAxis(LQ_MATRIX4 m, LQ_VECTOR *u, LQ_VECTOR *v, LQ_VECTOR *n)
{
    m[XX]=u->x; m[XY]=u->y; m[XZ]=u->z; m[WX]=0;
    m[YX]=v->x; m[YY]=v->y; m[YZ]=v->z; m[WY]=0;
    m[ZX]=n->x; m[ZY]=n->y; m[ZZ]=n->z; m[WZ]=0;
    m[TX]=0.0;  m[TY]=0.0;  m[TZ]=0.0;  m[WW]=1.0;
}

void LQ_MatrixXYZ(LQ_MATRIX4 m, float xan, float yan, float zan)
{
    float       cx, cy, cz, sx, sy, sz;

    xan = xan * PI / 180.0;
    yan = yan * PI / 180.0;
    zan = zan * PI / 180.0;

    cx=fcos(xan); cy=fcos(yan); cz=fcos(zan);
    sx=fsin(xan); sy=fsin(yan); sz=fsin(zan);

//       cy*cz              cy*sz          -sy 
// sx*sy*cz - cx*sz   sx*sy*sz + cx*cz    sx*cy
// cx*sy*cz + sx*sz   cx*sy*sz - sx*cz    cx*cy

    LQ_MatrixIdent(m);
    m[XX] = cy*cz;
    m[YX] = cy*sz;
    m[ZX] = -sy;

    m[XY] = sx*sy*cz - cx*sz;
    m[YY] = sx*sy*sz + cx*cz;
    m[ZY] = sx*cy;

    m[XZ] = cx*sy*cz + sx*sz;
    m[YZ] = cx*sy*sz - sx*cz;
    m[ZZ] = cx*cy;
}

void LQ_MatrixXRot(LQ_MATRIX4 m, float a)
{
    float   t, ct, st;

    LQ_MatrixIdent(m);

    t = DEG2RAD(a);
    ct = fcos(t);
    st = fsin(t);

    m[YY] = ct; m[YZ] =-st;
    m[ZY] = st; m[ZZ] = ct;
}


void LQ_MatrixYRot(LQ_MATRIX4 m, float a)
{
    float   t, ct, st;

    LQ_MatrixIdent(m);

    t = DEG2RAD(a);
    ct = fcos(t);
    st = fsin(t);

    m[XX] = ct; m[XZ] = st;
    m[ZX] =-st; m[ZZ] = ct;
}

void LQ_MatrixZRot(LQ_MATRIX4 m, float a)
{
    float   t, ct, st;

    LQ_MatrixIdent(m);

    t = DEG2RAD(a);
    ct = fcos(t);
    st = fsin(t);

    m[XX] = ct; m[XY] =-st;
    m[YX] = st; m[YY] = ct;
}


void LQ_CopyVector(LQ_VECTOR *a, LQ_VECTOR *b)
{
    a->x = b->x;
    a->y = b->y;
    a->z = b->z;
}

void LQ_CopyVectorN(LQ_VECTOR *a, LQ_VECTOR *b)
{
    a->x = -b->x;
    a->y = -b->y;
    a->z = -b->z;
}

void LQ_SubVector(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out)
{
    out->x = a->x - b->x;
    out->y = a->y - b->y;
    out->z = a->z - b->z;
}

void LQ_AddVector(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out)
{
    out->x = a->x + b->x;
    out->y = a->y + b->y;
    out->z = a->z + b->z;
}

float LQ_VectorLength(LQ_VECTOR *a)
{
    return(fsqrt(a->x*a->x + a->y*a->y + a->z*a->z));
}

float LQ_VectorLengthSq(LQ_VECTOR *a)
{
    return(a->x*a->x + a->y*a->y + a->z*a->z);
}

float LQ_VectorLengthFast(LQ_VECTOR *a)
{
    return(fastsqrt(a->x*a->x + a->y*a->y + a->z*a->z));
}

void LQ_NormaliseVector(LQ_VECTOR *a)
{
    float   length, ool;

    length = LQ_VectorLength(a);

    if(length!=0.0) {
        ool = 1.0/length;
        a->x*=ool;
        a->y*=ool;
        a->z*=ool;
    }
}

float LQ_NormaliseVectorFast(LQ_VECTOR *a)
{
    float   length, ool;

    length = a->x*a->x + a->y*a->y + a->z*a->z;
    if(length!=0.0) {
        ool = fastoosqrt(length);
        a->x*=ool;
        a->y*=ool;
        a->z*=ool;
    }
    return ool;
}

void LQ_SetVector(LQ_VECTOR *v, float x, float y, float z)
{
    v->x = x;
    v->y = y;
    v->z = z;
}

void LQ_CrossProduct(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out)
{
    out->x = a->y*b->z - a->z*b->y;
    out->y = a->z*b->x - a->x*b->z;
    out->z = a->x*b->y - a->y*b->x;
}



float LQ_DotProduct(LQ_VECTOR *v1, LQ_VECTOR *v2)
{
    return(v1->x*v2->x + v1->y*v2->y + v1->z*v2->z);
}

void LQ_TransformVectorI(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o)
{
    o->x = v->x*m[XX] + v->y*m[YX] + v->z*m[ZX];
    o->y = v->x*m[XY] + v->y*m[YY] + v->z*m[ZY];
    o->z = v->x*m[XZ] + v->y*m[YZ] + v->z*m[ZZ];
}

void LQ_TransformVectorIT(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o)
{
    float   x, y, z;

    x = v->x - m[TX];
    y = v->y - m[TY];
    z = v->z - m[TZ];

    o->x = x*m[XX] + y*m[YX] + z*m[ZX];
    o->y = x*m[XY] + y*m[YY] + z*m[ZY];
    o->z = x*m[XZ] + y*m[YZ] + z*m[ZZ];
}

void LQ_TransformVector(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o)
{
    o->x = v->x*m[XX] + v->y*m[XY] + v->z*m[XZ];
    o->y = v->x*m[YX] + v->y*m[YY] + v->z*m[YZ];
    o->z = v->x*m[ZX] + v->y*m[ZY] + v->z*m[ZZ];
}

void LQ_TransformVectorT(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o)
{
    o->x = v->x*m[XX] + v->y*m[XY] + v->z*m[XZ] + m[TX];
    o->y = v->x*m[YX] + v->y*m[YY] + v->z*m[YZ] + m[TY];
    o->z = v->x*m[ZX] + v->y*m[ZY] + v->z*m[ZZ] + m[TZ];
}


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Quaternions                                                            //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

void LQ_AxisAngleToQuat(float x, float y, float z, float t, LQ_QUAT *q)
{
    float   a;
    float   s;

    a = t / 2.0;
    s = sin(a);
    q->w = cos(a);
    q->x = s * x;
    q->y = s * y;
    q->z = s * z;
}

void LQ_QuatMul(LQ_QUAT *a, LQ_QUAT *b, LQ_QUAT *o)
{
    o->w = a->w*b->w - a->x*b->x - a->y*b->y - a->z*b->z;
    o->x = a->w*b->x + a->x*b->w + a->y*b->z - a->z*b->y;
    o->y = a->w*b->y + a->y*b->w + a->z*b->x - a->x*b->z;
    o->z = a->w*b->z + a->z*b->w + a->x*b->y - a->y*b->x;
}

#define TOLERANCE 0.0001
#define HALF_PI 1.5707963267

void LQ_QuatSlerp(LQ_QUAT *q1, LQ_QUAT *q2, float t, LQ_QUAT *o)
{
    float   cosa, sina, a;
    float   k0, k1;


    // get cosine of angle between quaternions:
    cosa = q1->x * q2->x + 
           q1->y * q2->y + 
           q1->z * q2->z + 
           q1->w * q2->w; 

    // special cases:

    // make sure q1 and q2 are not opposite to each other (within some tolerance)
    if((1.0 + cosa) > TOLERANCE) {

        // check if angle between q1 and q2 is not too small
        if((1.0 - cosa) > TOLERANCE) {
            // slerp:
            a = acos(cosa);
            sina = sin(a);
            k0 = sin( (1.0-t)*a ) / sina;
            k1 = sin( t*a ) / sina;
		} else {
            // lerp:
            k0 = 1.0 - t;
            k1 = t;
		}
        // interpolated quat:
        o->x = k0 * q1->x + k1 * q2->x;
        o->y = k0 * q1->y + k1 * q2->y;
        o->z = k0 * q1->z + k1 * q2->z;
        o->w = k0 * q1->w + k1 * q2->w;

	}
    else {
        o->x = -q2->y;
        o->y = q2->x;
        o->z = -q2->w;
        o->w = q2->z;
        k0 = sin((1.0 - t) * (float)HALF_PI);
        k1 = sin(t * (float)HALF_PI);
        o->x = k0 * q1->x + k1 * o->x;
        o->y = k0 * q1->y + k1 * o->y;
        o->z = k0 * q1->z + k1 * o->z;
        o->w = k0 * q1->w + k1 * o->w;
    }

}


void LQ_QuatSlerp2(LQ_QUAT *a, LQ_QUAT *b, float t, LQ_QUAT *o)
{
    float   k1, k2;
    float   angle;
    float   sina, cosa;
    int     flip;

    cosa = a->w*b->w + a->x*b->x + a->y*b->y + a->z*b->z;

    if(cosa < 0.0) {
        cosa = -cosa;
        flip = -1;
    }
    else flip = 1;


    if ((1.0 - cosa) < EPSILON) {
        k1 = 1.0 - t;
        k2 = t;
    } else {
        angle = acos(cosa);
        sina = sin(angle);
        k1 = sin( (1-t)*angle ) / sina;
        k2 = sin( angle*t ) / sina;
    }

    k2 *= flip;
    o->x = k1*a->x + k2*b->x;
    o->y = k1*a->y + k2*b->y;
    o->z = k1*a->z + k2*b->z;
    o->w = k1*a->w + k2*b->w;
}

void LQ_QuatToMatrix(LQ_QUAT *q, LQ_MATRIX4 m)
{
/*

      ( 1-yy-zz , xy+wz   , xz-wy   )
  T = ( xy-wz   , 1-xx-zz , yz+wx   )
      ( xz+wy   , yz-wx   , 1-xx-yy )
*/
    float   x2, y2, z2, wx, wy, wz,
            xx, xy, xz, yy, yz, zz;

    x2 = q->x + q->x; y2 = q->y + q->y; z2 = q->z + q->z;
    wx = q->w * x2;   wy = q->w * y2;   wz = q->w * z2;
    xx = q->x * x2;   xy = q->x * y2;   xz = q->x * z2;
    yy = q->y * y2;   yz = q->y * z2;   zz = q->z * z2;

    m[XX] = 1.0 - (yy + zz);
    m[YX] = xy + wz;
    m[ZX] = xz - wy;

    m[XY] = xy - wz;
    m[YY] = 1.0 - (xx + zz);
    m[ZY] = yz + wx;

    m[XZ] = xz + wy;
    m[YZ] = yz - wx;
    m[ZZ] = 1.0 - (xx + yy);

    m[TX] = 0.0;
    m[TY] = 0.0;
    m[TZ] = 0.0;
    m[WX] = 0.0;
    m[WY] = 0.0;
    m[WZ] = 0.0;
    m[WW] = 1.0;
}
