//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
//
// rendering kernel
//
//
// test version
//
//
//
#include "l3d.h"
#include <math.h>

LQ_SCENE    *active_scene;
LQ_CAMERA   *active_cam;
LQ_MATRIX4  cmat;
LQ_MATRIX4  pmat;


LQ_TRIFACE_CLIP clip_in[LQ_CLIP_STORAGE];
LQ_TRIFACE_CLIP clip_out[LQ_CLIP_STORAGE];
LQ_VERTEX       clip_out_sc[LQ_CLIP_STORAGE];

ubyte       *active_surface;
ubyte       *stencil_buffer;
float       *zbuffer;

int         LQ_frame;

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_RenderFace                                                         //
//                                                                       //
// - Render face and clip if required                                    //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_RenderFace(LQ_TRIFACE *face)
{
    LQ_TRIMESH      *trimesh = face->obj;
    LQ_VERTEX       *vertexS;
    LQ_VERTEX       *vertexR;
    LQ_UVCOORDS     *vertexUV;
    LQ_TRIPOINT     p1, p2, p3;
    LQ_TRIFACE_CLIP *clipface;
    int             num_verts;
    int             a, b, c, r, g, i;
    float           xw, yw, ooz;
    dword           col;

    //////
    // forcing FLAT shading at the moment
    face->rtype = LQ_FLAT;

    // rendering type:
    switch(face->rtype) {

        case LQ_FLAT:
            r = (ubyte)(face->data->face_colour.r * 255.0);
            g = (ubyte)(face->data->face_colour.g * 255.0);
            b = (ubyte)(face->data->face_colour.b * 255.0);

            col = (r<<16)+(g<<8)+b;

            // temp!
            col = face->col;


            if(!LQ_ISFLAG(face->flags, LQ_FACE_CLIP)) {

                vertexS = trimesh->vertexS;
                vertexR = trimesh->vertexR;
                a       = face->v1;
                b       = face->v2;
                c       = face->v3;

                p1.x    = vertexS[a].x + 0.5;
                p1.y    = vertexS[a].y + 0.5;
                p1.ooz  = vertexS[a].z;

                p2.x    = vertexS[b].x + 0.5;
                p2.y    = vertexS[b].y + 0.5;
                p2.ooz  = vertexS[b].z;

                p3.x    = vertexS[c].x + 0.5;
                p3.y    = vertexS[c].y + 0.5;
                p3.ooz  = vertexS[c].z;

                LQ_POLY_FlatFill(&p1, &p2, &p3, col);
            } else {

                clipface = LQ_ClipFace(face, &num_verts);
                xw = active_scene->window_x;
                yw = active_scene->window_y;

                for(i=0; i<num_verts; i++) {
                    ooz = 1.0 / clipface[i].v.z;
                    clip_out[i].v.x = (xw + (xw * clipface[i].v.x * ooz))+0.5;
                    clip_out[i].v.y = (yw - (yw * clipface[i].v.y * ooz))+0.5;
                    clip_out[i].v.z = ooz;
                }

                // triangulate n-gon
                a = 0;
                for(i=2; i<num_verts; i++) {
                    b = i - 1;
                    c = i;

                    p1.x    = clip_out[a].v.x;
                    p1.y    = clip_out[a].v.y;
                    p1.ooz  = clip_out[a].v.z;

                    p2.x    = clip_out[b].v.x;
                    p2.y    = clip_out[b].v.y;
                    p2.ooz  = clip_out[b].v.z;

                    p3.x    = clip_out[c].v.x;
                    p3.y    = clip_out[c].v.y;
                    p3.ooz  = clip_out[c].v.z;

                    LQ_POLY_FlatFill(&p1, &p2, &p3, col);
                }
            }

            break;

        // next rendering mode inserted here:
        //
        //
    }


}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_RenderVisList                                                      //
//                                                                       //
// - Render global visability list                                       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_RenderVisList(void)
{
    LQ_TRIFACE      *startface, *face;
    LQ_TRIFACE      **vislist;
    LQ_TRIFACE_CLIP *clipface;
    int             i, num_verts;

    if(LQ_ISFLAG(active_scene->flags, LQ_SCENE_FRONTBACK)) {
        vislist = active_scene->vislist;
        for(i=0; i<LQ_SORT_SLOTS; i++) {
            if(*vislist) {
                startface = *vislist;
                face = startface->next;
                while(face) {
                    LQ_RenderFace(face);
                    face = face->next;
                }
                LQ_RenderFace(startface);
            }
            vislist++;
        }
    } else {
        vislist = &active_scene->vislist[LQ_SORT_SLOTS-1];
        for(i=0; i<LQ_SORT_SLOTS; i++) {
            if(*vislist) {
                startface = *vislist;
                face = startface->next;
                while(face) {
                    LQ_RenderFace(face);
                    face = face->next;
                }
                LQ_RenderFace(startface);
            }
            vislist--;
        }
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_AddFace                                                            //
//                                                                       //
// - Add face into global visability list                                //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_AddFace(LQ_TRIFACE *face)
{
    LQ_TRIMESH  *obj        = face->obj;
    LQ_TRIFACE  **vislist   = active_scene->vislist;
    float       sort_z;
    int         i;
    
    sort_z = (MAX(obj->vertexR[face->v1].z,
              MAX(obj->vertexR[face->v2].z, obj->vertexR[face->v3].z))) * LQ_SORT_SCALE;

    frndint(&i, sort_z);

    if(i>=0 && i<LQ_SORT_SLOTS) {


        // perform lighting on this face:
        switch(obj->stype) {
            //
            // lambert shading
            //
            case LQ_LAMBERT:
                LQ_LIGHT_CalcLambertShading(active_scene, face);
                break;
        }

        // add face to vislist:
        if(!active_scene->vislist[i]) {
            face->next = NULL;
            vislist[i] = face;
        } else {
            face->next = vislist[i];
            vislist[i] = face;
        }

        active_scene->num_vis++;
    }
}






///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_TransformVisableVertices                                           //
//                                                                       //
// - Transform objects vertices by matrix that are flagged for xform     //
// - Project vertices and overlap perspective divide (for asm opt)       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_TransformVisableVertices(LQ_TRIMESH *obj, LQ_MATRIX4 m)
{
    LQ_VERTEX   *vertex  = obj->vertex;
    LQ_VERTEX   *vertexR = obj->vertexR;
    LQ_VTX_FLAG *vertexF = obj->vertexF;
    LQ_VERTEX   *vertexS = obj->vertexS;
    int         i;
    float       xw, yw;

    xw = active_scene->window_x;
    yw = active_scene->window_y;


    for(i=0; i<obj->num_vertices; i++) {
        if(LQ_ISFLAG(*vertexF, LQ_VTX_XFORM)) {
            vertexR->x = vertex->x*m[XX] + vertex->y*m[XY] + vertex->z*m[XZ] + m[TX];
            vertexR->y = vertex->x*m[YX] + vertex->y*m[YY] + vertex->z*m[YZ] + m[TY];
            vertexR->z = vertex->x*m[ZX] + vertex->y*m[ZY] + vertex->z*m[ZZ] + m[TZ];

            vertexS->z = 1.0 / vertexR->z;  // !pipeline this!
            vertexS->x = xw + (xw * vertexR->x * vertexS->z);
            vertexS->y = yw - (yw * vertexR->y * vertexS->z);
        }
        vertex++;
        vertexF++;
        vertexR++;
        vertexS++;
    }
}



///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_TransformAllVertices                                               //
//                                                                       //
// - Transform objects vertices by matrix                                //
// - Project vertices and overlap perspective divide (for asm opt)       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_TransformAllVertices(LQ_TRIMESH *obj, LQ_MATRIX4 m)
{
    LQ_VERTEX   *vertex  = obj->vertex;
    LQ_VERTEX   *vertexR = obj->vertexR;
    LQ_VERTEX   *vertexS = obj->vertexS;
    LQ_VTX_FLAG *vertexF = obj->vertexF;
    int         i;
    float       xw, yw;

    xw = active_scene->window_x;
    yw = active_scene->window_y;


    for(i=0; i<obj->num_vertices; i++) {
        vertexR->x = vertex->x*m[XX] + vertex->y*m[XY] + vertex->z*m[XZ] + m[TX];
        vertexR->y = vertex->x*m[YX] + vertex->y*m[YY] + vertex->z*m[YZ] + m[TY];
        vertexR->z = vertex->x*m[ZX] + vertex->y*m[ZY] + vertex->z*m[ZZ] + m[TZ];
        vertexS->z = 1.0 / vertexR->z;
        vertexS->x = xw + (xw * vertexR->x * vertexS->z);
        vertexS->y = yw - (yw * vertexR->y * vertexS->z);
        *vertexF = LQ_VTX_LIGHT;
        vertexS++;
        vertexR++;
        vertexF++;
        vertex++;
    }
}

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_CullFaces                                                          //
//                                                                       //
//  - Back face culling of faces                                         //
//  - Flags vertices for xform/projection                                //
//  - Adds faces to the global visable face list                         //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_CullFaces(LQ_TRIMESH *obj, LQ_VECTOR *pos)
{
    LQ_VERTEX   *vertex     = obj->vertex;
    LQ_VTX_FLAG *vertexF    = obj->vertexF;
    LQ_TRIFACE  *face       = obj->face;
    LQ_VECTOR   *normalF    = obj->normalF;
    int         i, v1, v2, v3;
    float       ex, ey, ez, d;

    memset(vertexF, 0, sizeof(LQ_VTX_FLAG) * obj->num_vertices);
    for(i=0; i<obj->num_faces; i++) {
        face->flags = 0;
        v1 = face->v1;
        v2 = face->v2;
        v3 = face->v3;
        ex = pos->x - vertex[v1].x;
        ey = pos->y - vertex[v1].y;
        ez = pos->z - vertex[v1].z;
        d = ex*normalF->x + ey*normalF->y + ez*normalF->z;
        if(d>0.0) {
            vertexF[v1] = LQ_VTX_XFORM|LQ_VTX_PROJECT|LQ_VTX_LIGHT;
            vertexF[v2] = LQ_VTX_XFORM|LQ_VTX_PROJECT|LQ_VTX_LIGHT;
            vertexF[v3] = LQ_VTX_XFORM|LQ_VTX_PROJECT|LQ_VTX_LIGHT;
            LQ_AddFace(face);
        }
        face++;
        normalF++;
    }
}

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_AddAllToVisList                                                    //
//                                                                       //
// - Use ordering table scheme to quickly sort visability list           //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_AddAllToVisList(LQ_TRIMESH *obj)
{
    LQ_TRIFACE  *face       = obj->face;
    int         i;
    
    for(i=0; i<obj->num_faces; i++) {
        LQ_AddFace(face);
        face++;
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_CullFacesLocal                                                     //
//                                                                       //
//  - Back face culling of faces                                         //
//  - Flags vertices for xform/projection                                //
//  - Adds faces to the local visable face list                          //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_CullFacesLocal(LQ_TRIMESH *obj, LQ_VECTOR *pos)
{
    LQ_VERTEX   *vertex     = obj->vertex;
    LQ_VTX_FLAG *vertexF    = obj->vertexF;
    LQ_TRIFACE  *face       = obj->face;
    LQ_VECTOR   *normalF    = obj->normalF;
    int         i, v1, v2, v3;
    float       ex, ey, ez, d;

    obj->num_vis = 0;
    memset(vertexF, 0, sizeof(LQ_VTX_FLAG) * obj->num_vertices);
    for(i=0; i<obj->num_faces; i++) {
        face->flags = 0;
        v1 = face->v1;
        v2 = face->v2;
        v3 = face->v3;
        ex = pos->x - vertex[v1].x;
        ey = pos->y - vertex[v1].y;
        ez = pos->z - vertex[v1].z;
        d = ex*normalF->x + ey*normalF->y + ez*normalF->z;
        if(d>0.0) {
            obj->vislist[obj->num_vis++] = face;
            vertexF[v1] = LQ_VTX_XFORM|LQ_VTX_PROJECT;
            vertexF[v2] = LQ_VTX_XFORM|LQ_VTX_PROJECT;
            vertexF[v3] = LQ_VTX_XFORM|LQ_VTX_PROJECT;
        }
        face++;
        normalF++;
    }
}

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_TransformVisableVerticesLocal                                      //
//                                                                       //
// - Transform objects vertices by matrix that are flagged for xform     //
// - Project vertices and overlap perspective divide (for asm opt)       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_TransformVisableVerticesLocal(LQ_TRIMESH *obj, LQ_MATRIX4 m)
{
    LQ_VERTEX   *vertex  = obj->vertex;
    LQ_VERTEX   *vertexR = obj->vertexR;
    LQ_VTX_FLAG *vertexF = obj->vertexF;
    LQ_VERTEX   *vertexS = obj->vertexS;
    udword      vis;
    int         i;
    float       xw, yw, x, y, z;

    xw = active_scene->window_x;
    yw = active_scene->window_y;

    for(i=0; i<obj->num_vertices; i++) {
        if(LQ_ISFLAG(*vertexF, LQ_VTX_XFORM)) {

            x = vertex->x*m[XX] + vertex->y*m[XY] + vertex->z*m[XZ] + m[TX];
            y = vertex->x*m[YX] + vertex->y*m[YY] + vertex->z*m[YZ] + m[TY];
            z = vertex->x*m[ZX] + vertex->y*m[ZY] + vertex->z*m[ZZ] + m[TZ];
            vis = 0;
            if(x < -z)
                LQ_SETFLAG(vis, LQ_VTX_CLIP_LEFT);

            if(x >  z)
                LQ_SETFLAG(vis, LQ_VTX_CLIP_RIGHT);

            if(y < -z)
                LQ_SETFLAG(vis, LQ_VTX_CLIP_BOTTOM);

            if(y >  z)
                LQ_SETFLAG(vis, LQ_VTX_CLIP_TOP);

            
            *vertexF = vis;

            
            vertexR->x = x;
            vertexR->y = y;
            vertexR->z = z;

            if(!vis) {
                vertexS->z = 1.0 / z;
                vertexS->x = xw + (xw * x * vertexS->z);
                vertexS->y = yw - (yw * y * vertexS->z);
            }
        }
        vertexF++;
        vertex++;
        vertexR++;
        vertexS++;
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_AddToVisListLocal                                                  //
//                                                                       //
//  - Flags faces for clipping                                           //
//  - Add visable/partially visable faces to global visability list      //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_AddToVisListLocal(LQ_TRIMESH *obj)
{
    LQ_TRIFACE      *face;
    LQ_TRIFACE      **ovislist  = obj->vislist;
    LQ_TRIFACE      **vislist   = active_scene->vislist;
    LQ_VERTEX       *vertexR    = obj->vertexR;
    LQ_VTX_FLAG     *vertexF    = obj->vertexF;
    udword          a, b, c, vis, reject;
    int             i;

    for(i=0; i<obj->num_vis; i++) {
        face = *ovislist;

        a = vertexF[ face->v1 ] & (LQ_VTX_CLIP_RIGHT | LQ_VTX_CLIP_LEFT | LQ_VTX_CLIP_TOP | LQ_VTX_CLIP_BOTTOM);
        b = vertexF[ face->v2 ] & (LQ_VTX_CLIP_RIGHT | LQ_VTX_CLIP_LEFT | LQ_VTX_CLIP_TOP | LQ_VTX_CLIP_BOTTOM);
        c = vertexF[ face->v3 ] & (LQ_VTX_CLIP_RIGHT | LQ_VTX_CLIP_LEFT | LQ_VTX_CLIP_TOP | LQ_VTX_CLIP_BOTTOM);
        vis = !(a&&b&&c);
        face->flags = (a|b|c);

        // is a vertex visable?
        if(vis) {
            LQ_AddFace(face);
            LQ_SETFLAG(vertexF[ face->v1 ], LQ_VTX_LIGHT);
            LQ_SETFLAG(vertexF[ face->v2 ], LQ_VTX_LIGHT);
            LQ_SETFLAG(vertexF[ face->v3 ], LQ_VTX_LIGHT);

            // any hidden vertices?
            if(a||b||c)
                LQ_SETFLAG(face->flags, LQ_FACE_CLIP);

        } else {
            reject = (a&b&c);
            if(!reject) {
                LQ_AddFace(face);
                LQ_SETFLAG(vertexF[ face->v1 ], LQ_VTX_LIGHT);
                LQ_SETFLAG(vertexF[ face->v2 ], LQ_VTX_LIGHT);
                LQ_SETFLAG(vertexF[ face->v3 ], LQ_VTX_LIGHT);
                LQ_SETFLAG(face->flags, LQ_FACE_CLIP);
            }
        }
        ovislist++;
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_AddAllFacesLocal                                                   //
//                                                                       //
// - Add all faces to the local visability list                          //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_AddAllFacesLocal(LQ_TRIMESH *obj)
{
    LQ_TRIFACE  *face       = obj->face;
    LQ_VTX_FLAG *vertexF    = obj->vertexF;
    int         i;

    memset(vertexF, LQ_VTX_XFORM|LQ_VTX_PROJECT, sizeof(LQ_VTX_FLAG) * obj->num_vertices);
    obj->num_vis = 0;
    for(i=0; i<obj->num_faces; i++) {
        LQ_CLEARFLAG(face->flags, LQ_FACE_CLIP);
        obj->vislist[obj->num_vis++] = face;
        face++;
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_CheckBBox                                                          //
//                                                                       //
//  Checks a bounding box against view volume. The matrix passed should  //
//  incorperate the perspective warp.                                    //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
ubyte LQ_CheckBBox(LQ_BBOX *bbox, LQ_MATRIX4 m)
{
    int         i;
    LQ_VECTOR   v;
    float       minx, miny, minz;
    float       maxx, maxy, maxz;

    LQ_TransformVectorT(m, &bbox->v[0], &v);
    minx = maxx = v.x;
    miny = maxy = v.y;
    minz = maxz = v.z;
    for(i=1; i<8; i++) {
        LQ_TransformVectorT(m, &bbox->v[i], &v);
        if(v.x > maxx) maxx = v.x;
        if(v.x < minx) minx = v.x;
        if(v.y > maxy) maxy = v.y;
        if(v.y < miny) miny = v.y;
        if(v.z > maxz) maxz = v.z;
        if(v.z < minz) minz = v.z;
    }

    // check for visability:
    if(maxz <  0)
        return 0;
    if(maxx < -maxz)
        return 0;
    if(minx > maxz)
        return 0;
    if(maxy < -maxz)
        return 0;
    if(miny > maxz)
        return 0;

    // check for partial visability
    if(minx < -minz)
        return 2;
    if(maxx > minz)
        return 2;
    if(miny < -minz)
        return 2;
    if(maxy > minz)
        return 2;

    // full visability:
    return 1;
}


void LQ_BuildTrimeshXform(void)
{
    LQ_TRIMESH  *obj;
    LQ_VECTOR   pivot, trans;


    obj = active_scene->trimesh_list;
    while(obj) {
        if(LQ_ISFLAG(obj->flags, LQ_TRIMESH_VISABLE)) {

        
            // translate to pivot point:
            LQ_SetVector(&pivot, -obj->pivot.x, -obj->pivot.y, -obj->pivot.z);
            LQ_SetMatrixPreTrans(obj->mat, &pivot);

            // translate to world position:
            LQ_SetVector(&trans, obj->trans.x+pivot.x,
                                 obj->trans.y+pivot.y,
                                 obj->trans.z+pivot.z);
            LQ_SetMatrixPostTrans(obj->mat, &trans);
    

        }

        obj = obj->next;
    }
}

        
void LQ_XFormTrimesh(LQ_TRIMESH *obj, LQ_MATRIX4 mat)
{
    
}

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_ProcessTrimesh                                                     //
//                                                                       //
//  Takes a trimesh and transforms it into the world visability          //
//  list                                                                 //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_ProcessTrimesh(LQ_TRIMESH *obj)
{
    LQ_VECTOR   pos, pivot, trans;
    LQ_MATRIX4  pivot_mat;
    LQ_MATRIX4  view_mat;
    LQ_MATRIX4  temp_mat, temp_mat2, rmat;
    byte        vis;



    // do we have a father object?


//    if(obj->father_id == -1) {

        // no father, root object:


        // add world to camera space transform:
        LQ_MatrixMul(cmat, obj->mat, temp_mat);

        // add perspective transform:
        LQ_MatrixMul(pmat, temp_mat, view_mat);


//    } else {

        // we have a father so move up chain till we find root object



//    }



        // add world to camera space transform:
//        LQ_MatrixMul(cmat, obj->mat, temp_mat);

    // add perspective transform:
//    LQ_MatrixMul(pmat, temp_mat, view_mat);


    // check bounding box against view volume:
    vis = LQ_CheckBBox(&obj->bbox, view_mat);
    if(vis) {

        LQ_TransformVectorIT(obj->mat, &active_cam->position, &pos);

        // transform lights:
        LQ_LIGHT_Process(active_scene, obj);

        if(vis == 1) {

            //////////////////////////
            // Fully Visable Object //
            //////////////////////////
            if(LQ_ISFLAG(obj->flags, LQ_TRIMESH_CULL)) {

                // back face culling enabled:
                LQ_CullFaces(obj, &pos);
                LQ_TransformVisableVertices(obj, view_mat);
              //  LQ_AddToVisListLocal(obj);

            } else {

                // no back face culling being used:
                LQ_AddAllToVisList(obj);
                LQ_TransformAllVertices(obj, view_mat);

            }

        } else {

            //////////////////////////////
            // Partially Visable Object //
            //////////////////////////////
            if(LQ_ISFLAG(obj->flags, LQ_TRIMESH_CULL)) {

                // back face culling enabled:
                LQ_CullFacesLocal(obj, &pos);
                LQ_TransformVisableVerticesLocal(obj, view_mat);
                LQ_AddToVisListLocal(obj);

            } else {

                // no back face culling being used:
                LQ_AddAllFacesLocal(obj);
                LQ_TransformVisableVerticesLocal(obj, view_mat);
                LQ_AddToVisListLocal(obj);

            }
        }    

        // perform lighting on this face:
        switch(obj->stype) {
            //
            // gouraud shading
            //
            case LQ_GOURAUD:
                LQ_LIGHT_CalcGouraudShading(active_scene, obj);
                break;
        }
    }
}    

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_CullLight                                                          //
//                                                                       //
// - Culls light  to view volume                                         //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_CullLight(LQ_LIGHT *light)
{
    LQ_VECTOR   pos;

    // transform light into camera space:
    LQ_TransformVectorT(cmat, &light->position, &pos);

    light->flags = LQ_LIGHT_HIDDEN;

    // check light against view volume:
    if((pos.x+light->range_end) <-pos.z)
        return;

    if((pos.x-light->range_end) > pos.z)
        return;

    if((pos.y+light->range_end) <-pos.z)
        return;

    if((pos.y-light->range_end) > pos.z)
        return;

    light->flags = LQ_LIGHT_VISABLE;
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_SetupPerspective                                                   //
//                                                                       //
//  sets up perspective matrix for 3D clipping                           //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_SetupPerspective(LQ_SCENE *scene, LQ_CAMERA *cam, LQ_MATRIX4 m)
{
    float   dx, dy;

    dx = scene->window_x * cam->ootfov;
    dy = ((scene->window_y * scene->aratio) / scene->window_x) * dx;

    scene->znear = dx;

    LQ_MatrixIdent(m);
    m[XX] = dx / scene->window_x;
    m[YY] = dy / scene->window_y;
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_RenderScene                                                        //
//                                                                       //
//  render a scene into buffer                                           //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_RenderScene(LQ_SCENE *scene, LQ_CAMERA *cam, ubyte *buf, int frame)
{
    LQ_LIGHT    *light;
    LQ_TRIMESH  *obj;
    int         i;

    // setup globals:
    active_scene    = scene;
    active_cam      = cam;
    active_surface  = buf;
    scene->num_vis  = 0;
    zbuffer         = active_scene->zbuffer;
    stencil_buffer  = active_scene->stencil_buffer;
    LQ_frame        = frame;

    // clear vislist
    memset(active_scene->vislist, 0, LQ_SORT_SLOTS * sizeof(LQ_TRIFACE *));

    //memset(scene->stencil_buffer, 0, scene->xw*scene->yw * sizeof(float));

    LQ_SetupPerspective(scene, cam, pmat);
    LQ_CAMERA_Setup(cam, cmat);

  
    // process lights in scene:
    light = scene->light_list;
    while(light) {
        LQ_CullLight(light);
        light = light->next;
    }


    LQ_BuildTrimeshXform();


    // process trimeshs in object chain:
    obj = scene->trimesh_list;
    while(obj) {
        if(LQ_ISFLAG(obj->flags, LQ_TRIMESH_VISABLE))
            LQ_ProcessTrimesh(obj);

        obj = obj->next;
    }

    if(active_scene->num_vis) {

        // render global visability list:
        LQ_RenderVisList();
    }
}


