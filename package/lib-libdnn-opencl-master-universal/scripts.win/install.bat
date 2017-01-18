@echo off

rem
rem Installation script for CK packages.
rem
rem See CK LICENSE.txt for licensing details.
rem See CK Copyright.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

rem PACKAGE_DIR
rem INSTALL_DIR

echo **************************************************************
echo Preparing vars for ViennaCL ...

rem set CK_OPENMP=1
rem if "%CK_HAS_OPENMP%" == "0" (
rem   set CK_OPENMP=0
rem )

rem FGG had problems with OpenMP on Windows
set CK_OPENMP=0

set CK_CXX_FLAGS_FOR_CMAKE=
set CK_CXX_FLAGS_ANDROID_TYPICAL=

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
 -DOPENCL_ROOT="%CK_ENV_LIB_OPENCL%" ^
 -DOPENCL_LIBRARY="%CK_ENV_LIB_OPENCL_LIB%\OpenCL.lib" ^
 -DOPENCL_LIBRARIES="%CK_ENV_LIB_OPENCL_LIB%\OpenCL.lib" ^
 -DOPENCL_INCLUDE_DIRS="%CK_ENV_LIB_OPENCL_INCLUDE%" ^
 -DVIENNACL_HOME="%CK_ENV_LIB_VIENNACL%" ^
 -DVIENNACL_INCLUDE_DIR="%CK_ENV_LIB_VIENNACL_INCLUDE%"

rem  -DINCLUDE_INSTALL_DIR=%INSTALL_DIR%\install\include\greentea ^
rem -DPACKAGE_INSTALL_DIR=%INSTALL_DIR%\install\greentea ^
rem  -DLIB_INSTALL_DIR=%INSTALL_DIR%\lib

rem  -DBOOSTPATH=%CK_ENV_LIB_BOOST% ^
rem  -DBoost_ADDITIONAL_VERSIONS="1.62" ^

rem -DOPENCL_ROOT="%CK_ENV_LIB_OPENCL%" ^
rem -DOPENCL_LIBRARIES="%CK_ENV_LIB_OPENCL_LIB%/libOpenCL.so" ^
rem -DOPENCL_INCLUDE_DIRS="%CK_ENV_LIB_OPENCL_INCLUDE%"

exit /b 0
