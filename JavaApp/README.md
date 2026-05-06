# Java Camera List Application

This folder contains a Java sample application that displays available cameras and their supported resolutions in a graphical JOptionPane dialog.

## 📋 Overview

The application uses **JNA (Java Native Access)** to call the `GetCamerasNative.dll` native library and displays camera information in a user-friendly dialog box.

## 🎯 Features

- ✅ Displays all available cameras
- ✅ Shows supported resolutions for each camera
- ✅ User-friendly JOptionPane information dialog
- ✅ Native Windows integration via JNA
- ✅ No external .NET runtime required

## 📦 Requirements

- **Java JDK 11+** (for building)
- **Java JRE 11+** (for running)
- **GetCamerasNative.dll** (built from `../GetCamerasNative`)
- **JNA library** (automatically downloaded by Maven/Gradle, or manually downloaded)

## 🚀 Quick Start

### Option 1: Using Build Script (Easiest)

```batch
# Build the application
build.bat

# Run the application
run.bat
```

The build script will automatically detect and use Maven, Gradle, or compile manually with javac.

### Option 2: Using Maven

```batch
# Build
mvn clean package

# Run
java -jar target\camera-list-app-1.0.0-jar-with-dependencies.jar
```

### Option 3: Using Gradle

```batch
# Build
gradle build

# Run
java -jar build\libs\camera-list-app-1.0.0.jar
```

### Option 4: Manual Compilation

```batch
# Download JNA library
# Download from: https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar
# Save as: jna-5.13.0.jar

# Compile
javac -cp jna-5.13.0.jar CameraListApp.java

# Run
java -cp .;jna-5.13.0.jar CameraListApp
```

## 📁 File Structure

```
JavaApp/
├── src/
│   └── main/
│       └── java/
│           └── CameraListApp.java  # Main application source (Maven standard)
├── CameraListApp.java              # Main application source (root copy for manual build)
├── pom.xml                         # Maven build configuration
├── build.gradle                    # Gradle build configuration
├── build.bat                       # Universal build script
├── run.bat                         # Universal run script
└── README.md                       # This file
```

**Note:** Maven builds use `src/main/java/CameraListApp.java` (standard Maven layout). The `build.bat` script automatically sets this up.

## 🔧 How It Works

1. **JNA Interface**: Declares native interface to `GetCamerasNative.dll`
2. **Native Call**: Calls `GetCameras()` from the DLL
3. **Data Parsing**: Parses the returned camera data (format: `CameraName~~Resolution1~~Resolution2...`)
4. **UI Display**: Formats and displays in a JOptionPane information dialog

## 🎨 Sample Output

The dialog shows:

```
Available Cameras and Resolutions:

📹 Camera 1: Integrated Webcam
   Supported Resolutions:
      • 1920x1080
      • 1280x720
      • 640x480

📹 Camera 2: USB Camera
   Supported Resolutions:
      • 1280x720
      • 640x480

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total cameras found: 2
```

## ⚠️ Important Notes

### DLL Location

The `GetCamerasNative.dll` must be accessible when running the Java application. The DLL can be placed:

1. **Same directory as the JAR file** (recommended)
2. In the Windows `System32` folder
3. In a folder listed in the `java.library.path`

The `run.bat` script automatically copies the DLL from `../GetCamerasNative/` to the appropriate location.

### Manual DLL Path Setup

If you prefer to specify the DLL location manually:

```batch
java -Djava.library.path=..\GetCamerasNative -jar camera-list-app-1.0.0-jar-with-dependencies.jar
```

## 🔍 Troubleshooting

### "GetCamerasNative.dll not found"

**Solution**: Ensure the DLL is built and placed in the same directory as your JAR file:

```batch
cd ..\GetCamerasNative
build-native.bat
copy GetCamerasNative.dll ..\JavaApp\
```

### "No cameras found"

**Possible causes**:
- No camera is physically connected
- Camera drivers are not installed
- Camera is in use by another application
- Insufficient permissions to access the camera

### Compilation Error

**Solution**: Ensure JNA library is in the classpath:
- Maven/Gradle: Dependencies are automatic
- Manual: Download `jna-5.13.0.jar` and place in the JavaApp folder

## 📚 Dependencies

- **JNA 5.13.0**: Java Native Access library for calling native DLLs
  - Maven: `net.java.dev.jna:jna:5.13.0`
  - Manual: https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar

## 🔗 Related Files

- **Native DLL**: `../GetCamerasNative/GetCamerasNative.dll`
- **DLL Source**: `../GetCamerasNative/GetCamerasNative.cpp`
- **DLL Build Script**: `../GetCamerasNative/build-native.bat`
- **.NET EXE Alternative**: `../GetCameras/` (self-contained .NET executable)

## 💡 Integration Example

To integrate into your own Java application:

```java
import com.sun.jna.Library;
import com.sun.jna.Native;

interface GetCamerasNative extends Library {
    GetCamerasNative INSTANCE = Native.load("GetCamerasNative", GetCamerasNative.class);
    String GetCameras();
}

// Use it
String cameraData = GetCamerasNative.INSTANCE.GetCameras();
// Parse cameraData (format: "CameraName~~Res1~~Res2\nCameraName2~~Res1...")
```

## 📄 License

This sample follows the same license as the parent get-cameras project.
