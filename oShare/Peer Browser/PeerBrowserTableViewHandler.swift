import Foundation
import UIKit
import MultipeerConnectivity

class PeerBrowserTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	// Pass weak instance of parent table view across. We do not own this reference, so it must be both `weak` and Optional.
	weak var tableView: UITableView?
	
	private var foundPeers: [MCPeerID] = []
	
	func reloadData(foundPeers: [MCPeerID]) {
		self.foundPeers = foundPeers

//		tableView?.performBatchUpdates({
//
//		}, completion: { finished in
//
//		})
		
		tableView?.reloadData()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
		
		cell.textLabel?.text = foundPeers[indexPath.row].displayName
		cell.detailTextLabel?.text = "Peer"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return foundPeers.count
	}
}
