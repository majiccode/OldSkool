///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// light module:
//      initial version:
//
////////////
#include "l3d.h"

LQ_LIGHT *LQ_LIGHT_Create(char *name)
{
    LQ_LIGHT    *light;

    light = (LQ_LIGHT *)malloc(sizeof(LQ_LIGHT));
    if(light) {
        light->name = (char *)strdup(name);
        light->next = NULL;
        light->prev = NULL;
        light->object_type = LQ_LIGHT_OBJECT;
    }
    return light;
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_LIGHT_CalcLambertShading                                           //
//                                                                       //
// - Go through all light sources and calculating lighting information   //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_LIGHT_CalcLambertShading(LQ_SCENE *scene, LQ_TRIFACE *face)
{
    LQ_TRIMESH  *obj    = face->obj;
    LQ_LIGHT    *light  = scene->light_list;
    float       rT, gT, bT;
    float       d, intensity, dist, falloff, range;
    LQ_VECTOR   *normal;
    LQ_VECTOR   lv;


    // ambient light in scene, set to total light:
    rT = scene->ambient.r;
    gT = scene->ambient.g;
    bT = scene->ambient.b;

    // run through all lights in scene:
    while(light) {
        if(LQ_ISFLAG(light->flags, LQ_LIGHT_VISABLE)) {

            switch(light->type) {
    
                //
                // omni light calculations:
                //
                //
                case LQ_LIGHT_OMNI:
                    range = light->range_end * light->range_end;
                    lv.x = light->light_pos.x - obj->vertex[ face->v1 ].x;
                    lv.y = light->light_pos.y - obj->vertex[ face->v1 ].y;
                    lv.z = light->light_pos.z - obj->vertex[ face->v1 ].z;
                    dist = LQ_VectorLengthSq(&lv);
                    if(dist <= range) {
                    //    falloff = 1.0 - (dist / light->range_end);
                        LQ_NormaliseVectorFast(&lv);
                        normal = &obj->normalF[ face->normal ];
                        d = LQ_DotProduct(&lv, normal);// * falloff;
                        if(d>0) {
                            rT += (light->colour.r * d);
                            gT += (light->colour.g * d);
                            bT += (light->colour.b * d);
                        }
                    }
                    break;
    
                //
                // spot light calculations:
                //
                // not real simulation of spot light.  I could simulate it by
                // a light map and project it onto a polygon by calculating the
                // uv coordinates for the polygons vertex correctly. will do this
                // later when i add texture mapping support. At the moment
                // it is simply a directional lightsource.
                //
                case LQ_LIGHT_SPOT:
                    normal = &obj->normalF[ face->normal ];

                    d = LQ_DotProduct(&light->light_vec, normal);
    
                    if(d>0) {
                        rT += (light->colour.r * d);
                        gT += (light->colour.g * d);
                        bT += (light->colour.b * d);
                    }
                    break;

            }
        }

        light = light->next;

    }


    if(rT > 1.0) rT = 1.0;
    if(rT < 0.0) rT = 0.0;

    if(gT > 1.0) gT = 1.0;
    if(gT < 0.0) gT = 0.0;

    if(bT > 1.0) bT = 1.0;
    if(bT < 0.0) bT = 0.0;

    intensity = 0.299*rT + 0.587*gT + 0.114*bT;
    if(intensity > 1.0) intensity = 1.0;
    if(intensity < 0.0) intensity = 0.0;

    face->data->face_colour.r = rT;
    face->data->face_colour.g = gT;
    face->data->face_colour.b = bT;
    face->data->intensity = intensity;
}

///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_LIGHT_CalcGouraudShading                                           //
//                                                                       //
// - Go through all light sources and calculating lighting information   //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_LIGHT_CalcGouraudShading(LQ_SCENE *scene, LQ_TRIMESH *obj)
{
    LQ_LIGHT    *light  = scene->light_list;
    float       rT, gT, bT;
    float       d, intensity, dist, falloff, range;
    LQ_VECTOR   lv;
    LQ_VTX_FLAG *vertexF = obj->vertexF;
    LQ_VECTOR   *vertexN = obj->normalV;
    LQ_VERTEX   *vertex  = obj->vertex;
    LQ_COLOUR   *vertexL = obj->vertexL;
    int         i;

    // all vertices that are connected to visable faces:
    for(i=0; i<obj->num_vertices; i++) {

        // ambient light in scene, set to total light:
        rT = scene->ambient.r;
        gT = scene->ambient.g;
        bT = scene->ambient.b;

        if(LQ_ISFLAG(*vertexF, LQ_VTX_LIGHT)) {

            while(light) {
                if(LQ_ISFLAG(light->flags, LQ_LIGHT_VISABLE)) {

                    switch(light->type) {
    
                    //
                    // omni light calculations:
                    //
                    //
                    case LQ_LIGHT_OMNI:
                        range = light->range_end * light->range_end;
                        lv.x = light->light_pos.x - vertex->x;
                        lv.y = light->light_pos.y - vertex->y;
                        lv.z = light->light_pos.z - vertex->z;
                        dist = LQ_VectorLengthSq(&lv);
                        if(dist <= range) {
                            LQ_NormaliseVectorFast(&lv);
                            d = LQ_DotProduct(&lv, vertexN);
                            if(d>0) {
                                rT += (light->colour.r * d);
                                gT += (light->colour.g * d);
                                bT += (light->colour.b * d);
                            }
                        }
                        break;
    
                    //
                    // spot light calculations:
                    //
                    // not real simulation of spot light.  I could simulate it by
                    // a light map and project it onto a polygon by calculating the
                    // uv coordinates for the polygons vertex correctly. will do this
                    // later when i add texture mapping support. At the moment
                    // it is simply a directional lightsource.
                    //
                    case LQ_LIGHT_SPOT:
                        d = LQ_DotProduct(&light->light_vec, vertexN);
        
                        if(d>0) {
                            rT += (light->colour.r * d);
                            gT += (light->colour.g * d);
                            bT += (light->colour.b * d);
                        }
                        break;
    
                    }
                }

                light = light->next;
            }
        }

        // clamp lighting values into range:
        if(rT > 1.0) rT = 1.0;
        if(rT < 0.0) rT = 0.0;

        if(gT > 1.0) gT = 1.0;
        if(gT < 0.0) gT = 0.0;

        if(bT > 1.0) bT = 1.0;
        if(bT < 0.0) bT = 0.0;


        // store lighting information:
        vertexL->r = rT;
        vertexL->g = gT;
        vertexL->b = bT;


        // next vertex:
        vertexF++;
        vertexN++;
        vertexL++;
        vertex++;
    }
}


///////////////////////////////////////////////////////////////////////////
//                                                                       //
// LQ_LIGHT_Process                                                      //
//                                                                       //
// - Transform lights into object space                                  //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
void LQ_LIGHT_Process(LQ_SCENE *scene, LQ_TRIMESH *obj)
{
    LQ_LIGHT        *light;

    // transform lights into object space:
    light = scene->light_list;
    while(light) {
        if(LQ_ISFLAG(light->flags, LQ_LIGHT_VISABLE)) {
            switch(light->type) {
                //
                // omni light transform:
                //
                case LQ_LIGHT_OMNI:
                    LQ_TransformVectorIT(obj->mat, &light->position, &light->light_pos);
                    break;
    
                //
                // spot light transform:
                //
                case LQ_LIGHT_SPOT:
                    LQ_TransformVectorIT(obj->mat, &light->position, &light->light_pos);
                    LQ_TransformVectorIT(obj->mat, &light->target, &light->light_tgt);
                    LQ_SubVector(&light->light_tgt, &light->light_pos, &light->light_vec);
                    LQ_NormaliseVectorFast(&light->light_vec);
                    break;
    
            }
        }

        light = light->next;
    }
}



