@echo off

rem *******************************************************************************************************************************

mkdir "%INSTALL_DIR%\src\obj"
cd "%INSTALL_DIR%\src\obj"

"%CK_MAKE%" -j %CK_HOST_CPU_NUMBER_OF_PROCESSORS% -f "%ORIGINAL_PACKAGE_DIR%\Makefile" %*
set code=%errorlevel%

if %code% equ 0 (
    cd ..
    xcopy arm_compute ..\install\include\arm_compute /e /c /i /y
    xcopy tests ..\install\include\arm_compute\tests /e /c /i /y
)

cd "%INSTALL_DIR%"

exit /b %code%
