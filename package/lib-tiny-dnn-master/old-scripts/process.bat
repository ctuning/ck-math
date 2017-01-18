@echo off

rem
rem Installation script for CK packages.
rem
rem See CK LICENSE for licensing details.
rem See CK Copyright for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016
rem

rem PACKAGE_DIR
rem INSTALL_DIR

echo.
echo Cloning Package from GitHub ...

git clone %PACKAGE_URL% %INSTALL_DIR%/src

echo.
echo Updating Package from GitHub ...

cd /D %INSTALL_DIR%\src
git pull

:err
exit /b 0
