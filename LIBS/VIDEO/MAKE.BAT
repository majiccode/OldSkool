@echo off
cls
call c vesa
wcc386 -fpi87 -fp5 -mf -d3 example
wlink debug all file example,vesa name example


