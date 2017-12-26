import UIKit
import MultipeerConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var connectivityManager: MultipeerConnectivityManager!
	
	// This functionality was moved in here to ensure that we tear down and rebuild the connectivity manager as appropriate. The user will vanish if they close the app, and reappear to others when they reopen it.
	
	func configureConnectivityManager() {
		// Retrieve the display name from UserDefaults, and use that to create our MCPeerID.
		guard let displayName = UserDefaults.standard.value(forKey: "displayName") as? String, displayName.count > 0 && displayName.count <= 20 else {
			
			// If for any reason, the user has somehow set an empty string or a too-long name as their display name, they will be unable to connect to any peers. Handle this error.
			return
		}
		
		connectivityManager = MultipeerConnectivityManager(peer: MCPeerID(displayName: displayName))
		connectivityManager.startBrowsingForDevices()
		connectivityManager.startAdvertising()
	}
	
	func tearDownConnectivityManager() {
		connectivityManager.stopAdvertising()
		connectivityManager.stopBrowsingForDevices()
		connectivityManager.foundPeers = []
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		// When the app launches, and only when that happens, allow a new displayName to be set by setting this Boolean to true.
		// Ideally this would be configurable from within the app, inside another flow. However in the interest of keeping things simple, it happens on a `newLaunch` only.
		UserDefaults.standard.set(true, forKey: "newLaunch")

		return true
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		tearDownConnectivityManager()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		configureConnectivityManager()
	}

}
