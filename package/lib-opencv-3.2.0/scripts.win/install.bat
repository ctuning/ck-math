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

set CK_CC_FLAGS_FOR_CMAKE=%CK_CC_FLAGS_FOR_CMAKE% /DWIN32
set CK_CXX_FLAGS_FOR_CMAKE=%CK_CXX_FLAGS_FOR_CMAKE% /DWIN32

exit /b 0
