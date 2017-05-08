@echo off

rem *******************************************************************************************************************************

mkdir ..\install
mkdir ..\install\lib
mkdir ..\install\include

mkdir obj
cd obj

rem *******************************************************************************************************************************

echo.
echo Building static library ...
echo.

set CK_TARGET_FILE=%CK_TARGET_LIB%%CK_LIB_EXT%
del /q %CK_TARGET_FILE%

echo %CK_CXX% %CK_COMPILER_FLAGS_OBLIGATORY% %CK_FLAGS_STATIC_LIB% %CK_FLAGS_CREATE_OBJ% %CK_CXXFLAGS% %CK_SRC_FILES% %CK_FLAG_PREFIX_INCLUDE%..
echo.

%CK_CXX% %CK_COMPILER_FLAGS_OBLIGATORY% %CK_FLAGS_STATIC_LIB% %CK_FLAGS_CREATE_OBJ% %CK_CXXFLAGS% %CK_SRC_FILES% %CK_FLAG_PREFIX_INCLUDE%..
if %errorlevel% neq 0 (
 echo.
 echo Building failed!
 exit /b 1
)

echo %CK_LB% %CK_LB_OUTPUT%%CK_TARGET_FILE% %CK_OBJ_FILES%
echo.

%CK_LB% %CK_LB_OUTPUT%%CK_TARGET_FILE% %CK_OBJ_FILES%
if %errorlevel% neq 0 (
 echo.
 echo Building static library failed!
 exit /b 1
)

copy /b %CK_TARGET_FILE% ..\..\install\lib
if %errorlevel% neq 0 (
 echo.
 echo Copying static library failed!
 exit /b 1
)

rem *******************************************************************************************************************************

set CK_TARGET_FILE_D=%CK_TARGET_LIB%%CK_DLL_EXT%
if not "%CK_BARE_METAL%" == "on" (

   echo.
   echo Building dynamic library ...
   echo.

   del /q %CK_TARGET_FILE_D%

   echo %CK_CXX% %CK_COMPILER_FLAGS_OBLIGATORY% %CK_FLAGS_DLL% %CK_CXXFLAGS% %CK_SRC_FILES% %CK_FLAG_PREFIX_INCLUDE%.. %CK_FLAGS_OUTPUT%%CK_TARGET_FILE_D% %CK_FLAGS_DLL_EXTRA% %CK_LD_FLAGS_MISC% %CK_LD_FLAGS_EXTRA% %CK_LFLAGS%
   %CK_CXX% %CK_COMPILER_FLAGS_OBLIGATORY% %CK_FLAGS_DLL% %CK_CXXFLAGS% %CK_SRC_FILES% %CK_FLAG_PREFIX_INCLUDE%.. %CK_FLAGS_OUTPUT%%CK_TARGET_FILE_D% %CK_FLAGS_DLL_EXTRA% %CK_LD_FLAGS_MISC% %CK_LD_FLAGS_EXTRA% %CK_LFLAGS%
   if %errorlevel% neq 0 (
    echo.
    echo Building dynamic library failed!
    exit /b 1
   )

   copy /b %CK_TARGET_FILE_D% ..\..\install\lib
   if %errorlevel% neq 0 (
    echo.
    echo Copying dynamic library failed!
    exit /b 1
   )
)

rem *******************************************************************************************************************************

echo.
echo Copying include files ...
echo.

cd ..
xcopy arm_compute ..\install\include\arm_compute /e /c /i /y
xcopy test_helpers ..\install\include\test_helpers /e /c /i /y

exit /b 0
