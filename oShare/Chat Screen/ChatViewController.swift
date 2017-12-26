import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController {
	
	private var appDelegate: AppDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let appDelegate = Constants.appDelegate else { return }
		self.appDelegate = appDelegate
		
		configureEndChatButton()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.hidesBackButton = true
	}
	
	private func configureEndChatButton() {
		let endChatButton = UIBarButtonItem(title: "End", style: .done, target: self, action: #selector(self.endChat(sender:)))
		navigationItem.rightBarButtonItem = endChatButton
	}
	
	@IBAction private func endChat(sender: UIBarButtonItem) {
		// For the sake of simplicity, we are only going to support peer-to-peer chat, as opposed to multiple peers in a single chat. This is why I directly access [0] in the list of connected peers.
		let messageDictionary: [String: String] = ["message": "_end_chat_"]
		
		if appDelegate.connectivityManager.send(dictionaryWithData: messageDictionary, toPeer: appDelegate.connectivityManager.session.connectedPeers[0]) {
			appDelegate.connectivityManager.session.disconnect()
			appDelegate.connectivityManager.startAdvertising()
			appDelegate.connectivityManager.startBrowsingForDevices()
			
			navigationController?.popViewController(animated: true)
		}
	}
	
}
