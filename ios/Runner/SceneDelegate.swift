import Flutter
import GoogleMaps
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // UIScene can connect before map views appear; the key must be set here
        // as well as in AppDelegate after the Flutter scene lifecycle migration.
        GMSServices.provideAPIKey("AIzaSyCtVdR79rZ-cTDtXYrURz1YmGLmeCiBIDo")
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
}
