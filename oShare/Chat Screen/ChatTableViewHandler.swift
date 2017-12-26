import Foundation
import UIKit
import MultipeerConnectivity

class ChatTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	// Pass weak instance of parent table view, and app delegate across. We do not own these references, so they must be both `weak` and Optional.
	weak var tableView: UITableView?
	weak var appDelegate: AppDelegate?
	
	// Keep track of the messages. Since this is strictly for data display, we don't want to access it outside of this handler.
	private var messages: [Dictionary<String, String>] = []
	
	// MARK: - Reloading
	
	/// Reload the tableView in accordance with the new data. This will trigger a small animation.
	///
	/// - Parameter foundPeers: the new list of peers to populate the table.
	func reloadData(messages: [Dictionary<String, String>]) {
		self.messages = messages
		// I dislike the extraneous separator lines beneath the actual, populated data. This hides them.
		tableView?.tableFooterView = UIView()
		
		// Set a height of 60pt as the default base value to estimate from.
		tableView?.estimatedRowHeight = Constants.Numbers.standardTableViewRowHeight
		
		// Disable interaction while we reload data, and re-enable it after we're done.
		tableView?.isUserInteractionEnabled = false
		tableView?.performBatchUpdates({ [weak self] in
			self?.tableView?.reloadSections(IndexSet([0]), with: .automatic)
			}, completion: { [weak self] finished in
				self?.tableView?.isUserInteractionEnabled = true
		})
	}
	
	// MARK: - UITableViewDelegate and DataSource Methods
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
		let message = messages[indexPath.row]["message"]
		let sender = messages[indexPath.row]["sender"]
		
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
		cell.textLabel?.text = message
		cell.detailTextLabel?.text = sender
		cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
		cell.textLabel?.textAlignment = sender == "self" ? .right : .left
		cell.detailTextLabel?.textAlignment = sender == "self" ? .right : .left
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
}

