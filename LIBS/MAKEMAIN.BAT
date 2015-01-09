@echo off
cls
del main.lib
wlib main +p:\libs\c\memory.obj
wlib main +p:\libs\c\dpmi.obj
wlib main +p:\libs\asm\control.obj
wlib main +p:\libs\c\vesa.obj


