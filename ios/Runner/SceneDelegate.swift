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
        GMSServices.provideAPIKey("AIzaSyBx7X2S83I4ei7X51AOUOiqiaj-e7gHO0E")
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
}
