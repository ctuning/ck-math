@echo off

rem
rem Extra installation script
rem
rem See CK LICENSE.txt for licensing details.
rem See CK Copyright.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
 -DOPENCL_ROOT="%CK_ENV_LIB_OPENCL%" ^
 -DOPENCL_LIBRARIES="%CK_ENV_LIB_OPENCL_LIB%\libOpenCL.so" ^
 -DOPENCL_INCLUDE_DIRS="%CK_ENV_LIB_OPENCL_INCLUDE%"

exit /b 0
