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

set NO_LAPACK=1

if "%CK_ANDROID_ABI%" == "arm64-v8a" (
  set NO_LAPACK=1
  set TARGET=ARMV8
) else if "%CK_ANDROID_ABI%" == "armeabi" (
  set NO_LAPACK=1
  set TARGET=ARMV5
) else if "%CK_ANDROID_ABI%" == "armeabi-v7a" (
  rem  ARMV7 can be used only with hardfp and neon - see later
  set NO_LAPACK=1
  set TARGET=ARMV5
) else if "%CK_ANDROID_ABI%" == "x86" (
  set NO_LAPACK=1
  set TARGET=ATOM
) else if "%CK_ANDROID_ABI%" == "x86_64" (
  set NO_LAPACK=1
  set TARGET=ATOM
) else (
  echo Error: %CK_ANDROID_ABI% is not supported!
  exit /b 1
)

set CK_OPENMP=1
if "%CK_HAS_OPENMP%" == "0" (
  set CK_OPENMP=0
)

set EXTRA_FLAGS=

if "%CK_CPU_ARM_NEON%" == "ON" (
  set EXTRA_FLAGS= %EXTRA_FLAGS% -mfpu=neon
  set TARGET=ARMV7
)

if "%CK_CPU_ARM_VFPV3%" == "ON" (
  set EXTRA_FLAGS= %EXTRA_FLAGS% -mfpu=vfpv3
  set TARGET=ARMV7
)

cd %INSTALL_DIR%\%PACKAGE_SUB_DIR%

patch -p1 < %ORIGINAL_PACKAGE_DIR%\scripts.android\patch-host-win

make VERBOSE=1 -j%CK_HOST_CPU_NUMBER_OF_PROCESSORS% ^
     HOSTCC=gcc ^
     CC="%CK_CC%" ^
     CFLAGS="%CK_COMPILER_FLAGS_OBLIGATORY% %CK_CC_FLAGS_ANDROID_TYPICAL% %EXTRA_FLAGS%" ^
     AR="%CK_AR%" ^
     NOFORTRAN=1 ^
     CROSS_SUFFIX=%CK_ENV_COMPILER_GCC_BIN%\%CK_COMPILER_PREFIX% ^
     USE_THREAD=1 ^
     NUM_THREADS=8 ^
     USE_OPENMP=%CK_OPENMP% ^
     NO_LAPACK=%NO_LAPACK% ^
     TARGET=%TARGET% ^
     BINARY=%CK_TARGET_CPU_BITS% ^
     CK_COMPILE=ON

if %errorlevel% neq 0 (
 echo.
 echo Error: make failed!
 exit /b 1
)

rem ############################################################
echo.
echo Installing package ...

make install PREFIX="%INSTALL_DIR%\install" 

if %errorlevel% neq 0 (
 echo.
 echo Error: make install failed!
 exit /b 1
)

exit /b 0
