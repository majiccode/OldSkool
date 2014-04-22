///////////////////////////////////////////////////////////////////////////
//
// l3d - liquid 3D engine for 64k intros. Watcom C prototype version:
// code : frenzy
//
// 
// keyframer system - initial version:
//
////////////
#include "l3d.h"

void LQ_CalculateKeysSplineDerivs(LQ_KEY *pkey, LQ_KEY *key, LQ_KEY *nkey, udword type)
{
    float   tm, bm, bp, cm, cp;
    float   tmbp, tmbm, a, b, c, d;
    float   d1, d2, dsadjust, ddadjust;
    float   pf,f,nf;

    f  = key->key_num;
    pf = pkey->key_num;
    nf = nkey->key_num;

    dsadjust = 1.0;//(f - pf)/(nf - pf);
    ddadjust = 1.0;//(nf - f)/(nf - pf);

    tm = 0.5 * (1.0-key->tcb.tension);
    bm = 1.0-key->tcb.bias;
    bp = 2.0-bm;
    cm = 1.0-key->tcb.continuity;
    cp = 2.0-cm;
    tmbp = tm*bp;
    tmbm = tm*bm;
    a = tmbp*cp;
    b = tmbm*cm;
    c = tmbp*cm;
    d = tmbm*cp;

    switch(type) {
        case LQ_POSITION_TRACK:
        case LQ_TARGET_TRACK:
            // source derivative:
            key->ds.x = (a*(key->val.pos.x - pkey->val.pos.x) + b*(nkey->val.pos.x - key->val.pos.x)) * dsadjust;
            key->ds.y = (a*(key->val.pos.y - pkey->val.pos.y) + b*(nkey->val.pos.y - key->val.pos.y)) * dsadjust;
            key->ds.z = (a*(key->val.pos.z - pkey->val.pos.z) + b*(nkey->val.pos.z - key->val.pos.z)) * dsadjust;

            // destination derivative:
            key->dd.x = (c*(key->val.pos.x - pkey->val.pos.x) + d*(nkey->val.pos.x - key->val.pos.x)) * ddadjust;
            key->dd.y = (c*(key->val.pos.y - pkey->val.pos.y) + d*(nkey->val.pos.y - key->val.pos.y)) * ddadjust;
            key->dd.z = (c*(key->val.pos.z - pkey->val.pos.z) + d*(nkey->val.pos.z - key->val.pos.z)) * ddadjust;
            break;
    }
}    

void LQ_CalculateKeysSplineDerivsFirst(LQ_KEY *key, LQ_KEY *nkey, LQ_KEY *nnkey, udword type)
{
	float	f20,f10,v20,v10;

    f20 = nnkey->key_num - key->key_num;
    f10 = nkey->key_num - key->key_num;


    switch(type) {
        case LQ_POSITION_TRACK:
        case LQ_TARGET_TRACK:
            v20 = nnkey->val.pos.x - key->val.pos.x;
            v10 = nkey->val.pos.x - key->val.pos.x;
            key->dd.x = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);

            v20 = nnkey->val.pos.y - key->val.pos.y;
            v10 = nkey->val.pos.y - key->val.pos.y;
            key->dd.y = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);

            v20 = nnkey->val.pos.z - key->val.pos.z;
            v10 = nkey->val.pos.z - key->val.pos.z;
            key->dd.z = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);
            break;
    }
}


void LQ_CalculateKeysSplineDerivsLast(LQ_KEY *ppkey, LQ_KEY *pkey, LQ_KEY *key, udword type)
{
	float	f20,f10,v20,v10;
    f20 = key->key_num - ppkey->key_num;
    f10 = key->key_num - pkey->key_num;

    switch(type) {
        case LQ_POSITION_TRACK:
        case LQ_TARGET_TRACK:
            v20 = key->val.pos.x - ppkey->val.pos.x;
            v10 = key->val.pos.x - pkey->val.pos.x;
            key->ds.x = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);

            v20 = key->val.pos.y - ppkey->val.pos.y;
            v10 = key->val.pos.y - pkey->val.pos.y;
            key->ds.y = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);

            v20 = key->val.pos.z - ppkey->val.pos.z;
            v10 = key->val.pos.z - pkey->val.pos.z;
            key->ds.z = (1-key->tcb.tension)*(v20*(0.25 - f10/(2*f20)) + (v10 - v20/2)*3/2 + v20/2);
            break;
    }
}


void LQ_CalculateTracksSplineDerives(LQ_TRACK *track)
{
    int     i;
    LQ_KEY  *ppkey, *pkey, *key, *nkey, *nnkey;


    if(track->num_keys >= 3) {
        pkey = track->keys;
        key = pkey->next;
        nkey = key->next;
        nnkey = nkey->next;

        LQ_CalculateKeysSplineDerivsFirst(pkey, key, nkey, track->type);

        for(i=1; i<track->num_keys-1; i++) {
            LQ_CalculateKeysSplineDerivs(pkey, key, nkey, track->type);
            pkey = key;
            key = nkey;
            nkey = key->next;
        }

        ppkey = pkey->prev;
        LQ_CalculateKeysSplineDerivsLast(ppkey, pkey, key, track->type);
    }

    if(track->num_keys <= 2) {
        key=track->keys;
        nkey = key->next;
        while(nkey) {
            nkey->val.pos.x = key->val.pos.x;
            nkey->val.pos.y = key->val.pos.y;
            nkey->val.pos.z = key->val.pos.z;
            nkey = nkey->next;
        }
    }
}

void LQ_SplineInterpolate(LQ_KEY *key, LQ_KEY *nkey, float t, LQ_KDATA *val, udword type)
{
    float   t2, t3, a, b;
    float   k1, k2, k3, k4;

    t2 = t*t;
    t3 = t2*t;
    a = 2*t3;
    b = 3*t2;

    k1 = a-b+1;
    k2 = -a+b;
    k3 = t3-2*t2+t;
    k4 = t3-t2;

    switch(type) {
        case LQ_POSITION_TRACK:
        case LQ_TARGET_TRACK:
            val->pos.x = k1*key->val.pos.x + k2*nkey->val.pos.x + k3*key->dd.x + k4*nkey->ds.x;
            val->pos.y = k1*key->val.pos.y + k2*nkey->val.pos.y + k3*key->dd.y + k4*nkey->ds.y;
            val->pos.z = k1*key->val.pos.z + k2*nkey->val.pos.z + k3*key->dd.z + k4*nkey->ds.z;
            break;

        case LQ_ROTATION_TRACK:
            LQ_QuatSlerp(&key->val.rot, &nkey->val.rot, t, &val->rot);
            break;

    }
}


void LQ_InitKeyframer(LQ_KEYFRAMER *kf)
{
    kf->tracks = NULL;
    kf->num_tracks = 0;
    kf->frames = 0;
    kf->start = 0;
    kf->end = 0;
}

LQ_TRACK *LQ_AddTrack(LQ_KEYFRAMER *kf, udword type)
{
    LQ_TRACK    *track, *next, *prev;

    if(!kf->tracks) {
        kf->tracks = (LQ_TRACK *)malloc(sizeof(LQ_TRACK));
        kf->tracks->keys    = NULL;
        kf->tracks->num_keys= 0;
        kf->tracks->prev    = NULL;
        kf->tracks->next    = NULL;
        kf->tracks->type    = type;
        kf->num_tracks      = 1;
        return kf->tracks;
    } else {
        track = kf->tracks;
        next = track->next;
        prev = NULL;
        while(next) {
            prev = track;
            track = next;
            next = track->next;
        }
        next            = (LQ_TRACK *)malloc(sizeof(LQ_TRACK));
        next->type      = type;
        next->keys      = NULL;
        next->num_keys  = 0;
        next->next      = NULL;
        next->prev      = track;
        track->next     = next;
        kf->num_tracks++;
        return next;           
    }
    return NULL;
}

LQ_KEY *LQ_AddKey(LQ_TRACK *track)
{
    LQ_KEY  *key, *next, *prev;

    if(!track->keys) {
        track->keys = (LQ_KEY *)malloc(sizeof(LQ_KEY));
        track->keys->next = NULL;
        track->keys->prev = NULL;
        track->num_keys=1;
        return track->keys;
    } else {
        key = track->keys;
        next = key->next;
        prev = NULL;
        while(next) {
            key = next;
            next = key->next;
            prev = key->prev;
        }
        next = (LQ_KEY *)malloc(sizeof(LQ_KEY));
        next->prev = key;
        key->next = next;
        next->next = NULL;
        track->num_keys++;
        return next;
    }
    return NULL;
}

void LQ_SetData(void *obj, udword otype, LQ_KDATA *data, udword type)
{
    LQ_CAMERA   *cam;
    LQ_TRIMESH  *tmesh;
    LQ_LIGHT    *light;

    switch(otype) {
        case LQ_CAMERA_OBJECT:
            cam = (LQ_CAMERA *)obj;
            switch(type) {
                case LQ_POSITION_TRACK:
                    cam->position.x = data->pos.x;
                    cam->position.y = data->pos.y;
                    cam->position.z = data->pos.z;
                    break;
                case LQ_TARGET_TRACK:
                    cam->target.x   = data->pos.x;
                    cam->target.y   = data->pos.y;
                    cam->target.z   = data->pos.z;
                    break;
            }
            break;

        case LQ_TRIMESH_OBJECT:
            tmesh = (LQ_TRIMESH *)obj;
            switch(type) {
                case LQ_POSITION_TRACK:
                    tmesh->trans.x = data->pos.x;
                    tmesh->trans.y = data->pos.y;
                    tmesh->trans.z = data->pos.z;
                    break;
                case LQ_ROTATION_TRACK:
                    LQ_QuatToMatrix(&data->rot, tmesh->mat);
                    break;
                    
                    
            }
            break;

        case LQ_LIGHT_OBJECT:
            light = (LQ_LIGHT *)obj;
            switch(type) {
                case LQ_POSITION_TRACK:
                    light->position.x = data->pos.x;
                    light->position.y = data->pos.y;
                    light->position.z = data->pos.z;
                    break;
                case LQ_TARGET_TRACK:
                    light->target.x = data->pos.x;
                    light->target.y = data->pos.y;
                    light->target.z = data->pos.z;
                    break;
            }
            break;

    }
}

void LQ_SetFrame(LQ_SCENE *scene, LQ_KEYFRAMER *kf, uint frame)
{
    int         i;
    float       t;
    LQ_TRACK    *track;
    LQ_KEY      *key, *nkey;
    LQ_KDATA    data;

    if(frame>=0 && frame<kf->frames) {
        track = kf->tracks;

        while(track) {
            key = track->keys;
            nkey = key->next;
            while(key) {

                
                // key is actual frame
                if(key->key_num==frame) {

                    LQ_SetData(track->obj, track->otype, &key->val, track->type);
                    goto done_key;

                } else {
                    if(nkey) {
                        if(key->key_num < frame && nkey->key_num > frame) {
                            t = ((float)frame - key->key_num) / (nkey->key_num - key->key_num);

                            LQ_SplineInterpolate(key, nkey, t, &data, track->type);
                            LQ_SetData(track->obj, track->otype, &data, track->type);

                            goto done_key;
                        }
                    }
                }

                key = nkey;
                nkey = key->next;
            }

done_key:   track = track->next;
        }
    }
}   

