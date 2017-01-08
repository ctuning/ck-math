@echo off

rem
rem Extra installation script
rem
rem See CK LICENSE.txt for licensing details.
rem See CK Copyright.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

rem ############################################################
echo.
echo Preparing vars ...

cd %INSTALL_DIR%\%PACKAGE_SUB_DIR%

mingw32-make PREFIX="%INSTALL_DIR%\install" BINARY=%CK_TARGET_CPU_BITS% ONLY_CBLAS=1 MAKE=mingw32-make.exe CFLAGS="-DMS_ABI" NOFORTRAN=1 NO_LAPACK=1

if %errorlevel% neq 0 (
 echo.
 echo Error: make failed!
 goto err
)

mingw32-make install PREFIX="%INSTALL_DIR%\install" 

if %errorlevel% neq 0 (
 echo.
 echo Error: make install failed!
 goto err
)

exit /b 0
