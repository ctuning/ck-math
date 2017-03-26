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

rem To avoid problem linking openCL lib ...

set CMAKE_C_FLAGS=%CMAKE_C_FLAGS% -L%CK_ENV_LIB_OPENCL_LIB%
set CMAKE_CXX_FLAGS=%CMAKE_CXX_FLAGS% -L%CK_ENV_LIB_OPENCL_LIB%

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
 -DOPENCL_ROOT:PATH="%CK_ENV_LIB_OPENCL%" ^
 -DOPENCL_LIBRARIES:FILEPATH=%CK_ENV_LIB_OPENCL_DYNAMIC_NAME% ^
 -DOPENCL_INCLUDE_DIRS:PATH="%CK_ENV_LIB_OPENCL_INCLUDE%" ^
 -DCMAKE_EXE_LINKER_FLAGS=-L%CK_ENV_LIB_OPENCL_LIB% ^
 -DTUNERS=ON ^
 -DCLTUNE_ROOT:PATH="%CK_ENV_TOOL_CLTUNE%" ^
 -DSAMPLES=ON ^
 -DANDROID=ON

exit /b 0
