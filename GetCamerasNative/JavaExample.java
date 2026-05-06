import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;

/**
 * Java interface to GetCamerasNative.dll
 * Uses JNA (Java Native Access) to call native C++ DLL
 * 
 * Add JNA dependency to your project:
 * Maven:
 *   <dependency>
 *     <groupId>net.java.dev.jna</groupId>
 *     <artifactId>jna</artifactId>
 *     <version>5.13.0</version>
 *   </dependency>
 * 
 * Gradle:
 *   implementation 'net.java.dev.jna:jna:5.13.0'
 */
public interface GetCamerasNative extends Library {
    // Load the DLL
    GetCamerasNative INSTANCE = Native.load("GetCamerasNative", GetCamerasNative.class);

    /**
     * Get camera information
     * @return String containing camera names and resolutions in format:
     *         CameraName~~Resolution1~~Resolution2...
     *         Each camera on a new line
     */
    String GetCameras();

    /**
     * Free the string returned by GetCameras (optional, but recommended)
     * @param str The string pointer returned by GetCameras
     */
    void FreeCameraString(String str);
}

/**
 * Example usage of GetCamerasNative DLL from Java
 */
class CameraDetector {
    public static void main(String[] args) {
        try {
            System.out.println("📷 Getting camera information...\n");

            // Call the native DLL
            String result = GetCamerasNative.INSTANCE.GetCameras();

            if (result == null || result.isEmpty()) {
                System.out.println("No cameras found or error occurred.");
                return;
            }

            // Parse and display results
            String[] lines = result.split("\n");

            System.out.println("Found " + lines.length + " camera(s):\n");
            System.out.println("=".repeat(60));

            for (String line : lines) {
                String[] parts = line.split("~~");

                if (parts.length > 0) {
                    System.out.println("\n📹 Camera: " + parts[0]);
                    System.out.println("   Resolutions:");

                    for (int i = 1; i < parts.length; i++) {
                        System.out.println("     • " + parts[i]);
                    }
                }
            }

            System.out.println("\n" + "=".repeat(60));

            // Optional: Free the native string (DLL handles this automatically on next call)
            // GetCamerasNative.INSTANCE.FreeCameraString(result);

        } catch (UnsatisfiedLinkError e) {
            System.err.println("❌ Error: GetCamerasNative.dll not found!");
            System.err.println("   Please ensure GetCamerasNative.dll is in:");
            System.err.println("   1. The same directory as your Java application");
            System.err.println("   2. Or in a directory listed in java.library.path");
            System.err.println("   3. Or in Windows System32 folder");
            System.err.println("\n   Current java.library.path:");
            System.err.println("   " + System.getProperty("java.library.path"));
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
