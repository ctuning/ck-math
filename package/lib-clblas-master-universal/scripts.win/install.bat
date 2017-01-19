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
 -DBoost_ADDITIONAL_VERSIONS="1.62" ^
 -DBoost_NO_SYSTEM_PATHS=ON ^
 -DBOOST_ROOT="%CK_ENV_LIB_BOOST%" ^
 -DBOOST_INCLUDEDIR="%CK_ENV_LIB_BOOST_INCLUDE%" ^
 -DBOOST_LIBRARYDIR="%CK_ENV_LIB_BOOST_LIB%" ^
 -DBoost_INCLUDE_DIR="%CK_ENV_LIB_BOOST_INCLUDE%" ^
 -DBoost_LIBRARY_DIR="%CK_ENV_LIB_BOOST_LIB%" ^
 -DCMAKE_C_COMPILER="%CK_CC_PATH_FOR_CMAKE%" ^
 -DCMAKE_CXX_COMPILER="%CK_CXX_PATH_FOR_CMAKE%" ^
 -DCMAKE_C_FLAGS="%CK_CXX_FLAGS_FOR_CMAKE%" ^
 -DCMAKE_CXX_FLAGS="%CK_CXX_FLAGS_FOR_CMAKE%" ^
 -DOPENCL_ROOT="%CK_ENV_LIB_OPENCL%"

exit /b 0
