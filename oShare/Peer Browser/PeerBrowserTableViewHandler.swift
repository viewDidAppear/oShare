import Foundation
import UIKit
import MultipeerConnectivity

class PeerBrowserTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	// Pass weak instance of parent table view, and app delegate across. We do not own these references, so they must be both `weak` and Optional.
	weak var tableView: UITableView?
	weak var appDelegate: AppDelegate?
	
	// Keep track of the number of peers. Since this is strictly for data display, we don't want to access it outside of this handler.
	private var foundPeers: [MCPeerID] = []
	
	// Some example status messages. Theoretically, a user could set this in their app preferences, to advertise their current status to their team. I shamelessly ripped this idea from WhatsApp, Slack and Skype.
	// Because these messages are accessed randomly, an extremely large font size in Settings can result in the messages changing upon scroll. A full-fledged implementation would not have this issue.
	private let exampleStatusMessages: [String] = ["Hi there, I am using oShare.", "こんにちは、オシャレを使う。", "Probably drinking coffee...", "AFK", "Brb, lunch...", "Debugging a SIGABRT. BBIAB.", "I really, really, really, really, really, really, really, REALLY like long status messages. Like, really, really, really, really, really long status messages. It's such a good test of a UI's ability to handle long text in unexpected places."]

	// MARK: - Reloading
	
	/// Reload the tableView in accordance with the new data. This will trigger a small animation.
	///
	/// - Parameter foundPeers: the new list of peers to populate the table.
	func reloadData(foundPeers: [MCPeerID]) {
		self.foundPeers = foundPeers

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
		
		guard let selectedPeer = appDelegate?.connectivityManager.foundPeers[indexPath.row] else {
			// TODO: - Handle error should this fail.
			return
		}
		
		appDelegate?.connectivityManager.invitePeerToChat(peer: selectedPeer)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
		let randomIndex = Int(arc4random_uniform(UInt32(exampleStatusMessages.count)))
		
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
		cell.textLabel?.text = foundPeers[indexPath.row].displayName
		cell.detailTextLabel?.text = exampleStatusMessages[randomIndex]
		cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foundPeers.count
	}
}
