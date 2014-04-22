@echo off
cls
echo                          X-COPY PC v3.01 Installation
echo                       (c)1995 Matrix Design, Paul Adams
echo                              BETA TEST VERSION
echo.

if %1.==. goto error
if %2.==. goto error

echo.
echo.
echo.
echo Creating Directory \XCOPY
echo.
%2:
cd\
md XCOPY            
cd\xcopy
echo Now Coping All Files From Distribution Disk!
echo Please Wait...
echo.
copy %1\*.* >nul
echo.
%2:
cd\xcopy
echo Now type XCOPY to run this program
goto end

:error
echo.
echo.
echo *** ERROR ***
echo.
echo To run this installation type INSTALL A: C:
echo where A: is the source drive
echo       C: is the destination drive
echo.
echo.
echo Now try again!
echo.
echo.
echo.
:end
