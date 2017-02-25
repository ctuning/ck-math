@echo off

rem
rem Post-cloning installation script.
rem
rem See CK LICENSE.txt for licensing details.
rem See CK COPYRIGHT.txt for copyright details.
rem
rem Developer(s):
rem - Grigori Fursin, grigori.fursin@ctuning.org, 2016-2017.
rem - Anton Lokhmotov, anton@dividiti.com, 2017.
rem

rem Manually copy src/viennacl/ directory under install/include/.

if NOT EXIST %INSTALL_DIR%\include (

  mkdir %INSTALL_DIR%\install\include

  if %errorlevel% neq 0 (
    echo.
    echo Error: problem creating include directory!
    goto err
  )
)

echo **************************************************************
echo Copying headers to installation directory ...

xcopy /E %INSTALL_DIR%\src\viennacl\ %INSTALL_DIR%\install\include\

exit /b 0
