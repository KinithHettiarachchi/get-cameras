@echo off
REM Build script for GetCameras single executable

echo ========================================
echo Building GetCameras Self-Contained EXE
echo ========================================
echo.

echo Cleaning previous builds...
dotnet clean -c Release
echo.

echo Publishing self-contained executable...
dotnet publish -c Release -r win-x64
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Executable location:
    echo bin\Release\net10.0-windows\win-x64\publish\GetCameras.exe
    echo.
    echo File size:
    powershell -Command "Get-ChildItem 'bin\Release\net10.0-windows\win-x64\publish\GetCameras.exe' | Select-Object Name, @{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}}"
    echo.
    echo You can now copy GetCameras.exe to any Windows x64 machine!
    echo No .NET installation required on target machine.
    echo.
) else (
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo Please check error messages above.
)

pause
