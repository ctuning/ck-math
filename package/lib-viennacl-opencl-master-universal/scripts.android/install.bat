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

rem if "%CK_TARGET_OS_ID%" == "android" (

set CK_OPENMP=1
if "%CK_HAS_OPENMP%" == "0" (
  set CK_OPENMP=0
)

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
 -DENABLE_OPENCL=%CK_INSTALL_ENABLE_OPENCL% ^
 -DOPENCL_LIBRARY=%CK_ENV_LIB_OPENCL_LIB%\libOpenCL.so ^
 -DOPENCL_INCLUDE_DIRS=%CK_ENV_LIB_OPENCL_INCLUDE% ^
 -DENABLE_OPENMP=%CK_OPENMP% ^
 -DBOOSTPATH=%CK_ENV_LIB_BOOST%

cd %INSTALL_DIR%\%PACKAGE_SUB_DIR%

patch -p1 < %ORIGINAL_PACKAGE_DIR%\scripts.android\patch-host-win

rem )

exit /b 0
