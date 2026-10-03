import UIKit
import Flutter
import VisionKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, VNDocumentCameraViewControllerDelegate {

    var flutterResult: FlutterResult?

    override init() {
        super.init()
        GMSServices.provideAPIKey("AIzaSyCtVdR79rZ-cTDtXYrURz1YmGLmeCiBIDo")
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Required for google_maps_flutter on iOS. Must run before Flutter UI.
        GMSServices.provideAPIKey("AIzaSyCtVdR79rZ-cTDtXYrURz1YmGLmeCiBIDo")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let channel = FlutterMethodChannel(
            name: "vision_scanner",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            if call.method == "scanDocument" {
                if self.flutterResult != nil {
                    result(FlutterError(
                        code: "ALREADY_ACTIVE",
                        message: "Scanner already active",
                        details: nil
                    ))
                    return
                }

                self.flutterResult = result

                guard let controller = self.topViewController() else {
                    result(nil)
                    self.flutterResult = nil
                    return
                }

                self.openScanner(controller: controller)
            }
        }
    }

    private func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = scenes.flatMap { $0.windows }
        return (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
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

    // Success
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
                    self.flutterResult = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.flutterResult?(nil)
                    self.flutterResult = nil
                }
            }
        }
    }

    // Cancel
    func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        controller.dismiss(animated: true)

        DispatchQueue.main.async {
            self.flutterResult?(nil)
            self.flutterResult = nil
        }
    }

    // Error
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
