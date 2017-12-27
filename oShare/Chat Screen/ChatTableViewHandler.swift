import Foundation
import UIKit
import MultipeerConnectivity

class ChatTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	// Pass weak instance of parent table view, and app delegate across. We do not own these references, so they must be both `weak` and Optional.
	weak var tableView: UITableView?
	weak var appDelegate: AppDelegate?
	
	// Keep track of the messages. Since this is strictly for data display, we don't want to access it outside of this handler.
	private var messages: [Dictionary<String, String>] = []
	private let messageCellIdentifier: String = "MessageCell"
	
	// MARK: - Reloading
	
	/// Reload the tableView in accordance with the new data. This will trigger a small animation.
	///
	/// - Parameter foundPeers: the new list of peers to populate the table.
	func reloadData(messages: [Dictionary<String, String>]) {
		guard let tableView = tableView else { return }
		self.messages = messages

		tableView.tableFooterView = UIView()
		
		// Set a height of 60pt as the default base value to estimate from.
		tableView.estimatedRowHeight = Constants.Numbers.standardTableViewRowHeight
		
		// Disable interaction while we reload data, and re-enable it after we're done.
		tableView.isUserInteractionEnabled = false
		tableView.performBatchUpdates({
			tableView.reloadSections(IndexSet([0]), with: .automatic)
		}, completion: { _ in
			tableView.isUserInteractionEnabled = true
		})
		
		// Ensure the "last" (most recent) message is always visible.
		if tableView.contentSize.height > tableView.frame.size.height {
			tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
		}
	}
	
	// MARK: - UITableViewDelegate and DataSource Methods
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath)
		let message = messages[indexPath.row][DictionaryKeys.message.rawValue]
		let sender = messages[indexPath.row][DictionaryKeys.sender.rawValue] ?? Constants.Strings.theySaidString
		let senderLabelText: String
		let senderColor: UIColor
		
		if sender == Constants.Strings.selfSenderString {
			senderLabelText = "I said:"
			senderColor = UIColor.purple
		} else {
			senderLabelText = "\(sender) said:"
			senderColor = UIColor.orange
		}
		
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
		cell.textLabel?.text = message
		cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
		cell.detailTextLabel?.text = senderLabelText
		cell.detailTextLabel?.textColor = senderColor
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
}

private enum DictionaryKeys: String {
	case sender
	case message
}
