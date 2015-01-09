@echo off
echo test 3d engine (c) paul adams
IF %1.==. GOTO err
dos4gw.exe test.exe %1
goto done

:err
echo please specify 3DS file to load...
echo    usage: runme <file.3ds>


:done