///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// 
//      initial version:
//
////////////
#ifndef __LIQUID3D_H__
#define __LIQUID3D_H__

#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include "\libs\h\fmaths.h"
#include "\libs\h\vga.h"

////////////////////////////////////////////////////////////////////////////
// typedefs                                                               //
////////////////////////////////////////////////////////////////////////////
typedef unsigned int    udword;
typedef int             dword;
typedef unsigned short  uword;
typedef short           word;
typedef unsigned char   ubyte;
typedef char            byte;

////////////////////////////////////////////////////////////////////////////
// macros                                                                 //
////////////////////////////////////////////////////////////////////////////
#define LQ_ISFLAG(a,b)      (a&b)
#define LQ_SETFLAG(a,b)     (a|=b)
#define LQ_CLEARFLAG(a,b)   (a&=~b)

#define MIN(a,b)            (a<b ? a : b)
#define MAX(a,b)            (a>b ? a : b)
#define SQR(a)              (a*a)

#define LQ_CLAMP(a,b,c)     (a<b ? 0.0 : ((a>c) ? 1.0 : a))

#define EPSILON             1.0e-6



////////////////////////////////////////////////////////////////////////////
// object types                                                           //
////////////////////////////////////////////////////////////////////////////
typedef enum {
    LQ_CAMERA_OBJECT        = 0,
    LQ_TRIMESH_OBJECT       = 1,
    LQ_LIGHT_OBJECT         = 2
}   LQ_OBJECT;


////////////////////////////////////////////////////////////////////////////
// render types                                                           //
////////////////////////////////////////////////////////////////////////////
typedef enum {
    LQ_USE_OBJ_TYPE         = 0,
    LQ_WIREFRAME            = 1,
    LQ_TEXTURE_MAP          = 2,
    LQ_FLAT                 = 3
}   LQ_RENDER_TYPE;

////////////////////////////////////////////////////////////////////////////
// shader types                                                           //
////////////////////////////////////////////////////////////////////////////
typedef enum {
    LQ_NO_SHADING           = 0,
    LQ_LAMBERT              = 1,
    LQ_GOURAUD              = 2,
    LQ_ENVIRONMENT          = 3
}   LQ_SHADER_TYPE;


////////////////////////////////////////////////////////////////////////////
// general defines                                                        //
////////////////////////////////////////////////////////////////////////////
#define LQ_CLIP_STORAGE     20
#define LQ_SORT_SLOTS       4096
#define LQ_SORT_SCALE       0.5

////////////////////////////////////////////////////////////////////////////
// depth sorting stratergy                                                //
////////////////////////////////////////////////////////////////////////////
typedef enum {
    LQ_ZSORT_MIN            = 0,
    LQ_ZSORT_MAX            = 1,
    LQ_ZSORT_AVG            = 2
}   LQ_SORT_KEY;

////////////////////////////////////////////////////////////////////////////
// math types                                                             //
////////////////////////////////////////////////////////////////////////////
#define XX  0                   
#define XY  1
#define XZ  2
#define TX  3
#define YX  4
#define YY  5
#define YZ  6
#define TY  7
#define ZX  8
#define ZY  9
#define ZZ  10
#define TZ  11
#define WX  12
#define WY  13
#define WZ  14
#define WW  15

typedef struct {
    float   x, y, z, w;
}   LQ_VECTOR;

typedef struct {
    float   x, y, z, w;
}   LQ_QUAT;

typedef float LQ_MATRIX4[16];  

typedef struct {
    LQ_VECTOR   normal;
    float       distance;
}   LQ_PLANE;

typedef struct {
    LQ_VECTOR   v[8];
    float       minx, maxx;
    float       miny, maxy;
    float       minz, maxz;
}   LQ_BBOX;

////////////////////////////////////////////////////////////////////////////
// misc types                                                             //
////////////////////////////////////////////////////////////////////////////
typedef struct {
    float   r, g, b;
}   LQ_COLOUR;

////////////////////////////////////////////////////////////////////////////
// camera object                                                          //
////////////////////////////////////////////////////////////////////////////

typedef struct tLQ_CAMERA {
    udword              object_type;           
    struct tLQ_CAMERA   *next, *prev;    
    char                *name;                 

    LQ_VECTOR           position;
    LQ_VECTOR           target;
    float               roll;
    float               focus;
    float               fov;
    float               ootfov;
}   LQ_CAMERA;



////////////////////////////////////////////////////////////////////////////
// light object                                                           //
////////////////////////////////////////////////////////////////////////////

typedef enum {
    LQ_LIGHT_OMNI   = 0,
    LQ_LIGHT_SPOT   = 1
}   LQ_LIGHT_TYPE;

typedef enum {
    LQ_LIGHT_HIDDEN = 0,
    LQ_LIGHT_VISABLE = 1
}   LQ_LIGHT_FLAGS;

typedef struct tLQ_LIGHT {
    udword              object_type;
    struct tLQ_LIGHT    *next, *prev;
    char                *name;

    LQ_LIGHT_TYPE       type;
    LQ_LIGHT_FLAGS      flags;

    LQ_VECTOR           position;
    LQ_VECTOR           target;

    LQ_VECTOR           light_vec;  // object space vectors:
    LQ_VECTOR           light_pos;
    LQ_VECTOR           light_tgt;

    float               hotspot;
    float               falloff;
    float               range_start;
    float               range_end;
    LQ_COLOUR           colour;
}   LQ_LIGHT;


////////////////////////////////////////////////////////////////////////////
// trimesh object structures                                              //
////////////////////////////////////////////////////////////////////////////

typedef enum {              // vertex flags
    LQ_VTX_CLIP             = 1,
    LQ_VTX_CLIP_RIGHT       = 2,
    LQ_VTX_CLIP_LEFT        = 4,
    LQ_VTX_CLIP_TOP         = 8,
    LQ_VTX_CLIP_BOTTOM      = 16,
    LQ_VTX_XFORM            = 32,
    LQ_VTX_PROJECT          = 64,
    LQ_VTX_LIGHT            = 128
}   LQ_VTX_FLAG;


typedef enum {              // face flags
    LQ_FACE_CLIP            = 1,
    LQ_FACE_CLIP_RIGHT      = 2,
    LQ_FACE_CLIP_LEFT       = 4,
    LQ_FACE_CLIP_TOP        = 8,
    LQ_FACE_CLIP_BOTTOM     = 16,
    LQ_FACE_VISABLE         = 32,
}   LQ_FACE_FLAG;


typedef enum {              // trimesh flags
    LQ_TRIMESH_VISABLE      = 1,
    LQ_TRIMESH_CULL         = 2,
}   LQ_TRIMESH_FLAG;


typedef struct {            // vertex
    float   x, y, z;
}   LQ_VERTEX;

typedef struct {            // texture vertex
    float   u, v;
}   LQ_UVCOORDS;

typedef struct {
    float               intensity;
    LQ_COLOUR           face_colour;
    LQ_COLOUR           v1, v2, v3;
}   LQ_TRIFACE_DATA;

typedef struct tLQ_TRIFACE {
    uint                v1, v2, v3;     // index into vertex array
    uint                normal;         // index into normal array

    struct tLQ_TRIMESH  *obj;           // ptr to object face belongs too
    LQ_FACE_FLAG        flags;          // flags

    LQ_RENDER_TYPE      rtype;          // render type
    LQ_SHADER_TYPE      stype;

    struct tLQ_TRIFACE  *next;

    LQ_TRIFACE_DATA     *data;          // extra info for face..

    int col;
}   LQ_TRIFACE;

typedef struct {
    LQ_VERTEX           v;              // clipped vertex
    LQ_UVCOORDS         uv;             // clipped uv coordinate
}   LQ_TRIFACE_CLIP;

typedef struct tLQ_TRIMESH {
    udword              object_type;

    struct tLQ_TRIMESH  *next, *prev;

    char                *name;          // name of object

    word                obj_id;         // numeric id of object
    word                father_id;      // numeric id of father object

    uword               num_vertices;   // number of vertices
    uword               num_faces;      // number of faces
    uword               num_vis;        // number of visable faces
    LQ_TRIMESH_FLAG     flags;          // flags

    LQ_VERTEX           *vertex;        // vertex array
    LQ_VERTEX           *vertexR;       // transformed vertex array
    LQ_VERTEX           *vertexS;       // screen space vertex array
    LQ_COLOUR           *vertexL;       // vertex lighting


    LQ_UVCOORDS         *uv;            // uv coordinates array
    

    LQ_VTX_FLAG         *vertexF;       // vertex flag array
    LQ_VECTOR           *normalF;       // normal array
    LQ_VECTOR           *normalV;       // vertex normal array
    LQ_TRIFACE          *face;          // face array
    LQ_TRIFACE          **vislist;      // local vis list

    LQ_MATRIX4          mat;            // object tranform matrix
    LQ_VECTOR           trans;          // translation vector
    LQ_VECTOR           pivot;          // pivot point


    LQ_BBOX             bbox;           // bounding box

    LQ_RENDER_TYPE      rtype;          // global rendering type
    LQ_SHADER_TYPE      stype;

}   LQ_TRIMESH;



/////////////////////////////////////////////////////////////////////////////
// particle structures                                                     //
/////////////////////////////////////////////////////////////////////////////
typedef struct tLQ_PARTICLE {
    LQ_VECTOR   position;           
    LQ_VECTOR   velocity;
    LQ_VECTOR   acceleration;
    float       mass;
    float       localtime;
}   LQ_PARTICLE;

typedef struct tLQ_PARTICLE_SYSTEM {
    // total number of particles allowed in this system
    int         num_particles;

    // position to emit particles from
    LQ_VECTOR   emit_position;

    // max number of particles emited at the same time
    int         num_emit_particles; 

    // emiter function for this system
    void        (*emiter)(LQ_PARTICLE *p, float x, float y, float z);

    // render function for this system
    void        (*render)(LQ_PARTICLE *p);

    
    float       gravity;
    float       maxlifetime;
    float       oldtime;
    float       globaltime;

    // list of particles belonging to this system
    LQ_PARTICLE *plist;

}   LQ_PARTICLE_SYSTEM;


/////////////////////////////////////////////////////////////////////////////
// rendering code                                                          //
/////////////////////////////////////////////////////////////////////////////

typedef struct {
    float   x, y, ooz;
    float   u, v;
}   LQ_TRIPOINT;

typedef struct {
    float   x, dx;
    float   ooz, dooz;
}   LQ_EDGE;


extern ubyte    *active_surface;
extern float    *zbuffer;
extern int      LQ_frame;




/////////////////////////////////////////////////////////////////////////////
// scene structure                                                         //
/////////////////////////////////////////////////////////////////////////////

typedef enum {
    LQ_SCENE_ZBUFFER    = 1,
    LQ_SCENE_FRONTBACK  = 2
}   LQ_SCENE_FLAG;


typedef struct {
    udword      num_vertices;
    udword      num_faces;
    udword      num_vis;

    udword      num_cameras;
    udword      num_trimeshs;
    udword      num_lights;

    // tri-meshs in scene:
    LQ_TRIMESH  *trimesh_list;

    // particle systems in scene:
    LQ_PARTICLE_SYSTEM  *psystem_list;

    // cameras in scene:
    LQ_CAMERA   *camera_list;

    // lights in scene:
    LQ_LIGHT    *light_list;


    LQ_COLOUR   ambient;            // ambient light in scene

    LQ_TRIFACE  **vislist;


    float       *zbuffer;

    ubyte       *stencil_buffer;

    LQ_SCENE_FLAG   flags;

    int         xw, yw;
    float       window_x, window_y;
    float       znear, zfar;
    float       aratio;

}   LQ_SCENE;

extern LQ_SCENE *active_scene;


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// keyframe section:                                                      //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

typedef union {
    LQ_VECTOR   pos;
    LQ_QUAT     rot;
    float       theta;
}   LQ_KDATA;

typedef struct {
    float       tension;
    float       continuity;
    float       bias;
    float       easeto;
    float       easefrom;
}   LQ_TCB;

typedef enum {
    LQ_POSITION_TRACK       = 0,
    LQ_TARGET_TRACK         = 1,
    LQ_ROTATION_TRACK       = 2,
    LQ_SCALE_TRACK          = 3,
    LQ_ROLL_TRACK           = 4,
    LQ_FOV_TRACK            = 5
}   LQ_TRACKTYPE;


typedef struct tLQ_KEY {
    uint            key_num;
    LQ_TCB          tcb;
    LQ_KDATA        val;
    LQ_VECTOR       ds, dd;
    struct tLQ_KEY  *next, *prev;
}   LQ_KEY;

typedef struct tLQ_TRACK {
    uword               flag;
    LQ_TRACKTYPE        type;

    LQ_OBJECT           otype;
    void                *obj;

    LQ_KEY              *keys;
    uint                num_keys;
    struct tLQ_TRACK    *next, *prev;
}   LQ_TRACK;

typedef struct {
    uint        frames;
    uint        start;
    uint        end;
    uint        num_tracks;
    LQ_TRACK    *tracks;
}   LQ_KEYFRAMER;
    

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// function prototypes                                                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////




//
// matvec.cpp
//
void LQ_MatrixIdent(LQ_MATRIX4 m);
void LQ_MatrixMul(LQ_MATRIX4 a, LQ_MATRIX4 b, LQ_MATRIX4 o);
void LQ_SetMatrixAxis(LQ_MATRIX4 m, LQ_VECTOR *u, LQ_VECTOR *v, LQ_VECTOR *n);
void LQ_MatrixInverse3(LQ_MATRIX4 m, LQ_MATRIX4 o);
void LQ_MatrixMul3(LQ_MATRIX4 a, LQ_MATRIX4 b, LQ_MATRIX4 o);
void LQ_MatrixTranspose(LQ_MATRIX4 m, LQ_MATRIX4 o);
void LQ_MatrixScale(LQ_MATRIX4 m, float sx, float sy, float sz);
void LQ_MatrixXYZ(LQ_MATRIX4 m, float xan, float yan, float zan);
void LQ_MatrixCopy(LQ_MATRIX4 in, LQ_MATRIX4 out);
void LQ_MatrixXRot(LQ_MATRIX4 m, float a);
void LQ_MatrixYRot(LQ_MATRIX4 m, float a);
void LQ_MatrixZRot(LQ_MATRIX4 m, float a);
void LQ_CopyVector(LQ_VECTOR *a, LQ_VECTOR *b);
void LQ_CopyVectorN(LQ_VECTOR *a, LQ_VECTOR *b);
void LQ_SubVector(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out);
void LQ_AddVector(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out);
float LQ_VectorLengthFast(LQ_VECTOR *a);
float LQ_VectorLength(LQ_VECTOR *a);
float LQ_VectorLengthSq(LQ_VECTOR *a);
void LQ_NormaliseVector(LQ_VECTOR *a);
float LQ_NormaliseVectorFast(LQ_VECTOR *a);
void LQ_SetVector(LQ_VECTOR *v, float x, float y, float z);
void LQ_CrossProduct(LQ_VECTOR *a, LQ_VECTOR *b, LQ_VECTOR *out);
float LQ_DotProduct(LQ_VECTOR *v1, LQ_VECTOR *v2);
void LQ_TransformVectorI(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o);
void LQ_TransformVector(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o);
void LQ_TransformVectorT(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o);
void LQ_TransformVectorIT(LQ_MATRIX4 m, LQ_VECTOR *v, LQ_VECTOR *o);
void LQ_AxisAngleToQuat(float x, float y, float z, float t, LQ_QUAT *q);
void LQ_QuatMul(LQ_QUAT *a, LQ_QUAT *b, LQ_QUAT *o);
void LQ_QuatSlerp(LQ_QUAT *a, LQ_QUAT *b, float t, LQ_QUAT *o);
void LQ_QuatToMatrix(LQ_QUAT *q, LQ_MATRIX4 m);
void LQ_SetMatrixPreTrans(LQ_MATRIX4 m, LQ_VECTOR *v);
void LQ_SetMatrixPostTrans(LQ_MATRIX4 m, LQ_VECTOR *v);
void LQ_MatrixTranslate(LQ_MATRIX4 m, float x, float y, float z);


//
// camera.cpp
//
LQ_CAMERA *LQ_CAMERA_Create(char *name);
void LQ_CAMERA_Setup(LQ_CAMERA *camera, LQ_MATRIX4 cmat);
void LQ_CAMERA_SetFOV(LQ_CAMERA *camera, float fov);
void LQ_CAMERA_SetROLL(LQ_CAMERA *camera, float roll);
void LQ_CAMERA_SetPosition(LQ_CAMERA *camera, LQ_VECTOR *pos);
void LQ_CAMERA_SetTarget(LQ_CAMERA *camera, LQ_VECTOR *tgt);


//
// trimesh.cpp
//
LQ_TRIMESH *LQ_TRIMESH_Create(char *name);
LQ_VERTEX *LQ_TRIMESH_VertexList(LQ_TRIMESH *obj, udword num_vertices);
LQ_UVCOORDS *LQ_TRIMESH_UVList(LQ_TRIMESH *obj, udword n);
LQ_VECTOR *LQ_TRIMESH_VertexNormalList(LQ_TRIMESH *obj, udword num_vertices);
LQ_TRIFACE *LQ_TRIMESH_FaceList(LQ_TRIMESH *obj, udword num_faces);
LQ_VECTOR *LQ_TRIMESH_FaceNormalList(LQ_TRIMESH *obj, udword num_faces);
void LQ_TRIMESH_BoundingBox(LQ_TRIMESH *obj);
void LQ_TRIMESH_FaceNormals(LQ_TRIMESH *obj);
void LQ_TRIMESH_ToObjectSpace(LQ_TRIMESH *obj, LQ_MATRIX4 m);
void LQ_TRIMESH_SetRenderType(LQ_TRIMESH *obj, udword type);

//
// scene.cpp
//
LQ_SCENE *LQ_SCENE_Create(void);
void LQ_SCENE_AddEmptyObject(LQ_SCENE *scene, void *obj);
void *LQ_SCENE_GetObject(LQ_SCENE *scene, char *name);
LQ_OBJECT LQ_SCENE_GetObjectType(void *obj);
void LQ_SCENE_Fix(LQ_SCENE *scene);
void LQ_SCENE_SetWindow(LQ_SCENE *scene, float xw, float yw);
void LQ_SCENE_SetZClip(LQ_SCENE *scene, float znear, float zfar);
void LQ_SCENE_FREE(LQ_SCENE *scene);
void LQ_SCENE_BuildHierarchy(LQ_SCENE *scene);
LQ_TRIMESH *LQ_SCENE_GetObjectFromPosition(LQ_SCENE *scene, word id);


//
// raster.cpp
//
void LQ_POLY_FlatFill(LQ_TRIPOINT *p1, LQ_TRIPOINT *p2, LQ_TRIPOINT *p3, ubyte col);


//
// 3ds.c
//
int LQ_LoadScene3DS(LQ_SCENE *s, LQ_KEYFRAMER *k, char *filename);


//
// render.cpp
//
void LQ_RenderScene(LQ_SCENE *scene, LQ_CAMERA *camera, ubyte *buf, int frame);


//
// clip.cpp
//
extern LQ_TRIFACE_CLIP clip_in[], clip_out[];
LQ_TRIFACE_CLIP *LQ_ClipFace(LQ_TRIFACE *face, int *num_verts);


//
// light.cpp
//
LQ_LIGHT *LQ_LIGHT_Create(char *name);
void LQ_LIGHT_CalcLambertShading(LQ_SCENE *scene, LQ_TRIFACE *face);
void LQ_LIGHT_Process(LQ_SCENE *scene, LQ_TRIMESH *obj);
void LQ_LIGHT_CalcGouraudShading(LQ_SCENE *scene, LQ_TRIMESH *obj);


//
// keyframe.cpp
//
void LQ_InitKeyframer(LQ_KEYFRAMER *kf);
void LQ_CalculateTracksSplineDerives(LQ_TRACK *track);
LQ_TRACK *LQ_AddTrack(LQ_KEYFRAMER *kf, udword type);
LQ_KEY *LQ_AddKey(LQ_TRACK *track);
void LQ_SetFrame(LQ_SCENE *scene, LQ_KEYFRAMER *kf, uint frame);




#endif
