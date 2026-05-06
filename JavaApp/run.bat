@echo off
REM Run script for Camera List App

echo ========================================
echo Running Camera List App
echo ========================================
echo.

REM Check for Maven build
if exist "target\camera-list-app-1.0.0-jar-with-dependencies.jar" (
    echo Running Maven-built JAR...
    echo.

    REM Copy DLL if not already in target directory
    if not exist "target\GetCamerasNative.dll" (
        if exist "..\GetCamerasNative\GetCamerasNative.dll" (
            echo Copying GetCamerasNative.dll...
            copy "..\GetCamerasNative\GetCamerasNative.dll" "target\" >nul
        )
    )

    cd target
    java -jar camera-list-app-1.0.0-jar-with-dependencies.jar
    cd ..
    goto :end
)

REM Check for Gradle build
if exist "build\libs\camera-list-app-1.0.0.jar" (
    echo Running Gradle-built JAR...
    echo.

    REM Copy DLL if not already in build\libs directory
    if not exist "build\libs\GetCamerasNative.dll" (
        if exist "..\GetCamerasNative\GetCamerasNative.dll" (
            echo Copying GetCamerasNative.dll...
            copy "..\GetCamerasNative\GetCamerasNative.dll" "build\libs\" >nul
        )
    )

    cd build\libs
    java -jar camera-list-app-1.0.0.jar
    cd ..\..
    goto :end
)

REM Check for manual compilation
if exist "CameraListApp.class" (
    echo Running manually compiled app...
    echo.

    REM Copy DLL if not already in current directory
    if not exist "GetCamerasNative.dll" (
        if exist "..\GetCamerasNative\GetCamerasNative.dll" (
            echo Copying GetCamerasNative.dll...
            copy "..\GetCamerasNative\GetCamerasNative.dll" . >nul
        )
    )

    if exist "jna-5.13.0.jar" (
        java -cp .;jna-5.13.0.jar CameraListApp
    ) else (
        echo ERROR: jna-5.13.0.jar not found!
        echo Please run build.bat first.
    )
    goto :end
)

REM Nothing built
echo ERROR: No built artifacts found!
echo.
echo Please run build.bat first to compile the application.
echo.
pause
exit /b 1

:end
echo.
pause
