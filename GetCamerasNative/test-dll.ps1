# Test script for GetCamerasNative.dll using PowerShell
# This uses P/Invoke to call the native DLL directly

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing GetCamerasNative.dll" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if DLL exists
if (-not (Test-Path "GetCamerasNative.dll")) {
    Write-Host "❌ ERROR: GetCamerasNative.dll not found!" -ForegroundColor Red
    Write-Host "   Please run build-native.bat first.`n" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Found GetCamerasNative.dll`n" -ForegroundColor Green

# Define P/Invoke signature
$signature = @"
[DllImport("GetCamerasNative.dll", CallingConvention = CallingConvention.Cdecl)]
public static extern IntPtr GetCameras();
"@

try {
    # Add the DLL import type
    Add-Type -MemberDefinition $signature -Namespace "CameraTest" -Name "NativeMethods"

    Write-Host "Calling GetCameras() from DLL..." -ForegroundColor Cyan
    Write-Host ""

    # Call the function
    $resultPtr = [CameraTest.NativeMethods]::GetCameras()

    if ($resultPtr -eq [IntPtr]::Zero) {
        Write-Host "❌ Function returned null pointer" -ForegroundColor Red
    } else {
        # Convert pointer to string
        $result = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($resultPtr)

        Write-Host "========================================" -ForegroundColor Green
        Write-Host "DLL OUTPUT:" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""

        # Display result with formatting
        $lines = $result -split "`n"
        foreach ($line in $lines) {
            if ($line.Trim() -ne "") {
                $parts = $line -split "~~"
                if ($parts.Count -gt 0) {
                    Write-Host "📷 Camera: " -NoNewline -ForegroundColor Cyan
                    Write-Host $parts[0] -ForegroundColor White

                    if ($parts.Count -gt 1) {
                        Write-Host "   Resolutions:" -ForegroundColor Gray
                        for ($i = 1; $i -lt $parts.Count; $i++) {
                            Write-Host "     • " -NoNewline -ForegroundColor DarkGray
                            Write-Host $parts[$i] -ForegroundColor Green
                        }
                    }
                    Write-Host ""
                }
            }
        }

        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✅ DLL TEST SUCCESSFUL!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    }

} catch {
    Write-Host "❌ ERROR calling DLL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  • DLL dependencies missing (ole32.lib, oleaut32.lib, strmiids.lib)" -ForegroundColor Gray
    Write-Host "  • DLL architecture mismatch (32-bit vs 64-bit)" -ForegroundColor Gray
    Write-Host "  • Visual C++ Redistributable not installed" -ForegroundColor Gray
}

Write-Host ""
pause
