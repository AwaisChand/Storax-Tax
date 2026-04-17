import UIKit
import Flutter
import VisionKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, VNDocumentCameraViewControllerDelegate {

    var flutterResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return ok
        }

        let channel = FlutterMethodChannel(
            name: "vision_scanner",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            if call.method == "scanDocument" {

                /// ✅ Prevent multiple calls
                if self.flutterResult != nil {
                    result(FlutterError(code: "ALREADY_ACTIVE", message: "Scanner already active", details: nil))
                    return
                }

                self.flutterResult = result
                self.openScanner(controller: controller)
            }
        }

        return ok
    }

    func openScanner(controller: UIViewController) {
        guard VNDocumentCameraViewController.isSupported else {
            flutterResult?(nil)
            flutterResult = nil
            return
        }

        DispatchQueue.main.async {
            let scanner = VNDocumentCameraViewController()
            scanner.delegate = self
            controller.present(scanner, animated: true)
        }
    }

    // ✅ Success
    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        controller.dismiss(animated: true)

        DispatchQueue.global(qos: .userInitiated).async {
            let image = scan.imageOfPage(at: 0)

            let tempDir = NSTemporaryDirectory()
            let filePath = "\(tempDir)/scan_\(Date().timeIntervalSince1970).jpg"

            if let data = image.jpegData(compressionQuality: 0.7) {
                try? data.write(to: URL(fileURLWithPath: filePath))

                DispatchQueue.main.async {
                    self.flutterResult?(filePath)
                    self.flutterResult = nil /// ✅ reset
                }
            } else {
                DispatchQueue.main.async {
                    self.flutterResult?(nil)
                    self.flutterResult = nil
                }
            }
        }
    }

    // ❌ Cancel
    func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        controller.dismiss(animated: true)

        DispatchQueue.main.async {
            self.flutterResult?(nil)
            self.flutterResult = nil
        }
    }

    // ❌ Error
    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError error: Error
    ) {
        controller.dismiss(animated: true)

        DispatchQueue.main.async {
            self.flutterResult?(nil)
            self.flutterResult = nil
        }
    }
}