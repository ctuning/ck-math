@echo off

rem
rem Extra installation script
rem
rem See CK LICENSE.txt for licensing details.
rem See CK Copyright.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

rem  Check extra stuff

set EXTRA_FLAGS=
if "%CK_ARMEABI_V7A%" == "ON" (
  set EXTRA_FLAGS=%EXTRA_FLAGS% -DARMEABI_V7A=ON
)

if "%CK_ARMEABI_V7A_HARD%" == "ON" (
  set EXTRA_FLAGS=%EXTRA_FLAGS% -DARMEABI_V7A_HARD=ON
)

set TOOLCHAIN=gcc
if NOT "%CK_COMPILER_TOOLCHAIN_NAME%" == "" (
  set TOOLCHAIN=%CK_COMPILER_TOOLCHAIN_NAME%
)

rem ############################################################
cd /D %INSTALL_DIR%\%PACKAGE_SUB_DIR1%

call bootstrap.bat

if %errorlevel% neq 0 (
  echo.
  echo Error: bootstrap failed!
  exit /b 1
)

rem ############################################################
echo.
echo Building (can be very long) ...

if EXIST %INSTALL_DIR%\install (
   rmdir /s /q %INSTALL_DIR%\install
)
if EXIST %INSTALL_DIR%\install (
  rmdir %INSTALL_DIR%\install
)

mkdir %INSTALL_DIR%\install

set BOOST_BUILD_PATH=%INSTALL_DIR%\install
call ck convert_to_cygwin_path os --path="using %TOOLCHAIN% : arm : %CK_CXX_PATH_FOR_CMAKE% %CK_CXX_FLAGS_FOR_CMAKE% %CK_CXX_FLAGS_ANDROID_TYPICAL% %EXTRA_FLAGS% -DNO_BZIP2 : <flavor>mingw ;" > %BOOST_BUILD_PATH%\user-config.jam

b2 install toolset=%TOOLCHAIN%-arm target-os=android threadapi=pthread --layout=system link=static --without-mpi --without-context --without-math address-model=%CK_TARGET_CPU_BITS% --prefix=%BOOST_BUILD_PATH% --without-python --debug-configuration
rem b2 install toolset=%TOOLCHAIN%-arm target-os=android --layout=system link=static --without-mpi --without-context --without-math address-model=%CK_TARGET_CPU_BITS% --prefix=%BOOST_BUILD_PATH% --without-python --debug-configuration

rem if %errorlevel% neq 0 (
rem   echo.
rem   echo Error: b2 failed!
rem   exit /b 1
rem )

exit /b 0
