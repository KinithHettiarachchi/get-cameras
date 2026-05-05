using AForge.Video.DirectShow;
using System.Text;

namespace GetCameras
{
    public static class CameraInfo
    {
        /// <summary>
        /// Gets camera information and writes to console in format: CameraName~~resolution1~~resolution2...
        /// This method can be called from command line or from other applications (including Java via Process)
        /// </summary>
        public static void GetCameraInformation()
        {
            try
            {
                // Get all video input devices
                FilterInfoCollection videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

                if (videoDevices.Count == 0)
                {
                    Console.WriteLine("No cameras found");
                    return;
                }

                for (int i = 0; i < videoDevices.Count; i++)
                {
                    var cameraLine = new StringBuilder();
                    cameraLine.Append(videoDevices[i].Name);

                    // Get supported capabilities (resolutions) for this camera
                    try
                    {
                        VideoCaptureDevice videoDevice = new VideoCaptureDevice(videoDevices[i].MonikerString);

                        if (videoDevice.VideoCapabilities.Length > 0)
                        {
                            // Group by resolution and frame rate
                            var capabilities = videoDevice.VideoCapabilities
                                .OrderByDescending(c => c.FrameSize.Width)
                                .ThenByDescending(c => c.FrameSize.Height)
                                .ThenByDescending(c => c.AverageFrameRate);

                            foreach (var capability in capabilities)
                            {
                                cameraLine.Append($"~~{capability.FrameSize.Width}x{capability.FrameSize.Height}@{capability.AverageFrameRate}fps");
                            }
                        }
                    }
                    catch
                    {
                        // Skip cameras with errors
                    }

                    Console.WriteLine(cameraLine.ToString());
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Gets camera information and returns as a string.
        /// Useful when calling from other .NET code or as a DLL reference.
        /// </summary>
        /// <returns>String with camera information in format: CameraName~~resolution1~~resolution2...</returns>
        public static string GetCameraInformationAsString()
        {
            var result = new StringBuilder();

            try
            {
                // Get all video input devices
                FilterInfoCollection videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

                if (videoDevices.Count == 0)
                {
                    return "No cameras found";
                }

                for (int i = 0; i < videoDevices.Count; i++)
                {
                    var cameraLine = new StringBuilder();
                    cameraLine.Append(videoDevices[i].Name);

                    // Get supported capabilities (resolutions) for this camera
                    try
                    {
                        VideoCaptureDevice videoDevice = new VideoCaptureDevice(videoDevices[i].MonikerString);

                        if (videoDevice.VideoCapabilities.Length > 0)
                        {
                            // Group by resolution and frame rate
                            var capabilities = videoDevice.VideoCapabilities
                                .OrderByDescending(c => c.FrameSize.Width)
                                .ThenByDescending(c => c.FrameSize.Height)
                                .ThenByDescending(c => c.AverageFrameRate);

                            foreach (var capability in capabilities)
                            {
                                cameraLine.Append($"~~{capability.FrameSize.Width}x{capability.FrameSize.Height}@{capability.AverageFrameRate}fps");
                            }
                        }
                    }
                    catch
                    {
                        // Skip cameras with errors
                    }

                    result.AppendLine(cameraLine.ToString());
                }
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }

            return result.ToString();
        }
    }
}
