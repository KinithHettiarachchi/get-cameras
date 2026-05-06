// GetCamerasNative.cpp - Native C++ DLL for DirectShow camera enumeration
// Can be called from Java using JNA

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <dshow.h>
#include <string>
#include <sstream>
#include <vector>

#pragma comment(lib, "strmiids.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "oleaut32.lib")

// Export function for Java to call
extern "C" __declspec(dllexport) const char* GetCameras();
extern "C" __declspec(dllexport) void FreeCameraString(const char* str);

// Structure to hold camera information
struct CameraInfo {
    std::wstring name;
    std::vector<std::wstring> resolutions;
};

// Global buffer to store result (freed by FreeCameraString)
static char* g_resultBuffer = nullptr;

// Helper function to enumerate video capture devices
std::vector<CameraInfo> EnumerateCameras() {
    std::vector<CameraInfo> cameras;
    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    bool comInitialized = SUCCEEDED(hr);

    ICreateDevEnum* pDevEnum = nullptr;
    IEnumMoniker* pEnum = nullptr;

    hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,
        IID_PPV_ARGS(&pDevEnum));

    if (SUCCEEDED(hr)) {
        hr = pDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory, &pEnum, 0);

        if (hr == S_OK) {
            IMoniker* pMoniker = nullptr;

            while (pEnum->Next(1, &pMoniker, NULL) == S_OK) {
                IPropertyBag* pPropBag = nullptr;
                hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));

                if (SUCCEEDED(hr)) {
                    CameraInfo cameraInfo;
                    VARIANT var;
                    VariantInit(&var);

                    // Get camera name
                    hr = pPropBag->Read(L"FriendlyName", &var, 0);
                    if (SUCCEEDED(hr)) {
                        cameraInfo.name = var.bstrVal;
                        VariantClear(&var);
                    }

                    // Try to get video formats
                    IBaseFilter* pFilter = nullptr;
                    hr = pMoniker->BindToObject(NULL, NULL, IID_IBaseFilter, (void**)&pFilter);

                    if (SUCCEEDED(hr) && pFilter) {
                        IEnumPins* pEnumPins = nullptr;
                        hr = pFilter->EnumPins(&pEnumPins);

                        if (SUCCEEDED(hr)) {
                            IPin* pPin = nullptr;

                            while (pEnumPins->Next(1, &pPin, NULL) == S_OK) {
                                PIN_DIRECTION pinDir;
                                pPin->QueryDirection(&pinDir);

                                if (pinDir == PINDIR_OUTPUT) {
                                    IAMStreamConfig* pConfig = nullptr;
                                    hr = pPin->QueryInterface(IID_IAMStreamConfig, (void**)&pConfig);

                                    if (SUCCEEDED(hr)) {
                                        int count, size;
                                        hr = pConfig->GetNumberOfCapabilities(&count, &size);

                                        if (SUCCEEDED(hr) && size == sizeof(VIDEO_STREAM_CONFIG_CAPS)) {
                                            for (int i = 0; i < count; i++) {
                                                AM_MEDIA_TYPE* pmt = nullptr;
                                                VIDEO_STREAM_CONFIG_CAPS scc;

                                                hr = pConfig->GetStreamCaps(i, &pmt, (BYTE*)&scc);

                                                if (SUCCEEDED(hr)) {
                                                    if (pmt->formattype == FORMAT_VideoInfo) {
                                                        VIDEOINFOHEADER* pVih = (VIDEOINFOHEADER*)pmt->pbFormat;

                                                        int width = pVih->bmiHeader.biWidth;
                                                        int height = abs(pVih->bmiHeader.biHeight);
                                                        long long avgTimePerFrame = pVih->AvgTimePerFrame;
                                                        int fps = (int)(10000000.0 / avgTimePerFrame);

                                                        std::wstringstream wss;
                                                        wss << width << L"x" << height << L"@" << fps << L"fps";

                                                        // Avoid duplicates
                                                        std::wstring resolution = wss.str();
                                                        bool exists = false;
                                                        for (const auto& res : cameraInfo.resolutions) {
                                                            if (res == resolution) {
                                                                exists = true;
                                                                break;
                                                            }
                                                        }

                                                        if (!exists) {
                                                            cameraInfo.resolutions.push_back(resolution);
                                                        }
                                                    }

                                                    if (pmt->cbFormat != 0) {
                                                        CoTaskMemFree((PVOID)pmt->pbFormat);
                                                    }
                                                    if (pmt->pUnk != NULL) {
                                                        pmt->pUnk->Release();
                                                    }
                                                    CoTaskMemFree(pmt);
                                                }
                                            }
                                        }

                                        pConfig->Release();
                                    }
                                }

                                pPin->Release();
                            }

                            pEnumPins->Release();
                        }

                        pFilter->Release();
                    }

                    cameras.push_back(cameraInfo);
                    pPropBag->Release();
                }

                pMoniker->Release();
            }

            pEnum->Release();
        }

        pDevEnum->Release();
    }

    if (comInitialized) {
        CoUninitialize();
    }

    return cameras;
}

// Convert wide string to UTF-8
std::string WideToUtf8(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();

    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
}

// Main export function - returns camera information
extern "C" __declspec(dllexport) const char* GetCameras() {
    // Free previous result if exists
    if (g_resultBuffer != nullptr) {
        delete[] g_resultBuffer;
        g_resultBuffer = nullptr;
    }

    std::vector<CameraInfo> cameras = EnumerateCameras();

    if (cameras.empty()) {
        const char* msg = "No cameras found";
        size_t len = strlen(msg) + 1;
        g_resultBuffer = new char[len];
        strcpy_s(g_resultBuffer, len, msg);
        return g_resultBuffer;
    }

    std::ostringstream oss;

    for (size_t i = 0; i < cameras.size(); i++) {
        oss << WideToUtf8(cameras[i].name);

        for (const auto& resolution : cameras[i].resolutions) {
            oss << "~~" << WideToUtf8(resolution);
        }

        if (i < cameras.size() - 1) {
            oss << "\n";
        }
    }

    std::string result = oss.str();
    size_t len = result.length() + 1;
    g_resultBuffer = new char[len];
    strcpy_s(g_resultBuffer, len, result.c_str());

    return g_resultBuffer;
}

// Free the string allocated by GetCameras
extern "C" __declspec(dllexport) void FreeCameraString(const char* str) {
    if (str == g_resultBuffer && g_resultBuffer != nullptr) {
        delete[] g_resultBuffer;
        g_resultBuffer = nullptr;
    }
}

// DLL entry point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
