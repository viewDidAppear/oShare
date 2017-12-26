import UIKit
import MultipeerConnectivity

class PeerBrowserViewController: UIViewController {
	
	@IBOutlet var peerTableView: UITableView!
	@IBOutlet var discoverabilitySwitch: UISwitch!
	
	private let transitionAnimator = SheetAnimator()
	private var connectivityManager: MultipeerConnectivityManager!
	private let peerTableViewHandler = PeerBrowserTableViewHandler()
	private var isAdvertising = true
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "oShare"
		
		addDynamicTextObservers()
		checkDisplayName()
		configureHandler()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Configuration
	
	private func addDynamicTextObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleDynamicTextChanges(notification:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
	}
	
	private func configureHandler() {
		peerTableViewHandler.tableView = peerTableView
		peerTableView.delegate = peerTableViewHandler
		peerTableView.dataSource = peerTableViewHandler
	}
	
	// MARK: - Dynamic Text Handler
	// This function must be exposed to the Objective-C Runtime.

	@objc private func handleDynamicTextChanges(notification: Notification) {
		// To handle changes in dynamic text size, reload the tableView contents.
		peerTableViewHandler.reloadData(foundPeers: connectivityManager.foundPeers)
	}
	
	// MARK: - Browsing
	
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
			
			// If for any reason, the user has somehow set an empty string or a too-long name as their display name, they will be unable to connect to any peers. Handle this error.
			return
		}
		
		connectivityManager = MultipeerConnectivityManager(peer: MCPeerID(displayName: displayName))
		connectivityManager.delegate = self
		connectivityManager.startBrowsingForDevices()
	}
	
}

// MARK: - UIViewControllerTransitioningDelegate

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

// MARK: - ChatSetupViewControllerDelegate

extension PeerBrowserViewController: ChatSetupViewControllerDelegate {
	
	/// This function gets called whenever the chat setup (display name input) view controller is dismissed. When and only when this occurs, we begin advertising ourselves to nearby devices, as well as browsing for other advertising instances.
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
