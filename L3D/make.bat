@echo off
cls
wcc386 -fpi87 -fp5 -mf test

wlink system pmodew file test,scene,trimesh,camera,matvec,3ds,keyframe,render,clip,raster,light  name test
