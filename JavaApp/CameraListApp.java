import com.sun.jna.Library;
import com.sun.jna.Native;
import javax.swing.JOptionPane;

/**
 * JNA Interface to GetCamerasNative.dll
 */
interface GetCamerasNative extends Library {
    GetCamerasNative INSTANCE = Native.load("GetCamerasNative", GetCamerasNative.class);
    String GetCameras();
}

/**
 * Camera List Application
 * Displays available cameras and their resolutions in a JOptionPane
 */
public class CameraListApp {

    public static void main(String[] args) {
        // Set look and feel to system default
        try {
            javax.swing.UIManager.setLookAndFeel(
                javax.swing.UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            // Ignore - will use default look and feel
        }

        // Get camera information
        String cameraInfo = getCameraInformation();

        // Display in JOptionPane
        JOptionPane.showMessageDialog(
            null,
            cameraInfo,
            "📷 Available Cameras",
            JOptionPane.INFORMATION_MESSAGE
        );

        System.exit(0);
    }

    /**
     * Gets camera information from the native DLL
     * @return Formatted string with camera information
     */
    private static String getCameraInformation() {
        try {
            // Call the native DLL
            String rawData = GetCamerasNative.INSTANCE.GetCameras();

            if (rawData == null || rawData.trim().isEmpty()) {
                return "❌ No data received from DLL";
            }

            // Parse and format the data
            StringBuilder formatted = new StringBuilder();
            formatted.append("Available Cameras and Resolutions:\n\n");

            String[] lines = rawData.split("\n");

            if (lines.length == 0 || (lines.length == 1 && lines[0].contains("No cameras"))) {
                return "⚠️ No cameras found on this system.\n\n" +
                       "Please check:\n" +
                       "  • Camera is connected\n" +
                       "  • Drivers are installed\n" +
                       "  • Camera is not in use by another application";
            }

            int cameraCount = 0;

            for (String line : lines) {
                if (line.trim().isEmpty()) {
                    continue;
                }

                String[] parts = line.split("~~");

                if (parts.length > 0) {
                    cameraCount++;

                    // Camera name
                    formatted.append("📹 Camera ").append(cameraCount).append(": ");
                    formatted.append(parts[0]).append("\n");

                    // Resolutions
                    if (parts.length > 1) {
                        formatted.append("   Supported Resolutions:\n");
                        for (int i = 1; i < parts.length; i++) {
                            formatted.append("      • ").append(parts[i]).append("\n");
                        }
                    } else {
                        formatted.append("   No resolution information available\n");
                    }

                    formatted.append("\n");
                }
            }

            if (cameraCount == 0) {
                return "⚠️ No cameras found";
            }

            // Add summary
            formatted.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
            formatted.append("Total cameras found: ").append(cameraCount);

            return formatted.toString();

        } catch (UnsatisfiedLinkError e) {
            return "❌ Error: GetCamerasNative.dll not found!\n\n" +
                   "Please ensure:\n" +
                   "  • GetCamerasNative.dll is in the same directory as this JAR\n" +
                   "  • Or add to java.library.path\n" +
                   "  • Or place in Windows System32 folder\n\n" +
                   "Technical details:\n" + e.getMessage();

        } catch (Exception e) {
            return "❌ Error getting camera information:\n\n" + 
                   e.getClass().getSimpleName() + ": " + e.getMessage();
        }
    }
}
