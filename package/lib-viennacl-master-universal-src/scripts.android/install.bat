@echo off

rem
rem Installation script.
rem
rem See CK LICENSE.txt for licensing details.
rem See CK COPYRIGHT.txt for copyright details.
rem
rem Developer(s):
rem - Grigori Fursin, grigori.fursin@ctuning.org, 2016-2017.
rem

rem Check extra stuff.

rem if "%CK_TARGET_OS_ID%" == "android" (

cd %INSTALL_DIR%\%PACKAGE_SUB_DIR%

patch -p1 < %ORIGINAL_PACKAGE_DIR%\scripts.android\patch-host-win

rem )

exit /b 0
