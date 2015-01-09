//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// inline FPU general maths functions                                       //
//                                                                          //
// some from pascal, some from me. and below are some notes to help ppl     //
// understand how things came to be from me also ;)                         //
// frenzy                                                                   //
//////////////////////////////////////////////////////////////////////////////
// notes:                                                                   //
//                                                                          //
//   The log and exponential functions are based on the logarithm laws:     //
//                                                                          //
//   LOG X  =  LOG X     (change of base formula)                           //
//      b         c                                                         //
//            -------                                                       //
//             LOG b                                                        //
//                c                                                         //
//                                                                          //
//                 Y                                                        //
//   Y=LOG X  =>  b =X                                                      //
//        b                                                                 //
//                                                                          //
//      b                                                                   //
//  [ a]    (a*b)                                                           //
//  [Y ]== Y                                                                //
//                                                                          //
//                         X                                                //
//   example: working out e                                                 //
//               a                                                          //
//   a=LOG e => 2  = e                                                      //
//        2                 X             b                                 //
//                X    LOG e          [ a]     (a*b)   X    XLOG e          //
//   therefore:  e  = 2   2   , since [Y ] == Y       e  = 2    2           //
//                                                                          //
//                                                                          //
////////////////////////////////////////////////////////////////////////////// 
#ifndef __FMATHS_H
#define __FMATHS_H

#define M_PI        3.14592654
#define PI          3.14592654
#define DEG2RAD(a)  ((a*M_PI)/180.0)
#define RAD2DEG(a)  ((a*180.0)/M_PI)

#define LOW_PRECISION   0
#define MED_PRECISION   1
#define HIGH_PRECISION  2

void  finit(int);               // initalise FPU with a set precision
                                // 0 = (fast)24bits, 1=(med)53bits, 2=(slow)64bits
float fsin(float);              // sine
float fcos(float);              // cosine
float fatan(float,float);       // arctangent
float flog2(float);             // log to base 2
float flog(float);              // log to base 10
float fln(float);               // natural log (ln)
float flogbX(float,float);      // log to base b of X
float fex(float);               // e^x
float fexp(float);              // 10^x
float fexp2(float);             // 2^x
float fpow(float,float);        // x^y
float fsqr(float);              // x*x
float fsqrt(float);             // square root
float ffabs(float);              // absolute value
float fprem(float,float);       // partial remainder 1.123,1.0 = 0.123
float fint(float);              // returns integer part
float ffrac(float);             // returns fractional part
void  frndint(int *dest,float); // fast round to integer
float fmax(float,float);        // returns maximum of two numbers
float fmin(float,float);        // returns minimum of two numbers

#pragma aux finit parm [ebx] modify [eax] = \
    "push 0" \
    "finit" \
    "fstcw word ptr [esp]" \
    "mov eax,[esp]" \
    "and ah,0FCh" \
    "or ah,bl" \
    "mov [esp],eax" \
    "fldcw word ptr [esp]" \
    "add esp,4";

#pragma aux fsin parm [8087] value [8087] modify [8087] = \
    "fsin";

#pragma aux fcos parm [8087] value [8087] modify [8087] = \
    "fcos";

#pragma aux fatan parm [8087] [8087] value [8087] modify [8087] = \
    "fpatan";

#pragma aux flog2 parm [8087] value [8087] modify [8087] = \
    "fld1" \
    "fxch" \
    "fyl2x";

#pragma aux flog parm [8087] value [8087] modify [8087] = \
    "fldlg2" \
    "fxch" \
    "fyl2x";
    
#pragma aux fln parm [8087] value [8087] modify [8087] = \
    "fldln2" \
    "fxch" \
    "fyl2x";

#pragma aux flogbX parm [8087] [8087] value [8087] modify [8087] = \
    "fld1" \
    "fxch" \
    "fxch st(2)" \
    "fyl2x" \
    "fxch" \
    "fld1" \
    "fxch" \
    "fyl2x" \
    "fdiv";

#pragma aux fex parm [8087] value [8087] modify [8087] = \
    "fldl2e" \
    "fmulp st(1), st" \
    "fld1" \
    "fld st(1)" \
    "fprem" \
    "f2xm1" \
    "faddp st(1), st" \
    "fscale" \
    "fxch" \
    "fstp st";

#pragma aux fexp parm [8087] value [8087] modify [8087] = \
    "fldl2t" \
    "fmulp st(1), st" \
    "fld1" \
    "fld st(1)" \
    "fprem" \
    "f2xm1" \
    "faddp st(1), st" \
    "fscale" \
    "fxch" \
    "fstp st";

#pragma aux fexp2 parm [8087] value [8087] modify [8087] = \
    "fld1" \
    "fld st(1)" \
    "fprem" \
    "f2xm1" \
    "faddp st(1), st" \
    "fscale" \
    "fxch" \
    "fstp st";

#pragma aux fpow parm [8087] [8087] value [8087] modify [8087] = \
    "fyl2x" \
    "fld1" \
    "fld st(1)" \
    "fprem" \
    "f2xm1" \
    "faddp st(1), st" \
    "fscale" \
    "fxch" \
    "fstp st";

#pragma aux fsqr parm [8087] value [8087] modify [8087] = \
    "fmul st,st";

#pragma aux fsqrt parm [8087] value [8087] modify [8087] = \
    "fsqrt";

#pragma aux ffabs parm [8087] value [8087] modify [8087] = \
    "fabs";

#pragma aux fprem parm [8087] [8087] value [8087] modify [8087] = \
    "fprem" \
    "fxch" \
    "fstp st";

#pragma aux fint parm [8087] value [8087] modify [8087] = \
    "fld st" \
    "fld1" \
    "fxch" \
    "fprem" \
    "fxch" \
    "fstp st" \
    "fsubp st(1), st";

#pragma aux ffrac parm [8087] value [8087] modify [8087] = \
    "fld1" \
    "fxch" \
    "fprem" \
    "fxch" \
    "fstp st";

#pragma aux frndint parm nomemory [eax] [8087] modify exact [8087] = \
    "fistp dword [eax]";

#pragma aux fmax parm [8087] [8087] value [8087] modify [8087 eax] = \
    "fcom"\
    "fnstsw ax"\
    "sahf"\
    "jb no_swap"\
    "fxch"\
"no_swap:"\
    "fstp st";

#pragma aux fmin parm [8087] [8087] value [8087] modify [8087 eax] = \
    "fcom"\
    "fnstsw ax"\
    "sahf"\
    "jnb no_swap"\
    "fxch"\
"no_swap:"\
    "fstp st";


#endif
