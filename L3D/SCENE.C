///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// scene managment module:
//      initial version:
//
////////////
#include "l3d.h"

LQ_SCENE *LQ_SCENE_Create(void)
{
    LQ_SCENE    *scene;

    scene = (LQ_SCENE *)malloc(sizeof(LQ_SCENE));
    if(scene) {
        scene->num_vertices = 0;
        scene->num_faces    = 0;
        scene->num_vis      = 0;
        scene->num_cameras  = 0;
        scene->num_trimeshs = 0;
        scene->num_lights   = 0;

        scene->camera_list  = NULL;
        scene->trimesh_list = NULL;
        scene->light_list   = NULL;

        scene->znear        = 0.0;

        LQ_SCENE_SetWindow(scene, 320, 200);
        LQ_SCENE_SetZClip(scene, 1.0, 1000.0);

        scene->flags        = 0;
        
    }

    return scene;
}

void LQ_SCENE_AddEmptyObject(LQ_SCENE *scene, void *obj)
{
    udword      type;
    LQ_TRIMESH  *tmesh;
    LQ_CAMERA   *cam;
    LQ_LIGHT    *light;

    type = *((udword *)obj);

    switch(type) {
        case LQ_CAMERA_OBJECT:
            if(!scene->num_cameras)
                scene->camera_list = (LQ_CAMERA *)obj;
            else {
                cam = scene->camera_list;
                while(cam->next)
                    cam = cam->next;
                cam->next = (LQ_CAMERA *)obj;
                cam->next->prev = cam;
            }
            scene->num_cameras++;
            break;

        case LQ_TRIMESH_OBJECT:
            if(!scene->num_trimeshs)
                scene->trimesh_list = (LQ_TRIMESH *)obj;
            else {
                tmesh = scene->trimesh_list;
                while(tmesh->next)
                    tmesh = tmesh->next;
                tmesh->next = (LQ_TRIMESH *)obj;
                tmesh->next->prev = tmesh;
            }
            scene->num_trimeshs++;
            break;

        case LQ_LIGHT_OBJECT:
            if(!scene->num_lights)
                scene->light_list = (LQ_LIGHT *)obj;
            else {
                light = scene->light_list;
                while(light->next)
                    light = light->next;
                light->next = (LQ_LIGHT *)obj;
                light->next->prev = light;
            }
            scene->num_lights++;
            break;

    }
}


void *LQ_SCENE_GetObject(LQ_SCENE *scene, char *name)
{
    LQ_TRIMESH  *tmesh;
    LQ_CAMERA   *cam;
    LQ_LIGHT    *light;

    tmesh = scene->trimesh_list;
    while(tmesh) {
        if(!strcmp(name, tmesh->name))
            return (void*)tmesh;
        tmesh = tmesh->next;
    }

    cam = scene->camera_list;
    while(cam) {
        if(!strcmp(name, cam->name))
            return (void*)cam;
        cam = cam->next;
    }

    light = scene->light_list;
    while(light) {
        if(!strcmp(name, light->name))
            return (void*)light;
        light = light->next;
    }

    return NULL;
}

LQ_OBJECT LQ_SCENE_GetObjectType(void *obj)
{
    return (LQ_OBJECT)(*((udword *)obj));
}


void LQ_SCENE_Fix(LQ_SCENE *scene)
{
    LQ_TRIMESH  *tmesh = scene->trimesh_list;
    int         i;

    scene->num_vertices = 0;
    scene->num_faces = 0;

    while(tmesh) {
        scene->num_vertices+=tmesh->num_vertices;
        scene->num_faces+=tmesh->num_faces;
        LQ_TRIMESH_ToObjectSpace(tmesh, tmesh->mat);
        LQ_TRIMESH_BoundingBox(tmesh);
        LQ_TRIMESH_FaceNormalList(tmesh, tmesh->num_faces);
        LQ_TRIMESH_FaceNormals(tmesh);
        tmesh = tmesh->next;
    }

    scene->vislist = (LQ_TRIFACE **)malloc(LQ_SORT_SLOTS * sizeof(LQ_TRIFACE *));
    scene->zbuffer = (float *)malloc(scene->xw * scene->yw * sizeof(float));
    memset(scene->zbuffer, 0, scene->xw*scene->yw * sizeof(float));

    scene->stencil_buffer = (ubyte *)malloc(scene->xw * scene->yw * sizeof(float));
    memset(scene->stencil_buffer, 0, scene->xw*scene->yw * sizeof(ubyte));
}

LQ_TRIMESH *LQ_SCENE_GetObjectFromPosition(LQ_SCENE *scene, word id)
{
    LQ_TRIMESH  *tlist = scene->trimesh_list;

    while(tlist) {
        if(tlist->obj_id == id)
            return tlist;

        tlist = tlist->next;
    }

    return NULL;
}
/*
void LQ_SCENE_BuildHierarchy(LQ_SCENE *scene)
{
    LQ_TRIMESH  *tmesh = scene->trimesh_list;
    LQ_TRIMESH  *prev, *next;

    prev = tmesh->prev;
    next = tmesh->next;
    while(tmesh) {

        if(tmesh->father_id != -1) {

            tmesh->father = LQ_SCENE_GetObjectFromPosition(scene, tmesh->father_id);
            tmesh->father->child = tmesh;
            prev->next = next;
            next->prev = prev;

        }

        prev = tmesh;
        tmesh = tmesh->next;
        next = tmesh->next;
    }


}
*/
void LQ_SCENE_SetWindow(LQ_SCENE *scene, float xw, float yw)
{
    scene->xw       = xw;
    scene->yw       = yw;
    scene->window_x = (xw-1) * 0.5;
    scene->window_y = (yw-1) * 0.5;
    scene->aratio   = 0.75 * ((xw-1)/(yw-1));
}

void LQ_SCENE_SetZClip(LQ_SCENE *scene, float znear, float zfar)
{
    scene->znear    = znear;
    scene->zfar     = zfar;
}


