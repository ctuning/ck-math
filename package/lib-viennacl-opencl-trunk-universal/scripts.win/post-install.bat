@echo off

rem
rem Installation script for CK packages.
rem
rem See CK LICENSE.txt for licensing details.
rem See CK Copyright.txt for copyright details.
rem
rem Developer(s): Grigori Fursin, 2016-2017
rem

rem Wierdly, ViennaCL doesn't copy produced libs
rem to a correct location, so doing it manually

if NOT EXIST %INSTALL_DIR%\lib (

  mkdir %INSTALL_DIR%\install\lib

  if %errorlevel% neq 0 (
    echo.
    echo Error: problem creating lib directory!
    goto err
  )
)

echo **************************************************************
echo Copying libraries to proper directory ...

xcopy /E %INSTALL_DIR%\obj\libviennacl\Release\* %INSTALL_DIR%\install\lib

exit /b 0
