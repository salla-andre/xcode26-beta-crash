import TestFramework
import UIKit

@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate
{

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print(NetworkChecker.shared.isConnected)
        return true
    }

}
