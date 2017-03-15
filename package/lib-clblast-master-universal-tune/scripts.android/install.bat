@echo off

rem
rem Installation script.
rem
rem See CK LICENSE.txt for licensing details.
rem See CK COPYRIGHT.txt for copyright details.
rem
rem Developer(s):
rem - Grigori Fursin, grigori@dividiti.com, 2016-2017
rem - Anton Lokhmotov, anton@dividiti.com, 2017
rem

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
 -DOPENCL_ROOT="%CK_ENV_LIB_OPENCL%" ^
 -DOPENCL_LIBRARIES="%CK_ENV_LIB_OPENCL_LIB%\libOpenCL.so" ^
 -DOPENCL_INCLUDE_DIRS="%CK_ENV_LIB_OPENCL_INCLUDE%" ^
 -DTUNERS -DCLTUNE_ROOT="%CK_ENV_TOOL_CLTUNE%" ^
 -DSAMPLES=ON ^
 -DANDROID=ON"

exit /b 0
