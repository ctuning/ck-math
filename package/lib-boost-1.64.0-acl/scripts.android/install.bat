@echo off

rem
rem Extra installation script
rem
rem See CK LICENSE.txt for licensing details.
rem See CK COPYRIGHT.txt for copyright details.
rem
rem Developer(s):
rem - Grigori Fursin, 2016-2017
rem - Anton Lokhmotov, 2017
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

call bootstrap.bat gcc

if %errorlevel% neq 0 (
  echo.
  echo Error: bootstrap failed!
  exit /b 1
)

rem ############################################################
echo.
echo Building Boost (can take a long time) ...

if EXIST %INSTALL_DIR%\install (
   rmdir /s /q %INSTALL_DIR%\install
)
if EXIST %INSTALL_DIR%\install (
  rmdir %INSTALL_DIR%\install
)

mkdir %INSTALL_DIR%\install

rem ############################################################
echo.
echo Preparing customized config via CK ...

set BOOST_BUILD_PATH=%INSTALL_DIR%\install
call python %ORIGINAL_PACKAGE_DIR%/scripts.android/convert_to_cygwin_path.py "using %TOOLCHAIN% : arm : %CK_CXX_PATH_FOR_CMAKE% %CK_CXX_FLAGS_FOR_CMAKE% %CK_CXX_FLAGS_ANDROID_TYPICAL% %EXTRA_FLAGS% -DNO_BZIP2 : <flavor>mingw <archiver>%CK_ENV_COMPILER_GCC_BIN%\%CK_AR% <ranlib>%CK_ENV_COMPILER_GCC_BIN%\%CK_RANLIB% ;" > %BOOST_BUILD_PATH%\user-config.jam

if %errorlevel% neq 0 (
  echo.
  echo Error: ck execution failed!
  exit /b 1
)

rem FIXME: compared with install.sh, the following options are extra in this install.bat:
rem '--without-context --without-math --without-python --debug-configuration' (debug?!).
rem The same is the case in 'package:lib-boost-1.62.0' and 'package:lib-boost-1.64.0'.
b2 install address-model=%CK_TARGET_CPU_BITS% target-os=android toolset=%TOOLCHAIN%-arm link=static define=BOOST_TEST_ALTERNATIVE_INIT_API threadapi=pthread --layout=system --with-program_options --with-test --without-mpi --without-context --without-math --without-python --debug-configuration --prefix=%BOOST_BUILD_PATH%

rem b2 install toolset=%TOOLCHAIN%-arm target-os=android --layout=system link=static --without-mpi --without-context --without-math address-model=%CK_TARGET_CPU_BITS% --prefix=%BOOST_BUILD_PATH% --without-python --debug-configuration

rem if %errorlevel% neq 0 (
rem   echo.
rem   echo Error: b2 failed!
rem   exit /b 1
rem )

exit /b 0
