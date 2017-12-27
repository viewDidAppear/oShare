import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController {
	
	// This constraint will be used to adjust the UI in response to the keyboard being displayed/hidden.
	@IBOutlet private var bottomConstraint: NSLayoutConstraint!
	@IBOutlet private var textField: UITextField!
	@IBOutlet private var tableView: UITableView!
	
	private var appDelegate: AppDelegate!
	private var messages: [Dictionary<String, String>] = []
	private let chatTableViewHandler = ChatTableViewHandler()
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let appDelegate = Constants.appDelegate else { return }
		self.appDelegate = appDelegate
		
		configureTableView()
		configureTextField()
		configureEndChatButton()
		configureNavigationBar()
		registerKeyboardNotifications()
		registerDataReceivedNotification()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.hidesBackButton = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Notifications
	
	private func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.adjustForDisplayKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.adjustForHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	private func registerDataReceivedNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleDataReceived(notification:)), name: NSNotification.Name.oShareRecivedData, object: nil)
	}
	
	// MARK: - UI Configuration
	
	private func configureNavigationBar() {
		guard let peer = appDelegate.connectivityManager.session.connectedPeers.first else { return }
		navigationItem.title = "\(peer.displayName)"
	}
	
	private func configureTableView() {
		chatTableViewHandler.appDelegate = appDelegate
		chatTableViewHandler.tableView = tableView
		tableView.delegate = chatTableViewHandler
		tableView.dataSource = chatTableViewHandler
	}
	
	private func configureTextField() {
		textField.delegate = self
		textField.becomeFirstResponder()
	}
	
	private func configureEndChatButton() {
		let endChatButton = UIBarButtonItem(title: "End", style: .done, target: self, action: #selector(self.endChat(sender:)))
		navigationItem.rightBarButtonItem = endChatButton
	}
	
	// MARK: - Data
	
	@objc private func handleDataReceived(notification: Notification) {
		guard
			let object = notification.object as? [String: Any],
			let data = object["data"] as? Data,
			let peer = object["peer"] as? MCPeerID,
			let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String]
			else { return }
		
		if let message = message["message"] {
			if message != Constants.Strings.endChatCodeString {
				let messageDictionary: [String: String] = ["sender": peer.displayName, "message": message]
				messages.append(messageDictionary)
				
				OperationQueue.main.addOperation { [weak self] () -> Void in
					guard let strongSelf = self else { return }
					strongSelf.chatTableViewHandler.reloadData(messages: strongSelf.messages)
				}
			} else {
				// If we receive the pre-set end chat code, we should be told that the peer ended the chat.
				// Randomly backing out of the chat screen could be quite confusing otherwise.
				handleChatEnded(peer)
			}
		}
	}
	
	private func handleChatEnded(_ peer: MCPeerID) {
		let alert = UIAlertController(title: "👋", message: "\(peer.displayName) ended the chat.", preferredStyle: .alert)
		let doneAction: UIAlertAction = UIAlertAction(title: "Close", style: .default) { [weak self] (action) in
			self?.appDelegate.connectivityManager.session.disconnect()
			self?.navigationController?.popViewController(animated: true)
		}
		
		alert.addAction(doneAction)
		
		OperationQueue.main.addOperation { [weak self] () -> Void in
			self?.present(alert, animated: true, completion: nil)
		}
	}
	
	// MARK: - Keyboard Adjustments
	
	@objc private func adjustForDisplayKeyboard(_ notification: Notification) {
		if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
			bottomConstraint.constant = keyboardSize.size.height-(Constants.appDelegate?.window?.safeAreaInsets.bottom ?? 0)
			UIView.animate(withDuration: 0.5) { [weak self] in
				guard let strongSelf = self else { return }
				strongSelf.view.setNeedsLayout()
				strongSelf.view.layoutIfNeeded()
			}
		}
	}
	
	@objc private func adjustForHideKeyboard(_ notification: Notification) {
		bottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5) { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.view.setNeedsLayout()
			strongSelf.view.layoutIfNeeded()
		}
	}
	
	// MARK: - End Chat
	
	@IBAction private func endChat(sender: UIBarButtonItem?) {
		// For the sake of simplicity, we are only going to support peer-to-peer chat, as opposed to multiple peers in a single chat. This is why I directly access [0] in the list of connected peers.
		let messageDictionary: [String: String] = ["sender": "self", "message": Constants.Strings.endChatCodeString]
		let waitTimeBeforeDisconnection: TimeInterval = 2
		
		guard let connectedPeer = appDelegate.connectivityManager.session.connectedPeers.first else { return }
		
		if appDelegate.connectivityManager.send(dictionaryWithData: messageDictionary, toPeer: connectedPeer) {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+waitTimeBeforeDisconnection, execute: { [weak self] in
					self?.appDelegate.connectivityManager.session.disconnect()
					self?.appDelegate.connectivityManager.startAdvertising()
					self?.appDelegate.connectivityManager.startBrowsingForDevices()
					self?.navigationController?.popViewController(animated: true)
			})
		}
	}
	
	// MARK: - Send Message
	
	@IBAction private func sendMessage(sender: UIButton?) {
		// Only proceed sending data if the text is not empty, and if there is still a connected peer.
		guard
			let text = textField.text,
			let peer = appDelegate.connectivityManager.session.connectedPeers.first,
			text.isEmpty == false
			else { return }
		
		let messageData: [String: String] = ["sender": "self", "message": text]
		
		if appDelegate.connectivityManager.send(dictionaryWithData: messageData, toPeer: peer) {
			messages.append(messageData)
			chatTableViewHandler.reloadData(messages: messages)
		} else {
			// TODO: - Handle Failure
		}
		
		textField.text = ""
	}
	
}

extension ChatViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		sendMessage(sender: nil)
		
		return true
	}

}
