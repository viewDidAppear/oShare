import UIKit
import MultipeerConnectivity

class PeerBrowserViewController: UIViewController {
	
	@IBOutlet var peerTableView: UITableView!
	@IBOutlet var discoverabilitySwitch: UISwitch!
	
	private let transitionAnimator = SheetAnimator()
	private var connectivityManager: MultipeerConnectivityManager!
	private let peerTableViewHandler = PeerBrowserTableViewHandler()
	private var isAdvertising = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "oShare"
		
		checkDisplayName()
		configureHandler()
	}
	
	private func configureHandler() {
		peerTableViewHandler.tableView = peerTableView
		peerTableView.delegate = peerTableViewHandler
		peerTableView.dataSource = peerTableViewHandler
	}
	
	private func checkDisplayName() {
		guard let setupViewController = Constants.mainStoryboard.instantiateViewController(withIdentifier: "setupViewController") as? ChatSetupViewController else { return }
		setupViewController.transitioningDelegate = self
		setupViewController.delegate = self
		
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 0.6
		})
		
		present(setupViewController, animated: true, completion: nil)
	}
	
	private func browseForNearbyDevices() {
		// Retrieve the display name from UserDefaults, and use that to create our MCPeerID.
		guard let displayName = UserDefaults.standard.value(forKey: "displayName") as? String, displayName.count > 0 && displayName.count <= 20 else {
			
			// If for any reason, the user has somehow set an empty string or a too-long name as their display name, they will be unable to connect to any peers.
			return
		}
		
		connectivityManager = MultipeerConnectivityManager(peer: MCPeerID(displayName: displayName))
		connectivityManager.delegate = self
		connectivityManager.startBrowsingForDevices()
	}
	
}

extension PeerBrowserViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transitionAnimator.isPresenting = true
		return transitionAnimator
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transitionAnimator.isPresenting = false
		return transitionAnimator
	}
}

extension PeerBrowserViewController: ChatSetupViewControllerDelegate {
	func dismissed() {
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 1.0
		})
		
		browseForNearbyDevices()
		connectivityManager.startAdvertising()
	}
}

extension PeerBrowserViewController: MultipeerConnectivityManagerDelegate {
	
	func beganBrowsing() {
		
	}
	
	func beganAdvertising() {
		isAdvertising = true
	}
	
	func stoppedBrowsing() {
		
	}
	
	func stoppedAdvertising() {
		isAdvertising = false
	}

	func receivedInvitation(fromPeer peer: MCPeerID, context: Data?) {
		// TODO: - Show Message
	}
	
	func connected(withPeer peer: MCPeerID) {
		// TODO: - Show Message
	}
	
	func failedToBrowseForPeers(withError error: Error) {
		// TODO: - Show Error Box
	}
	
	func foundPeer(_ peer: MCPeerID) {
		peerTableViewHandler.reloadData(
			foundPeers: connectivityManager.foundPeers
		)
	}
	
	func lostPeer(_ peer: MCPeerID) {
		peerTableViewHandler.reloadData(
			foundPeers: connectivityManager.foundPeers
		)
	}

}
