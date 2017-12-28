import UIKit
import MultipeerConnectivity

class PeerBrowserViewController: UIViewController {
	
	@IBOutlet private var peerTableView: UITableView!
	@IBOutlet private var discoverabilitySwitch: UISwitch!
	
	private let transitionAnimator = SheetAnimator()
	private let peerTableViewHandler = PeerBrowserTableViewHandler()
	private var appDelegate: AppDelegate!
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "oShare"
		
		guard let appDelegate = Constants.appDelegate else { return }
		self.appDelegate = appDelegate
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		addDynamicTextObservers()
		checkDisplayName()
		configureHandler()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - UI Configuration
	
	private func addDynamicTextObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleDynamicTextChanges(notification:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
	}
	
	private func configureHandler() {
		peerTableViewHandler.tableView = peerTableView
		peerTableViewHandler.appDelegate = appDelegate
		peerTableView.delegate = peerTableViewHandler
		peerTableView.dataSource = peerTableViewHandler
	}
	
	// MARK: - Dynamic Text Handler
	// This function must be exposed to the Objective-C Runtime.

	@objc private func handleDynamicTextChanges(notification: Notification) {
		// To handle changes in dynamic text size, reload the tableView contents.
		peerTableViewHandler.reloadData(foundPeers: appDelegate.connectivityManager.foundPeers)
	}
	
	// MARK: - Browsing
	
	private func checkDisplayName() {
		guard let setupViewController = Constants.mainStoryboard.instantiateViewController(withIdentifier: "setupViewController") as? ChatSetupViewController else { return }
		setupViewController.transitioningDelegate = self
		setupViewController.delegate = self
		
		guard UserDefaults.standard.bool(forKey: "newLaunch") == true else { return }
		
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 0.6
		})
		
		present(setupViewController, animated: true, completion: nil)
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
	
	/// This function gets called whenever the chat setup (display name input) view controller is dismissed. When and only when this occurs, we begin advertising ourselves to nearby devices, as well as browsing for other peers.
	func dismissed() {
		// Prevent the displayName popover from displaying upon every viewDidLoad() run. Ensure it only triggers on a `newLaunch`.
		// There are better ways to do this, however for the sake of simplicity, I used UserDefaults.
		UserDefaults.standard.set(false, forKey: "newLaunch")
		
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 1.0
		})
		
		appDelegate.configureConnectivityManager()
		appDelegate.connectivityManager.delegate = self
	}
}

// MARK: - MultipeerConnectivityManagerDelegate

extension PeerBrowserViewController: MultipeerConnectivityManagerDelegate {

	func receivedInvitation(fromPeer peer: MCPeerID, context: Data?) {
		let alert = UIAlertController(title: "👋", message: "\(peer.displayName) would like to chat with you!", preferredStyle: UIAlertControllerStyle.alert)
		let accept: UIAlertAction = UIAlertAction(
				title: "Sure!",
				style: UIAlertActionStyle.default
		) { [weak self] _ -> Void in
			self?.appDelegate.connectivityManager.respondToInvitation(accepted: true)
		}
		
		let decline = UIAlertAction(
				title: "Ignore",
				style: UIAlertActionStyle.destructive
		) { [weak self] _ -> Void in
			self?.appDelegate.connectivityManager.respondToInvitation(accepted: false)
		}
		
		alert.addAction(accept)
		alert.addAction(decline)
		
		OperationQueue.main.addOperation { [weak self] in
			self?.present(alert, animated: true, completion: nil)
		}
	}
	
	func failedToConnect(withPeer peer: MCPeerID) {
		let alert = UIAlertController(title: "😞", message: "Failed to initiate chat session.", preferredStyle: UIAlertControllerStyle.alert)
		let accept: UIAlertAction = UIAlertAction(
			title: "OK",
			style: UIAlertActionStyle.default
		)
		
		alert.addAction(accept)
		
		OperationQueue.main.addOperation { [weak self] in
			self?.present(alert, animated: true, completion: nil)
		}
	}
	
	func connected(withPeer peer: MCPeerID) {
		OperationQueue.main.addOperation { [weak self] in
			self?.performSegue(withIdentifier: Constants.Strings.chatScreenSegueString, sender: nil)
		}
	}
	
	func failedToBrowseForPeers(withError error: Error) {
		// TODO: - Show Error Box
	}
	
	func foundPeer(_ peer: MCPeerID) {
		peerTableViewHandler.reloadData(
			foundPeers: appDelegate.connectivityManager.foundPeers
		)
	}
	
	func lostPeer(_ peer: MCPeerID) {
		peerTableViewHandler.reloadData(
			foundPeers: appDelegate.connectivityManager.foundPeers
		)
	}

}
