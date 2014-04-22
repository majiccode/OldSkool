///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// trimesh object handling module:
//      initial version:
//
////////////
#include "l3d.h"

    
LQ_TRIMESH *LQ_TRIMESH_Create(char *name)
{
    int         i;
    LQ_TRIMESH  *obj;

    obj = (LQ_TRIMESH *)malloc(sizeof(LQ_TRIMESH));
    if(obj) {
        obj->object_type    = LQ_TRIMESH_OBJECT;
        obj->next           = NULL;
        obj->prev           = NULL;
        obj->name           = (char *)strdup(name);
        obj->father_id      = -1;
        obj->obj_id         = 0;

        obj->num_vertices   = 0;
        obj->num_faces      = 0;
        obj->num_vis        = 0;
        obj->flags          = LQ_TRIMESH_VISABLE | LQ_TRIMESH_CULL;

        obj->vertex         = NULL;
        obj->vertexR        = NULL;
        obj->vertexS        = NULL;
        obj->uv             = NULL;
        obj->vertexF        = NULL;

        obj->normalF        = NULL;
        obj->normalV        = NULL;
        obj->face           = NULL;

        LQ_MatrixIdent(obj->mat);
        LQ_SetVector(&obj->trans, 0,0,0);
    }

    return obj;
}

LQ_VERTEX *LQ_TRIMESH_VertexList(LQ_TRIMESH *obj, udword num_vertices)
{
    obj->num_vertices   = num_vertices;
    obj->vertex         = (LQ_VERTEX *)malloc(num_vertices * sizeof(LQ_VERTEX));
    obj->vertexR        = (LQ_VERTEX *)malloc(num_vertices * sizeof(LQ_VERTEX));
    obj->vertexF        = (LQ_VTX_FLAG *)malloc(num_vertices * sizeof(LQ_VTX_FLAG));
    obj->vertexS        = (LQ_VERTEX *)malloc(num_vertices * sizeof(LQ_VERTEX));
    return obj->vertex;
}

LQ_UVCOORDS *LQ_TRIMESH_UVList(LQ_TRIMESH *obj, udword n)
{
    obj->uv = (LQ_UVCOORDS *)malloc(n * sizeof(LQ_UVCOORDS));
    return obj->uv;
}

LQ_VECTOR *LQ_TRIMESH_VertexNormalList(LQ_TRIMESH *obj, udword num_vertices)
{
    obj->normalV = (LQ_VECTOR *)malloc(num_vertices * sizeof(LQ_VECTOR));
    return obj->normalV;
}

LQ_TRIFACE *LQ_TRIMESH_FaceList(LQ_TRIMESH *obj, udword num_faces)
{
    int i;

    obj->face = (LQ_TRIFACE *)malloc(num_faces * sizeof(LQ_TRIFACE));
    obj->vislist = (LQ_TRIFACE **)malloc(num_faces * sizeof(LQ_TRIFACE *));
    obj->num_faces = num_faces;

    for(i=0; i<num_faces; i++) {
        obj->face[i].obj = obj;
        obj->face[i].data = (LQ_TRIFACE_DATA *)malloc(sizeof(LQ_TRIFACE_DATA));
        obj->face[i].stype = LQ_NO_SHADING;
    }

    return obj->face;
}

LQ_VECTOR *LQ_TRIMESH_FaceNormalList(LQ_TRIMESH *obj, udword num_faces)
{
    obj->normalF = (LQ_VECTOR *)malloc(num_faces * sizeof(LQ_VECTOR));
    return obj->normalF;
}


void LQ_TRIMESH_BoundingBox(LQ_TRIMESH *obj)
{
    int     i;
    float   x, y, z;

    obj->bbox.minx = obj->vertex[0].x;
    obj->bbox.maxx = obj->vertex[0].x;
    obj->bbox.miny = obj->vertex[0].y;
    obj->bbox.maxy = obj->vertex[0].y;
    obj->bbox.minz = obj->vertex[0].z;
    obj->bbox.maxz = obj->vertex[0].z;

    for(i=1; i<obj->num_vertices; i++) {
        x = obj->vertex[i].x;
        y = obj->vertex[i].y;
        z = obj->vertex[i].z;

        if(x < obj->bbox.minx)
            obj->bbox.minx = x;
        if(x > obj->bbox.maxx)
            obj->bbox.maxx = x;

        if(y < obj->bbox.miny)
            obj->bbox.miny = y;
        if(y > obj->bbox.maxy)
            obj->bbox.maxy = y;

        if(z < obj->bbox.minz)
            obj->bbox.minz = z;
        if(z > obj->bbox.maxz)
            obj->bbox.maxz = z;
    }

    LQ_SetVector(&obj->bbox.v[0], obj->bbox.minx, obj->bbox.miny, obj->bbox.minz);
    LQ_SetVector(&obj->bbox.v[1], obj->bbox.minx, obj->bbox.miny, obj->bbox.maxz);
    LQ_SetVector(&obj->bbox.v[2], obj->bbox.minx, obj->bbox.maxy, obj->bbox.minz);
    LQ_SetVector(&obj->bbox.v[3], obj->bbox.minx, obj->bbox.maxy, obj->bbox.maxz);
    LQ_SetVector(&obj->bbox.v[4], obj->bbox.maxx, obj->bbox.miny, obj->bbox.minz);
    LQ_SetVector(&obj->bbox.v[5], obj->bbox.maxx, obj->bbox.miny, obj->bbox.maxz);
    LQ_SetVector(&obj->bbox.v[6], obj->bbox.maxx, obj->bbox.maxy, obj->bbox.minz);
    LQ_SetVector(&obj->bbox.v[7], obj->bbox.maxx, obj->bbox.maxy, obj->bbox.maxz);
}


void LQ_TRIMESH_FaceNormals(LQ_TRIMESH *obj)
{
    int         i;
    float       ax, ay, az, bx, by, bz;
    float       nx, ny, nz;
    float       l;
    ubyte       sign, newsign;

    for(i=0; i<obj->num_faces; i++) {
        ax = obj->vertex[obj->face[i].v1].x - obj->vertex[obj->face[i].v2].x;
        ay = obj->vertex[obj->face[i].v1].z - obj->vertex[obj->face[i].v2].z;
        az = obj->vertex[obj->face[i].v1].y - obj->vertex[obj->face[i].v2].y;
        bx = obj->vertex[obj->face[i].v1].x - obj->vertex[obj->face[i].v3].x;
        by = obj->vertex[obj->face[i].v1].z - obj->vertex[obj->face[i].v3].z;
        bz = obj->vertex[obj->face[i].v1].y - obj->vertex[obj->face[i].v3].y;
        nx = ay*bz - az*by;
        ny = az*bx - bz*ax;
        nz = ax*by - ay*bx;
        l = nx*nx + ny*ny + nz*nz;
        if(l<0.0)
            l=1.0;
        l = 1.0 / fsqrt(l);
        nx*=l;
        ny*=l;
        nz*=l;

        obj->normalF[i].x = nx;
        obj->normalF[i].y = nz;
        obj->normalF[i].z = ny;
        obj->face[i].normal = i;
    }
}


void LQ_TRIMESH_ToObjectSpace(LQ_TRIMESH *obj, LQ_MATRIX4 m)
{
    int     i;
    float   x, y, z;

    for(i=0; i<obj->num_vertices; i++) {
        obj->vertex[i].x -= obj->trans.x;
        obj->vertex[i].y -= obj->trans.y;
        obj->vertex[i].z -= obj->trans.z;
        x = obj->vertex[i].x * m[XX] + obj->vertex[i].y * m[YX] + obj->vertex[i].z * m[ZX];
        y = obj->vertex[i].x * m[XY] + obj->vertex[i].y * m[YY] + obj->vertex[i].z * m[ZY];
        z = obj->vertex[i].x * m[XZ] + obj->vertex[i].y * m[YZ] + obj->vertex[i].z * m[ZZ];
        obj->vertex[i].x = x;
        obj->vertex[i].y = y;
        obj->vertex[i].z = z;
    }
}


void LQ_TRIMESH_SetRenderType(LQ_TRIMESH *obj, LQ_RENDER_TYPE type)
{
    obj->rtype = type;
}

