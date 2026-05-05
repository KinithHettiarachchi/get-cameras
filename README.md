# 📷 GetCameras

> A lightweight Windows utility to enumerate all available cameras and their supported resolutions.

## 🎯 Purpose

GetCameras is a command-line tool that detects all video capture devices (cameras) connected to your Windows system and lists their supported resolutions with frame rates. Perfect for:

- 🔍 **Camera Discovery** - Find all connected cameras instantly
- 📊 **Resolution Testing** - See what resolutions each camera supports
- 🔌 **Integration** - Easy to integrate with Java, Python, or any language via command-line
- 🚀 **Portable** - Single executable, no installation required

---

## ✨ Features

- ✅ **Self-Contained** - No .NET runtime installation required
- ✅ **Single Executable** - Everything bundled in one .exe file (~36 MB)
- ✅ **Fast** - Instant camera enumeration
- ✅ **Simple Output** - Clean, parseable format
- ✅ **Cross-Language** - Works with Java, Python, PowerShell, C#, etc.
- ✅ **No Admin Required** - Runs with standard user privileges

---

## 📥 Quick Start

### 💻 Command Line Usage

Simply run the executable:

```cmd
GetCameras.exe
```

**Example Output:**
```
DroidCam Video~~2560x1440@30fps~~1920x1080@30fps~~1280x720@30fps~~640x480@30fps
Integrated Camera~~2560x1440@30fps~~1920x1080@30fps~~1280x720@30fps~~640x480@30fps
OBS Virtual Camera~~1920x1080@60fps
```

### 📋 Output Format

Each line represents one camera:
```
CameraName~~Resolution1~~Resolution2~~Resolution3...
```

- **`~~`** separates the camera name from resolutions
- **`~~`** separates each resolution
- Format: `WidthxHeight@FPSfps`

### 💾 Save to File

```cmd
GetCameras.exe > cameras.txt
```

---

## 🔧 Building from Source

### Prerequisites

- 🛠️ .NET 10 SDK
- 🪟 Windows OS
- 💻 Visual Studio 2026 (optional)

### Option 1: Using Build Script (Easiest)

```cmd
build.bat
```

This will:
1. Clean previous builds
2. Publish a self-contained executable
3. Show the output location and file size

### Option 2: Manual Build

```cmd
dotnet publish -c Release
```

### 📦 Output Location

The self-contained executable will be created at:
```
bin\Release\net10.0-windows\win-x64\publish\GetCameras.exe
```

**File Details:**
- 📏 Size: ~36 MB (includes .NET runtime)
- 🖥️ Platform: Windows x64
- 📦 Type: Single self-contained executable

---

## 🚀 Deployment

### Simple Deployment

1. Build the project using `build.bat` or `dotnet publish -c Release`
2. Copy `GetCameras.exe` from the publish folder
3. Distribute the single .exe file
4. ✅ No installation needed on target machines!

### 📋 System Requirements

**Target Machines:**
- 🪟 Windows 7 or later (x64)
- ❌ No .NET installation required
- 📹 DirectShow compatible cameras

**Development Machine:**
- 🛠️ .NET 10 SDK
- 💻 Visual Studio 2026 or compatible IDE

---

## 🔗 Integration Examples

### ☕ Java Integration

```java
import java.io.*;

public class CameraDetector {
    public static void main(String[] args) {
        try {
            // Execute GetCameras.exe
            Process process = Runtime.getRuntime().exec("GetCameras.exe");

            // Read output
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                // Parse: CameraName~~Resolution1~~Resolution2...
                String[] parts = line.split("~~");
                String cameraName = parts[0];

                System.out.println("📷 Camera: " + cameraName);
                for (int i = 1; i < parts.length; i++) {
                    System.out.println("   📐 " + parts[i]);
                }
            }

            process.waitFor();
            reader.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### 🐍 Python Integration

```python
import subprocess

# Execute and capture output
result = subprocess.run(['GetCameras.exe'], 
                       capture_output=True, 
                       text=True)

# Parse output
for line in result.stdout.strip().split('\n'):
    parts = line.split('~~')
    camera_name = parts[0]
    resolutions = parts[1:]

    print(f"📷 Camera: {camera_name}")
    for res in resolutions:
        print(f"   📐 {res}")
```

### 💻 PowerShell Integration

```powershell
# Execute and capture output
$output = & ".\GetCameras.exe"

# Parse each line
foreach ($line in $output) {
    $parts = $line -split "~~"
    $cameraName = $parts[0]
    $resolutions = $parts[1..($parts.Length-1)]

    Write-Host "📷 Camera: $cameraName" -ForegroundColor Cyan
    foreach ($res in $resolutions) {
        Write-Host "   📐 $res" -ForegroundColor Green
    }
}
```

### 💎 C# / .NET Integration

```csharp
using System.Diagnostics;

var process = new Process
{
    StartInfo = new ProcessStartInfo
    {
        FileName = "GetCameras.exe",
        RedirectStandardOutput = true,
        UseShellExecute = false,
        CreateNoWindow = true
    }
};

process.Start();

while (!process.StandardOutput.EndOfStream)
{
    string line = process.StandardOutput.ReadLine();
    string[] parts = line.Split("~~");
    string cameraName = parts[0];
    string[] resolutions = parts[1..];

    Console.WriteLine($"📷 Camera: {cameraName}");
    foreach (var res in resolutions)
    {
        Console.WriteLine($"   📐 {res}");
    }
}

process.WaitForExit();
```

---

## 🛠️ Project Structure

```
GetCameras/
├── 📄 CameraInfo.cs         # Core camera enumeration logic
├── 📄 Program.cs            # Application entry point
├── 📄 GetCameras.csproj     # Project configuration
├── 📄 build.bat             # Build script
└── 📄 README.md             # This file
```

---

## 🔍 Troubleshooting

### ❌ "No cameras found"

**Possible Solutions:**
- 🔌 Check if camera is physically connected
- 🔄 Reconnect the camera
- 💾 Verify camera drivers are installed
- 🚫 Close other applications using the camera
- 🔁 Restart your computer

### ⚠️ Antivirus Warnings

Self-contained executables may trigger false positives.

**Solutions:**
- ✅ Add to antivirus whitelist
- 🔏 Code sign the executable (recommended for production)
- 📝 Verify the source and build it yourself

### 🔒 Access Denied Errors

Some cameras may require elevated privileges.

**Solution:**
- 🛡️ Right-click `GetCameras.exe`
- ⬆️ Select "Run as Administrator"

---

## 📝 Technical Details

### Dependencies

- **AForge.Video.DirectShow** (2.2.5) - DirectShow wrapper for camera access
- **.NET 10 Runtime** (embedded in published executable)

### How It Works

1. 🔍 Uses DirectShow API to enumerate video capture devices
2. 📊 Queries each device for supported video capabilities
3. 📋 Formats output as: `CameraName~~Resolution1~~Resolution2...`
4. 💬 Outputs to stdout for easy integration

---

## 📜 License

This project is provided as-is for educational and commercial use.

---

## 🤝 Contributing

Found a bug or want to contribute? Feel free to:

1. 🐛 Report issues
2. 💡 Suggest features
3. 🔧 Submit improvements

---

## 📞 Support

For questions or issues:

1. 📖 Check this README
2. 🔍 Review troubleshooting section
3. 🧪 Test with different cameras
4. 📝 Check Windows camera drivers

---

## 🎓 Use Cases

- 🎥 **Video Conferencing Apps** - Detect available cameras for user selection
- 🤖 **Automation Scripts** - Verify camera availability in CI/CD pipelines
- 🎬 **Streaming Software** - List camera options for configuration
- 🔧 **System Diagnostics** - Troubleshoot camera detection issues
- 📱 **IoT Projects** - Camera enumeration for edge devices
- 🎮 **Game Development** - Detect webcams for player tracking

---

## 🌟 Why GetCameras?

✅ **Lightweight** - No bloated dependencies  
✅ **Fast** - Instant results  
✅ **Reliable** - Uses native Windows APIs  
✅ **Portable** - Single executable  
✅ **Developer-Friendly** - Easy to integrate  
✅ **Free** - Open source and free to use  

---

Made with ❤️ for developers who need simple camera enumeration

**Version:** 1.0  
**Platform:** Windows x64  
**.NET Version:** 10.0  
**Build Date:** 2026
