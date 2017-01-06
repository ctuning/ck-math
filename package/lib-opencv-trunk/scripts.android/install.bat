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

if "%CK_ARMEABI_V7A%" == "ON" (
  set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% -DARMEABI_V7A=ON
)

if "%CK_ARMEABI_V7A_HARD%" == "ON" (
  set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% -DARMEABI_V7A_HARD=ON
)

set CK_CMAKE_EXTRA=%CK_CMAKE_EXTRA% ^
  -DANDROID=ON ^
  -DANDROID_NDK="%CK_ANDROID_NDK_ROOT_DIR%" ^
  -DANDROID_ABI="%CK_ANDROID_ABI%" ^
  -DENABLE_NEON=%CK_CPU_ARM_NEON% ^
  -DENABLE_VFPV3=%CK_CPU_ARM_VFPV3% ^
  -DANDROID_STL="gnustl_static" ^
  -DANDROID_NATIVE_API_LEVEL=%CK_ANDROID_API_LEVEL% ^
  -DANDROID_NDK_ABI_NAME=%CK_ANDROID_ABI% ^
  -DCMAKE_SYSTEM_NAME="Android" ^
  -DCMAKE_SYSTEM_VERSION="1" ^
  -DCMAKE_SYSTEM_PROCESSOR="%CK_CMAKE_SYSTEM_PROCESSOR%" ^
  -DCMAKE_CROSSCOMPILING="TRUE"

rem   -DCMAKE_SYSTEM="%CK_ANDROID_NDK_PLATFORM%" ^ - some fails on Windows targeting Android

rem )

exit /b 0
