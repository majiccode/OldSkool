@echo off
cls
rem Compile assembly files
If %1. == . goto usage
tasm %1  /M3
tlink %1 
del *.map
del *.obj
goto end
:usage
cls
echo Usage: C source file
:end