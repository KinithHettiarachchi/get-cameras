namespace GetCameras
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Get camera information and output to console
            CameraInfo.GetCameraInformation();
        }
    }
}