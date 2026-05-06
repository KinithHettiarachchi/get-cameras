@echo off
REM Build script for Camera List App

echo ========================================
echo Building Camera List App
echo ========================================
echo.

REM Check if Maven is available
where mvn >nul 2>&1
if %errorlevel% equ 0 (
    echo Found Maven, building with Maven...
    echo.

    REM Ensure Maven directory structure exists
    if not exist "src\main\java" (
        echo Creating Maven directory structure...
        mkdir src\main\java
        copy CameraListApp.java src\main\java\ >nul 2>&1
    )

    call mvn clean package

    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo BUILD SUCCESSFUL!
        echo ========================================
        echo.
        echo Standalone JAR created:
        echo   target\camera-list-app-1.0.0-jar-with-dependencies.jar
        echo.
        echo To run:
        echo   java -jar target\camera-list-app-1.0.0-jar-with-dependencies.jar
        echo.
        echo Or use: run.bat
        echo.
    ) else (
        echo Build failed!
    )
    goto :end
)

REM Check if Gradle is available
where gradle >nul 2>&1
if %errorlevel% equ 0 (
    echo Found Gradle, building with Gradle...
    echo.
    call gradle build

    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo BUILD SUCCESSFUL!
        echo ========================================
        echo.
        echo JAR created:
        echo   build\libs\camera-list-app-1.0.0.jar
        echo.
        echo To run:
        echo   java -jar build\libs\camera-list-app-1.0.0.jar
        echo.
        echo Or use: run.bat
        echo.
    ) else (
        echo Build failed!
    )
    goto :end
)

REM Neither Maven nor Gradle found, compile manually
echo Neither Maven nor Gradle found. Compiling manually...
echo.

REM Check if javac is available
where javac >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java compiler (javac) not found!
    echo Please install Java JDK or ensure it's in your PATH.
    echo.
    pause
    exit /b 1
)

REM Download JNA if not present
if not exist "jna-5.13.0.jar" (
    echo Downloading JNA library...
    powershell -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar' -OutFile 'jna-5.13.0.jar'"

    if not exist "jna-5.13.0.jar" (
        echo Failed to download JNA library!
        echo Please download manually from:
        echo https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar
        echo.
        pause
        exit /b 1
    )
)

REM Compile
echo Compiling CameraListApp.java...
javac -cp jna-5.13.0.jar CameraListApp.java

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo To run:
    echo   java -cp .;jna-5.13.0.jar CameraListApp
    echo.
    echo Or use: run.bat
    echo.
) else (
    echo Compilation failed!
)

:end
pause
