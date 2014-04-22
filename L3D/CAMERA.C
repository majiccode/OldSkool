///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// camera module:
//      initial version:
//
////////////
#include "l3d.h"

LQ_CAMERA *LQ_CAMERA_Create(char *name)
{
    LQ_CAMERA   *cam;

    cam = (LQ_CAMERA *)malloc(sizeof(LQ_CAMERA));
    if(cam) {
        LQ_SetVector(&cam->position, 0, 0, 0);
        LQ_SetVector(&cam->target, 0, 0, 1000);
        LQ_CAMERA_SetFOV(cam, 90.0);
        LQ_CAMERA_SetROLL(cam, 0.0);
        cam->name = (char *)strdup(name);
        cam->next = NULL;
        cam->prev = NULL;
        cam->object_type = LQ_CAMERA_OBJECT;
    }
    return cam;
}

void LQ_CAMERA_Setup(LQ_CAMERA *camera, LQ_MATRIX4 cmat)
{
    LQ_VECTOR   U, V, N, tmp, trans;

    LQ_MatrixIdent(cmat);
    LQ_CopyVectorN(&trans, &camera->position);
    LQ_SubVector(&camera->target, &camera->position, &N);
    LQ_NormaliseVector(&N);
    LQ_SetVector(&V, fsin(camera->roll), fcos(camera->roll), 0.0);
    LQ_CrossProduct(&V, &N, &tmp);
    LQ_CrossProduct(&N, &tmp, &V);
    LQ_NormaliseVector(&V);
    LQ_CrossProduct(&V, &N, &U);
    LQ_SetMatrixAxis(cmat, &U, &V, &N);
    LQ_SetMatrixPreTrans(cmat, &trans);
}

void LQ_CAMERA_SetFOV(LQ_CAMERA *camera, float fov)
{
    float   a = DEG2RAD(fov * 0.5);

    camera->fov = a;
    camera->ootfov = 1.0 / (fsin(a) / fcos(a));    // easier usage
}

void LQ_CAMERA_SetROLL(LQ_CAMERA *camera, float roll)
{
    camera->roll = DEG2RAD(roll);
}

void LQ_CAMERA_SetPosition(LQ_CAMERA *camera, LQ_VECTOR *pos)
{
    camera->position.x = pos->x;
    camera->position.y = pos->y;
    camera->position.z = pos->z;
}

void LQ_CAMERA_SetTarget(LQ_CAMERA *camera, LQ_VECTOR *tgt)
{
    camera->target.x = tgt->x;
    camera->target.y = tgt->y;
    camera->target.z = tgt->z;
}
