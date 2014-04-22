@echo off
cls
wcc386 -fpi87 -fp5 -mf scene
wcc386 -fpi87 -fp5 -mf trimesh
wcc386 -fpi87 -fp5 -mf camera
wcc386 -fpi87 -fp5 -mf matvec
wcc386 -fpi87 -fp5 -mf 3ds
wcc386 -fpi87 -fp5 -mf keyframe
wcc386 -fpi87 -fp5 -mf render
wcc386 -fpi87 -fp5 -mf clip
wcc386 -fpi87 -fp5 -mf raster
wcc386 -fpi87 -fp5 -mf light

wcc386 -fpi87 -fp5 -mf test

wlink system pmodew file test,scene,trimesh,camera,matvec,3ds,keyframe,render,clip,raster,light  name test

