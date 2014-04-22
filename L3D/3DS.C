///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// 3DS reader:
//      initial version:
//
////////////
#include "l3d.h"

#define AMBIENT_BLOCK           0
#define CAMERA_POSITION_BLOCK   1
#define CAMERA_TARGET_BLOCK     2
#define TRIMESH_BLOCK           3
#define OMNI_BLOCK              4
#define SPOT_POSITION_BLOCK     5
#define SPOT_TARGET_BLOCK       6

#pragma pack(1);
typedef struct {
    uword    id;
    udword   length;
}   CHUNK;

enum {
    CHUNK_PRIMARY                       = 0x4D4D,

        CHUNK_COLOUR                    = 0x0010,

        CHUNK_OBJMESH                   = 0x3D3D,
            CHUNK_AMBIENT               = 0x2100,

            CHUNK_OBJBLOCK              = 0x4000,
                CHUNK_TRIMESH           = 0x4100,
                    CHUNK_OBJVERTS      = 0x4110,
                    CHUNK_OBJFACES      = 0x4120,
                    CHUNK_UVCOORDS      = 0x4140,
                    CHUNK_OBJMATRIX     = 0x4160,

                CHUNK_LIGHT             = 0x4600,
                    CHUNK_SPOTLIGHT     = 0x4610,

                    CHUNK_LIGHT_RANGESTRT = 0x4659,
                    CHUNK_LIGHT_RANGEEND  = 0x465A,

                CHUNK_CAMERA            = 0x4700,

        CHUNK_KEYFRAMER                 = 0xB000,
            CHUNK_FRAMES                = 0xB008,

            CHUNK_CAMERAPOS             = 0xB003,
            CHUNK_CAMERATGT             = 0xB004,
            CHUNK_OBJECTTRACK           = 0xB002,
            CHUNK_OMNI                  = 0xB005,
            CHUNK_SPOTPOS               = 0xB006,
            CHUNK_SPOTTGT               = 0xB007,

                CHUNK_OBJECTNAME        = 0xB010,
                CHUNK_OBJPIVOT          = 0xB013,
                CHUNK_TRACKPOS          = 0xB020,
                CHUNK_TRACKROT          = 0xB021,
                CHUNK_CAMERAROLL        = 0xB024,

                CHUNK_HIERARCHYPOS      = 0xB030,


};

////////////////////////////////////////////////////////////////////////////
//
// Globals
//
////////////////////////////////////////////////////////////////////////////
    FILE            *fp;
    LQ_SCENE        *scene;
    char            name[80];
    void            *object;
    LQ_OBJECT       obj_type;


    LQ_KEYFRAMER    *keyframer;
    LQ_TRACK        *track;
    LQ_KEY          *key;

    udword          current_block;
    word            obj_id;
    word            num_dummys;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//  Support Functions:                                                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
void CreateNewObject(LQ_OBJECT type)
{

    obj_type = type;
    switch(obj_type) {
        case LQ_TRIMESH_OBJECT:
            object = LQ_TRIMESH_Create(name);
            break;
        case LQ_CAMERA_OBJECT:
            object = LQ_CAMERA_Create(name);
            break;
        case LQ_LIGHT_OBJECT:
            object = LQ_LIGHT_Create(name);
            break;
    }

    LQ_SCENE_AddEmptyObject(scene, object);
}

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//  3DS READER FUNCTIONS:                                                 //
//                                                                        //
////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////
// read colour                                                            //
////////////////////////////////////////////////////////////////////////////
void ReadColour(void)
{
    LQ_OBJECT   type;
    void        *obj;
    float       r, g, b;

    fread(&r, 4, 1, fp);
    fread(&g, 4, 1, fp);
    fread(&b, 4, 1, fp);


    obj = LQ_SCENE_GetObject(scene, name);
    if(obj) {
        type = LQ_SCENE_GetObjectType(obj);

        switch(type) {
            case LQ_LIGHT_OBJECT:
                ((LQ_LIGHT *)obj)->colour.r = r;
                ((LQ_LIGHT *)obj)->colour.g = g;
                ((LQ_LIGHT *)obj)->colour.b = b;
                break;
        }
    } else {
        scene->ambient.r = r;
        scene->ambient.g = g;
        scene->ambient.b = b;
    }
}

////////////////////////////////////////////////////////////////////////////
// read object name                                                       //
////////////////////////////////////////////////////////////////////////////
void ReadObjectName(void)
{
    int     i=0, c;
    
    while((c=fgetc(fp)) != EOF && c != '\0')
        name[i++] = c;

    name[i] = '\0';
}


////////////////////////////////////////////////////////////////////////////
// create a new tri-mesh object                                           //
////////////////////////////////////////////////////////////////////////////
void CreateNewTrimeshObject(void)
{
    LQ_TRIMESH  *obj;

    CreateNewObject(LQ_TRIMESH_OBJECT);

    obj = (LQ_TRIMESH *)object;
    obj->obj_id = -1; //obj_id++;
}


////////////////////////////////////////////////////////////////////////////
// read tri-mesh object vertices                                          //
////////////////////////////////////////////////////////////////////////////
void ReadObjectVertices(void)
{
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;
    uword       num_verts;
    int         i;
    float       v[3];

    fread(&num_verts, sizeof(num_verts), 1, fp);
    obj->num_vertices = num_verts;

    LQ_TRIMESH_VertexList(obj, num_verts);

    for(i=0; i<num_verts; i++) {
        fread(v, 3*4, 1, fp);
        obj->vertex[i].x = v[0];
        obj->vertex[i].y = v[2];
        obj->vertex[i].z = v[1];
    }
}

////////////////////////////////////////////////////////////////////////////
// read tri-mesh object faces                                             //
////////////////////////////////////////////////////////////////////////////
void ReadObjectFaces(void)
{
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;
    uword       num_faces, face[4];
    int i;
    fread(&num_faces, sizeof(num_faces), 1, fp);
    obj->num_faces = num_faces;

    LQ_TRIMESH_FaceList(obj, num_faces);
  i = 1;
    while(num_faces--) {
        fread(face, sizeof(face), 1, fp);
        obj->face[num_faces].v1 = face[0];
        obj->face[num_faces].v2 = face[1];
        obj->face[num_faces].v3 = face[2];
        obj->face[num_faces].obj = obj;
        obj->face[num_faces].flags = 0;
        obj->face[num_faces].col = (i % 255) + 1;
        i++;
    }
}


////////////////////////////////////////////////////////////////////////////
// read tri-mesh texture vertices                                         //
////////////////////////////////////////////////////////////////////////////
void ReadTextureVertices(void)
{
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;
    uword       num_verts;
    float       u, v;
    int         i;

    fread(&num_verts, 2, 1, fp);
    LQ_TRIMESH_UVList(obj, num_verts);
    for(i=0; i<num_verts; i++) {
        fread(&u, 4, 1, fp);
        fread(&v, 4, 1, fp);
        obj->uv[i].u = u;
        obj->uv[i].v = v;
    }
}

////////////////////////////////////////////////////////////////////////////
// read tri-mesh object matrix                                            //
////////////////////////////////////////////////////////////////////////////
void ReadObjectMatrix(void)
{
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;
    float       mat[9], trans[3];
    LQ_MATRIX4  m;

    fread(&mat, sizeof(mat), 1, fp);
    fread(trans, sizeof(trans), 1, fp);

    LQ_MatrixIdent(m);
/*
    m[XX] = mat[0];
    m[XY] = mat[6];
    m[XZ] = mat[3];

    m[YX] = mat[2];
    m[YY] = mat[8];
    m[YZ] = mat[5];

    m[ZX] = mat[1];
    m[ZY] = mat[7];
    m[ZZ] = mat[4];
*/
    m[XX] = mat[0];
    m[XY] = mat[2];
    m[XZ] = mat[1];

    m[YX] = mat[6];
    m[YY] = mat[8];
    m[YZ] = mat[7];

    m[ZX] = mat[3];
    m[ZY] = mat[5];
    m[ZZ] = mat[4];



    //LQ_MatrixCopy(m, obj->mat);

    LQ_MatrixTranspose(m, obj->mat);

    obj->trans.x = trans[0];
    obj->trans.y = trans[2];
    obj->trans.z = trans[1];
    obj->pivot.x = 0.0;
    obj->pivot.y = 0.0;
    obj->pivot.z = 0.0;

//    LQ_SetMatrixPreTrans(obj->mat, &obj->trans);
//    LQ_MatrixIdent(obj->rmat);
/*
    m[XX] = mat[0];
    m[XY] = mat[2];
    m[XZ] = mat[1];

    m[YX] = mat[3];
    m[YY] = mat[5];
    m[YZ] = mat[4];

    m[ZX] = mat[6];       
    m[ZY] = mat[8];       
    m[ZZ] = mat[7];

    LQ_MatrixTranspose(m, obj->mat);

    obj->trans.x = trans[0];
    obj->trans.y = trans[2];
    obj->trans.z = trans[1];
    LQ_SetMatrixTrans(obj->mat, &obj->trans);
    */
}



////////////////////////////////////////////////////////////////////////////
// read light object                                                      //
////////////////////////////////////////////////////////////////////////////
void ReadOmniLight(void)
{
    LQ_LIGHT    *obj;
    float       v[3];

    CreateNewObject(LQ_LIGHT_OBJECT);
    obj = (LQ_LIGHT *)object;

    fread(&v, 3*4, 1, fp);
    obj->position.x = v[0];
    obj->position.y = v[2];
    obj->position.z = v[1];

    obj->type = LQ_LIGHT_OMNI;
}

void ReadSpotLight(void)
{
    LQ_LIGHT    *obj;
    float       v[3];

    obj = (LQ_LIGHT *)object;

    fread(&v, 3*4, 1, fp);
    obj->target.x = v[0];
    obj->target.y = v[2];
    obj->target.z = v[1];

    fread(&obj->hotspot, 4, 1, fp);
    fread(&obj->falloff, 4, 1, fp);

    obj->type = LQ_LIGHT_SPOT;
}

void ReadLightRangeStart(void)
{
    LQ_LIGHT    *obj;

    obj = (LQ_LIGHT *)object;

    fread(&obj->range_start, 4, 1, fp);
}

void ReadLightRangeEnd(void)
{
    LQ_LIGHT    *obj;

    obj = (LQ_LIGHT *)object;

    fread(&obj->range_end, 4, 1, fp);
}

////////////////////////////////////////////////////////////////////////////
// read camera object                                                     //
////////////////////////////////////////////////////////////////////////////
void ReadCamera(void)
{
    LQ_CAMERA   *obj;
    float       v[3];
    float       roll;

    CreateNewObject(LQ_CAMERA_OBJECT);

    obj = (LQ_CAMERA *)object;

    fread(&v, 3*4, 1, fp);
    obj->position.x = v[0];
    obj->position.y = v[2];
    obj->position.z = v[1];

    fread(&v, 3*4, 1, fp);
    obj->target.x = v[0];
    obj->target.y = v[2];
    obj->target.z = v[1];

    fread(&roll, 4, 1, fp);
    obj->roll = DEG2RAD(roll);
    fread(&obj->focus, 4, 1, fp);
    LQ_CAMERA_SetFOV(obj, 2400.0 / obj->focus);
}




/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// KEYFRAMER READER:                                                       //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////



void ReadFrames(void)
{
    udword  start, end;

    fread(&start, 4, 1, fp);
    fread(&end, 4, 1, fp);
    keyframer->start = start;
    keyframer->end = end;
    keyframer->frames = end-start;
}

void SetObjectName(void)
{
    int     i=0, c;
    uword   flag1, flag2;
    word    hierarchy;

    while((c=fgetc(fp)) != EOF && c != '\0')
        name[i++] = c;

    name[i] = '\0';

//    if(!strcmp(name, "$$$DUMMY"))
//        num_dummys++;

    fread(&flag1, 2, 1, fp);
    fread(&flag2, 2, 1, fp);
    fread(&hierarchy, 2, 1, fp);

    object = LQ_SCENE_GetObject(scene, name);
    obj_type = LQ_SCENE_GetObjectType(object);

    if(obj_type == LQ_TRIMESH_OBJECT) {
      //  if(hierarchy != -1)
      //      hierarchy += num_dummys;
        ((LQ_TRIMESH *)object)->father_id = hierarchy;

    }
}

void SetObjectPivotPoint(void)
{
    float       piv[3];
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;

    fread(piv, 3*4, 1, fp);

    if(obj_type == LQ_TRIMESH_OBJECT) {
        obj->pivot.x = piv[0];
        obj->pivot.y = piv[2];
        obj->pivot.z = piv[1];
    }
}

void SetCameraPositionBlock(void)
{
    current_block = CAMERA_POSITION_BLOCK;
}

void SetCameraTargetBlock(void)
{
    current_block = CAMERA_TARGET_BLOCK;
}

void SetTrimeshBlock(void)
{
    current_block = TRIMESH_BLOCK;
}

void SetOmniBlock(void)
{
    current_block = OMNI_BLOCK;
}

void SetSpotPositionBlock(void)
{
    current_block = SPOT_POSITION_BLOCK;
}

void SetSpotTargetBlock(void)
{
    current_block = SPOT_TARGET_BLOCK;
}


void ReadHierarchyPos(void)
{
    LQ_TRIMESH  *obj = (LQ_TRIMESH *)object;
    word        pos;

    fread(&pos, 2, 1, fp);

    if(obj_type == LQ_TRIMESH_OBJECT) {
        obj->obj_id = pos;
    }
}

void ReadTrack(void)
{
    uword   tcb;
    float   t, c, b, et, ef;
    udword  numkeys, keynum;
    ubyte   unknown[8];
    float   x,y,z,angle;
    LQ_QUAT q, qprev;
    int     i, mul;

    mul = 0;

    qprev.w = 1.0;
    qprev.x = 0.0;
    qprev.y = 0.0;
    qprev.z = 0.0;

    track->otype = obj_type;
    track->obj = object;

    fread(&track->flag, 2, 1, fp);
    fread(unknown, 8, 1, fp);
    fread(&numkeys, 4, 1, fp);
    track->num_keys = numkeys;

    for(i=0; i<numkeys; i++) {
        key = LQ_AddKey(track);

        fread(&keynum, 4, 1, fp);
        fread(&tcb, 2, 1, fp);

        t = c = b = et = ef = 0.0;

        if(tcb&1)
            fread(&t, 4, 1, fp);
        if(tcb&2)
            fread(&c, 4, 1, fp);
        if(tcb&4)
            fread(&b, 4, 1, fp);
        if(tcb&8)
            fread(&et, 4, 1, fp);
        if(tcb&16)
            fread(&ef, 4, 1, fp);

        switch(track->type) {
            case LQ_POSITION_TRACK:
            case LQ_TARGET_TRACK:
                fread(&x, 4, 1, fp);
                fread(&y, 4, 1, fp);
                fread(&z, 4, 1, fp);
                key->val.pos.x = x;
                key->val.pos.y = z;
                key->val.pos.z = y;
                break;
            case LQ_ROTATION_TRACK:
                fread(&angle, 4, 1, fp);
                fread(&x, 4, 1, fp);
                fread(&y, 4, 1, fp);
                fread(&z, 4, 1, fp);


                if(mul) {
                    LQ_AxisAngleToQuat(x, z, y, angle, &q);

                    LQ_QuatMul(&q, &qprev, &key->val.rot);

                    qprev = key->val.rot;

                } else {
                    
                    LQ_AxisAngleToQuat(x, z, y, angle, &qprev);

                    key->val.rot = qprev;

                    mul = 1;
                }

                
                break;
        }

        key->tcb.tension = t;
        key->tcb.continuity = c;
        key->tcb.bias = b;
        key->tcb.easefrom = ef;
        key->tcb.easeto = et;
        key->key_num = keynum;
    }
   
    switch(track->type) {
        case LQ_POSITION_TRACK:
        case LQ_TARGET_TRACK:
            LQ_CalculateTracksSplineDerives(track);
            break;
    }
            
}

void ReadTrackPos(void)
{
    switch(current_block) {
        case CAMERA_POSITION_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_POSITION_TRACK);
            break;
        case CAMERA_TARGET_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_TARGET_TRACK);
            break;
        case TRIMESH_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_POSITION_TRACK);
            break;
        case OMNI_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_POSITION_TRACK);
            break;
        case SPOT_POSITION_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_POSITION_TRACK);
            break;
        case SPOT_TARGET_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_TARGET_TRACK);
            break;
    }

    ReadTrack();
}


void ReadTrackRot(void)
{
    switch(current_block) {
        case TRIMESH_BLOCK:
            track = LQ_AddTrack(keyframer, LQ_ROTATION_TRACK);
            break;
    }

    ReadTrack();
}


/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// MAIN:                                                                   //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

struct {
    uword    id;
    void    (*ChunkReader)(void);
}   CHUNKS[] = {
    {CHUNK_PRIMARY,     NULL},

    {CHUNK_COLOUR,      ReadColour},


    {CHUNK_OBJMESH,     NULL},

    {CHUNK_AMBIENT,     NULL},
    
    {CHUNK_OBJBLOCK,    ReadObjectName},
    {CHUNK_TRIMESH,     CreateNewTrimeshObject},
    {CHUNK_OBJVERTS,    ReadObjectVertices},
    {CHUNK_OBJFACES,    ReadObjectFaces},
    {CHUNK_UVCOORDS,    ReadTextureVertices},
    {CHUNK_OBJMATRIX,   ReadObjectMatrix},

    {CHUNK_LIGHT,       ReadOmniLight},
    {CHUNK_SPOTLIGHT,   ReadSpotLight},
    {CHUNK_LIGHT_RANGESTRT, ReadLightRangeStart},
    {CHUNK_LIGHT_RANGEEND,  ReadLightRangeEnd},



    {CHUNK_CAMERA,      ReadCamera},


    {CHUNK_KEYFRAMER,   NULL},
    {CHUNK_FRAMES,      ReadFrames},

    {CHUNK_CAMERAPOS,   SetCameraPositionBlock},
    {CHUNK_CAMERATGT,   SetCameraTargetBlock},
    {CHUNK_OBJECTTRACK, SetTrimeshBlock},
    {CHUNK_OMNI,        SetOmniBlock},
    {CHUNK_SPOTPOS,     SetSpotPositionBlock},
    {CHUNK_SPOTTGT,     SetSpotTargetBlock},

    {CHUNK_OBJECTNAME,  SetObjectName},
    {CHUNK_OBJPIVOT,    SetObjectPivotPoint},

    {CHUNK_TRACKPOS,    ReadTrackPos},
    {CHUNK_TRACKROT,    ReadTrackRot},

    {CHUNK_HIERARCHYPOS, ReadHierarchyPos}
};



int LQ_FindChunk(uword chunk_id)
{
    int     i;

    for(i=0; i<sizeof(CHUNKS) / sizeof(CHUNKS[0]); i++)
        if(CHUNKS[i].id == chunk_id)
            return i;

    return -1;
}

void LQ_ChunkReader(udword size)
{
    CHUNK   chunk;
    udword  currpos;
    int     i;

    while(ftell(fp) < size) {
        currpos = ftell(fp);
        if(!fread(&chunk, sizeof(chunk), 1, fp))
            return;

        i = LQ_FindChunk(chunk.id);

        if(i == -1) {
            fseek(fp, currpos + chunk.length, SEEK_SET);
        } else {
            if(CHUNKS[i].ChunkReader != NULL) {
                CHUNKS[i].ChunkReader();
            }
        }               
    }
}

int LQ_LoadScene3DS(LQ_SCENE *s, LQ_KEYFRAMER *k, char *filename)
{
    udword      size;

    scene       = s;
    keyframer   = k;
    object      = NULL;
    obj_id      = 0;
    num_dummys  = 0;

    LQ_InitKeyframer(keyframer);

    fp=fopen(filename, "rb");
    fseek(fp, 0, SEEK_END);
    size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    LQ_ChunkReader(size);


    fclose(fp);

    LQ_SCENE_Fix(scene);

//    LQ_SCENE_BuildHierarchy(scene);

    return 0;
}

    
