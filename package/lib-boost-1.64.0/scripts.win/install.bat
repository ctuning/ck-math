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

rem ############################################################
cd /D %INSTALL_DIR%\%PACKAGE_SUB_DIR1%

call bootstrap.bat msvc

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

set TOOLCHAIN=msvc
if NOT "%CK_COMPILER_TOOLCHAIN_NAME%" == "" (
  set TOOLCHAIN=%CK_COMPILER_TOOLCHAIN_NAME%
)

set BOOST_BUILD_PATH=%INSTALL_DIR%\install
echo using %TOOLCHAIN% : : %CK_CXX% %CK_CXX_FLAGS_FOR_CMAKE% %EXTRA_FLAGS% -DNO_BZIP2 ; > %BOOST_BUILD_PATH%\user-config.jam

b2 install -a toolset=%TOOLCHAIN% link=shared --layout=tagged runtime-link=shared threading=multi address-model=%CK_TARGET_CPU_BITS% --prefix=%BOOST_BUILD_PATH%

if %errorlevel% neq 0 (
  echo.
  echo Error: b2 failed!
  exit /b 1
)

exit /b 0
