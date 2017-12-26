import Foundation
import UIKit
import MultipeerConnectivity

class PeerBrowserTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	// Pass weak instance of parent table view across. We do not own this reference, so it must be both `weak` and Optional.
	weak var tableView: UITableView?
	
	// Keep track of the number of peers. Since this is strictly for data display, we don't want to access it outside of this handler.
	private var foundPeers: [MCPeerID] = []
	
	// Some example status messages. Theoretically, a user could set this in their app preferences, to advertise their current status to their team. I shamelessly ripped this idea from WhatsApp, Slack and Skype.
	private let exampleStatusMessages: [String] = ["Hi there, I am using oShare.", "こんにちは、オシャレを使う。", "Probably drinking coffee...", "AFK", "Brb, lunch...", "Debugging a SIGABRT. BBIAB."]

	// MARK: - Reloading
	
	/// Reload the tableView in accordance with the new data. This will trigger a small animation.
	///
	/// - Parameter foundPeers: the new list of peers to populate the table.
	func reloadData(foundPeers: [MCPeerID]) {
		self.foundPeers = foundPeers

		tableView?.isUserInteractionEnabled = false
		tableView?.performBatchUpdates({ [weak self] in
			self?.tableView?.reloadSections(IndexSet([0]), with: .automatic)
		}, completion: { [weak self] finished in
			self?.tableView?.isUserInteractionEnabled = true
		})
	}
	
	// MARK: - UITableViewDelegate and DataSource Methods
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Constants.Numbers.standardTableViewRowHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		// TODO: - Invite Peer
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
		let randomIndex = Int(arc4random_uniform(UInt32(exampleStatusMessages.count)))
		
		cell.textLabel?.text = foundPeers[indexPath.row].displayName
		cell.detailTextLabel?.text = exampleStatusMessages[randomIndex]
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foundPeers.count
	}
}
