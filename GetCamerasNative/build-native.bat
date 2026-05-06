@echo off
setlocal enabledelayedexpansion

REM Build script for native C++ DLL using Visual Studio compiler
REM Automatically finds and sets up Visual Studio environment

echo ========================================
echo Building GetCamerasNative.dll
echo ========================================
echo.

REM Check if cl.exe is already in PATH
where cl.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Visual Studio C++ compiler found in PATH
    goto :build
)

echo Searching for Visual Studio installation...
echo.

REM Try to find Visual Studio using vswhere
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

if exist "%VSWHERE%" (
    echo Found vswhere.exe, locating Visual Studio...

    REM Get Visual Studio installation path
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
        set "VSINSTALLDIR=%%i"
    )

    if defined VSINSTALLDIR (
        echo Found Visual Studio at: !VSINSTALLDIR!
        echo.

        REM Try to find MSVC version
        for /f %%v in ('dir /b "!VSINSTALLDIR!\VC\Tools\MSVC" 2^>nul') do (
            set "MSVCVER=%%v"
        )

        if defined MSVCVER (
            echo Found MSVC version: !MSVCVER!

            REM Set up environment manually
            set "VCINSTALLDIR=!VSINSTALLDIR!\VC"
            set "MSVCDIR=!VCINSTALLDIR!\Tools\MSVC\!MSVCVER!"
            set "PATH=!MSVCDIR!\bin\Hostx64\x64;!PATH!"
            set "INCLUDE=!MSVCDIR!\include;!VSINSTALLDIR!\SDK\ScopeCppSDK\sdk\include;!INCLUDE!"
            set "LIB=!MSVCDIR!\lib\x64;!VSINSTALLDIR!\SDK\ScopeCppSDK\vc15\SDK\lib;!LIB!"

            REM Find Windows SDK
            for /f %%k in ('dir /b "C:\Program Files (x86)\Windows Kits\10\Include" 2^>nul ^| findstr /r "10\.0\."') do (
                set "WINSDK=%%k"
            )

            if defined WINSDK (
                echo Found Windows SDK: !WINSDK!
                set "INCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\!WINSDK!\ucrt;!INCLUDE!"
                set "INCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\!WINSDK!\um;!INCLUDE!"
                set "INCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\!WINSDK!\shared;!INCLUDE!"
                set "LIB=C:\Program Files (x86)\Windows Kits\10\Lib\!WINSDK!\ucrt\x64;!LIB!"
                set "LIB=C:\Program Files (x86)\Windows Kits\10\Lib\!WINSDK!\um\x64;!LIB!"
            )

            REM Verify cl.exe is now available
            where cl.exe >nul 2>&1
            if !errorlevel! equ 0 (
                echo.
                echo ✅ Build environment configured successfully!
                echo.
                goto :build
            )
        )
    )
)

REM If we get here, manual setup failed, try vcvars64.bat
echo Trying vcvars64.bat approach...
echo.

set "VCVARS64="

REM Try Visual Studio 2026
if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VCVARS64=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
)

REM Try Visual Studio 2022
if not defined VCVARS64 (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        set "VCVARS64=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    )
)

if defined VCVARS64 (
    echo Found vcvars64.bat at: !VCVARS64!
    echo Calling vcvars64.bat...
    echo.
    call "!VCVARS64!"

    where cl.exe >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ Environment configured via vcvars64.bat
        echo.
        goto :build
    )
)

REM If we get here, nothing worked
echo ========================================
echo ERROR: Cannot configure build environment!
echo ========================================
echo.
echo C++ build tools are installed but cannot be configured.
echo.
echo MANUAL SOLUTION:
echo   1. Open "x64 Native Tools Command Prompt for VS 2026"
echo      (Search in Start Menu)
echo   2. Navigate to this directory:
echo      cd /d "%~dp0"
echo   3. Run this command:
echo      cl.exe /LD /EHsc /O2 /W3 /D_USRDLL /D_WINDLL GetCamerasNative.cpp /link ole32.lib oleaut32.lib strmiids.lib /OUT:GetCamerasNative.dll
echo.
pause
exit /b 1

:build
echo ========================================
echo Building 64-bit DLL...
echo ========================================
echo.

REM Clean previous build
if exist GetCamerasNative.dll del GetCamerasNative.dll >nul 2>&1
if exist GetCamerasNative.obj del GetCamerasNative.obj >nul 2>&1
if exist GetCamerasNative.lib del GetCamerasNative.lib >nul 2>&1
if exist GetCamerasNative.exp del GetCamerasNative.exp >nul 2>&1

REM Compile and link
cl.exe /LD /EHsc /O2 /W3 /D_USRDLL /D_WINDLL ^
    GetCamerasNative.cpp ^
    /link ole32.lib oleaut32.lib strmiids.lib ^
    /OUT:GetCamerasNative.dll

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Output: GetCamerasNative.dll
    echo.

    REM Show file info
    if exist GetCamerasNative.dll (
        for %%F in (GetCamerasNative.dll) do (
            set size=%%~zF
            set /a sizekb=!size!/1024
            echo File: GetCamerasNative.dll
            echo Size: !sizekb! KB
        )
    )

    echo.
    echo ✅ This DLL can be called from Java using JNA!
    echo    See JavaExample.java for usage.
    echo.
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Common issues:
    echo   - Missing libraries (ole32.lib, oleaut32.lib, strmiids.lib)
    echo   - Windows SDK not properly installed
    echo   - Syntax errors in source code
    echo.
    echo TRY THIS:
    echo   Open "x64 Native Tools Command Prompt for VS 2026"
    echo   and run this script again from there.
    echo.
)

pause
endlocal
