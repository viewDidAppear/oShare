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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let appDelegate = Constants.appDelegate else { return }
		self.appDelegate = appDelegate
		
		configureTableView()
		configureTextField()
		configureEndChatButton()
		registerKeyboardNotifications()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.hidesBackButton = true
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
	
	private func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.adjustForDisplayKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.adjustForHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	private func configureEndChatButton() {
		let endChatButton = UIBarButtonItem(title: "End", style: .done, target: self, action: #selector(self.endChat(sender:)))
		navigationItem.rightBarButtonItem = endChatButton
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
	
	@IBAction private func endChat(sender: UIBarButtonItem) {
		// For the sake of simplicity, we are only going to support peer-to-peer chat, as opposed to multiple peers in a single chat. This is why I directly access [0] in the list of connected peers.
		let messageDictionary: [String: String] = ["message": "_end_chat_"]
		
		guard let connectedPeer = appDelegate.connectivityManager.session.connectedPeers.first else { return }
		
		if appDelegate.connectivityManager.send(dictionaryWithData: messageDictionary, toPeer: connectedPeer) {
			appDelegate.connectivityManager.session.disconnect()
			appDelegate.connectivityManager.startAdvertising()
			appDelegate.connectivityManager.startBrowsingForDevices()
			
			navigationController?.popViewController(animated: true)
		}
	}
	
	@IBAction private func sendMessage(sender: UIButton?) {
		// Only proceed sending data if the text is not empty.
		guard
			let text = textField.text,
			let peer = appDelegate.connectivityManager.session.connectedPeers.first,
			text.isEmpty == false
			else { return } // Why is the default indentation like this?
		
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
