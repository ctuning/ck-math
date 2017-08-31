@echo off

rem *******************************************************************************************************************************

mkdir "%INSTALL_DIR%\src\obj"
cd "%INSTALL_DIR%\src\obj"

"%CK_MAKE%" -j %CK_HOST_CPU_NUMBER_OF_PROCESSORS% -f "%ORIGINAL_PACKAGE_DIR%\Makefile" %*
set code=%errorlevel%

cd "%INSTALL_DIR%"

exit /b %code%
