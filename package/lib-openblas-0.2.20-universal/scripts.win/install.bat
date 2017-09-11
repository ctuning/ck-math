@echo off

rem
rem Extra installation script
rem
rem See CK LICENSE.txt for licensing details.
rem See CK COPYRIGHT.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

rem ############################################################
echo.
echo Preparing vars ...

rem Check make

where make.exe
if %errorlevel% == 0 (
   set CK_CUR_MAKE=make
)

where mingw64-make.exe
if %errorlevel% == 0 (
   set CK_CUR_MAKE=mingw64-make
)

where mingw32-make.exe
if %errorlevel% == 0 (
   set CK_CUR_MAKE=mingw32-make
)

if "%CK_CUR_MAKE%" == "" (
   echo.
   echo Error: can't detect make!
   goto err
)

set EXTRA1=
if not "%OPENBLAS_TARGET%" == "" (
  set EXTRA1=TARGET=%OPENBLAS_TARGET%
)

set EXTRA2=NOFORTRAN=1
if "%OPENBLAS_FORTRAN%" == "YES" (
  set EXTRA2=
)

set EXTRA3=NOLAPACK=1
if "%OPENBLAS_LAPACK%" == "YES" (
  set EXTRA3=
)

cd %INSTALL_DIR%\%PACKAGE_SUB_DIR%

rem mingw32-make PREFIX="%INSTALL_DIR%\install" BINARY=%CK_TARGET_CPU_BITS% ONLY_CBLAS=1 MAKE=mingw32-make.exe CFLAGS="-DMS_ABI" NOFORTRAN=1 NO_LAPACK=1
%CK_CUR_MAKE% PREFIX="%INSTALL_DIR%\install" BINARY=%CK_TARGET_CPU_BITS% CC=gcc FC=gfortran %EXTRA1% %EXTRA2% %EXTRA3%

if %errorlevel% neq 0 (
 echo.
 echo Error: make failed!
 goto err
)

rem mingw32-make install PREFIX="%INSTALL_DIR%\install" 
%CK_CUR_MAKE% install PREFIX="%INSTALL_DIR%\install" 

if %errorlevel% neq 0 (
 echo.
 echo Error: make install failed!
 goto err
)

exit /b 0
