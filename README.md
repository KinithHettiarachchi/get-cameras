# 📷 GetCameras - Complete Camera Enumeration Solution

> Enumerate Windows cameras and their supported resolutions - Available as both EXE and DLL

---

## 🎯 Two Solutions Available

### 🔷 GetCameras.exe (.NET) - Ready to Use ✅
- **Size:** ~36 MB (self-contained)
- **Java:** Via `Runtime.exec()`
- **Status:** Already built and ready
- **Location:** `GetCameras/bin/Release/net10.0-windows/win-x64/publish/GetCameras.exe`

### 🔶 GetCamerasNative.dll (C++) - Requires Build
- **Size:** ~50-100 KB
- **Java:** Via JNA (direct DLL call)
- **Status:** Requires Visual Studio C++ tools
- **Location:** `GetCamerasNative/` (after building)

---

## 📋 Output Format

```
CameraName~~Resolution1~~Resolution2...
```

Example:
```
HD Pro Webcam~~1920x1080@30fps~~1280x720@30fps~~640x480@30fps
```

---

## 🚀 Quick Start

### Using GetCameras.exe (Ready Now!)

**Command Line:**
```cmd
GetCameras\bin\Release\net10.0-windows\win-x64\publish\GetCameras.exe
```

**From Java:**
```java
Process p = Runtime.getRuntime().exec("GetCameras.exe");
BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
String line;
while ((line = r.readLine()) != null) {
    String[] parts = line.split("~~");
    // parts[0] = camera name, parts[1+] = resolutions
}
```

---

## 🔨 Building

### Build EXE:
```cmd
cd GetCameras
build.bat
```

### Build DLL (requires VS C++ tools):
```cmd
cd GetCamerasNative
build-native.bat
```

---

## ☕ Java Integration

### Option 1: Ready-to-Use GUI Sample ⭐ NEW
```cmd
cd JavaApp
build.bat
run.bat
```
Shows cameras in a JOptionPane dialog - see `JavaApp/README.md` for details

### Option 2: EXE (Easiest for CLI)
See Quick Start above

### Option 3: DLL (Direct Integration)
Add JNA: `net.java.dev.jna:jna:5.13.0`

```java
import com.sun.jna.*;

interface GetCamerasNative extends Library {
    GetCamerasNative INSTANCE = Native.load("GetCamerasNative", GetCamerasNative.class);
    String GetCameras();
}

// Use:
String cameras = GetCamerasNative.INSTANCE.GetCameras();
```

Complete examples: `JavaApp/CameraListApp.java` or `GetCamerasNative/JavaExample.java`

---

## 📊 EXE vs DLL

| Feature | EXE | DLL |
|---------|-----|-----|
| Size | 36 MB | 50 KB ✅ |
| Network | May block | OK ✅ |
| Build | Done ✅ | Required |
| Java | Process | JNA ✅ |

**Use EXE if:** Files allowed, want zero setup  
**Use DLL if:** EXE blocked, want small size

---

## 📁 Project Structure

```
get-cameras/
├── GetCameras/              # .NET EXE
│   ├── build.bat
│   └── bin/.../GetCameras.exe
├── GetCamerasNative/        # Native DLL  
│   ├── build-native.bat
│   ├── JavaExample.java
│   └── GetCamerasNative.dll
├── JavaApp/                 # Java GUI Sample ⭐ NEW
│   ├── CameraListApp.java
│   ├── build.bat
│   ├── run.bat
│   └── README.md
└── README.md
```

---

## 🛠️ Troubleshooting

**No cameras:** Check drivers, close other apps using camera  
**Build DLL fails:** Install VS C++ tools (see build-native.bat)  
**Java UnsatisfiedLink:** Put DLL in same directory as JAR

---

## 🎯 Quick Decision

✅ **Use EXE** - Already built, works now  
✅ **Use DLL** - If EXE blocked on network

---

**Platform:** Windows x64  
**Repo:** https://github.com/KinithHettiarachchi/get-cameras
