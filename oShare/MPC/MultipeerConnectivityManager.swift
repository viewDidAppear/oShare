import MultipeerConnectivity

class MultipeerConnectivityManager: NSObject {
	
	weak var delegate: MultipeerConnectivityManagerDelegate?

	var localPeer: MCPeerID
	var foundPeers: [MCPeerID] = []
	var invitationHandler: ((Bool, MCSession) -> Void)?

	private var connectivityBrowser: MCNearbyServiceBrowser
	private var connectivityAdvertiser: MCNearbyServiceAdvertiser
	private(set) var session: MCSession
	
	// MARK: - Initialization
	
	init(peer: MCPeerID) {
		self.localPeer = peer
		self.session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .optional)
		
		self.connectivityBrowser = MCNearbyServiceBrowser(
			peer: peer,
			serviceType: Constants.Strings.serviceTypeString
		)
		
		self.connectivityAdvertiser = MCNearbyServiceAdvertiser(
			peer: peer,
			discoveryInfo: nil,
			serviceType: Constants.Strings.serviceTypeString
		)

		super.init()

		self.session.delegate = self
		self.connectivityAdvertiser.delegate = self
		self.connectivityBrowser.delegate = self
	}
	
	// MARK: - Helper Functions
	
	func startBrowsingForDevices() {
		connectivityBrowser.startBrowsingForPeers()
		delegate?.beganBrowsing()
	}
	
	func stopBrowsingForDevices() {
		connectivityBrowser.stopBrowsingForPeers()
		delegate?.stoppedBrowsing()
	}
	
	func startAdvertising() {
		connectivityAdvertiser.startAdvertisingPeer()
		delegate?.beganAdvertising()
	}
	
	func stopAdvertising() {
		connectivityAdvertiser.stopAdvertisingPeer()
		delegate?.stoppedAdvertising()
	}
	
	func invitePeerToChat(peer: MCPeerID) {
		connectivityBrowser.invitePeer(
			peer,
			to: session,
			withContext: nil,
			timeout: Constants.Numbers.standardInvitationTimeout
		)
	}
	
	func respondToInvitation(accepted: Bool) {
		// Trigger the invitation callback with our response.
		invitationHandler?(accepted, session)
	}
	
	// MARK: - Send Data
	
	func send(dictionaryWithData dictionary: [String: String], toPeer targetPeer: MCPeerID) -> Bool {
		let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
		
		do {
			try session.send(dataToSend, toPeers: [targetPeer], with: .reliable)
		} catch {
			// TODO: - Handle Data Transmission Failure
			return false
		}
		
		return true
	}
	
}

extension MultipeerConnectivityManager: MCSessionDelegate {
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		// In the event we failed to browse for nearby people, we should let the user know.
		delegate?.failedToBrowseForPeers(withError: error)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			// A quirk in MultipeerConnectivity I discovered, is that once you're connected, and for some reason the peerID changes, you can very easily wind up with a failed connection. Ceasing advertising and browsing upon connection resolves this.
			stopAdvertising()
			stopBrowsingForDevices()

			delegate?.connected(withPeer: peerID)
		case .connecting:
			// In most cases tested, "connecting" only lasts for a split second, or a couple of seconds at worst.
			// As such, I decided to not implement a loading indicator.
			break
		default: break
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		// Assemble a dictionary with the data received. I opted to use a dictionary in order to namespace the objects.

		let dictionary: [String: Any] = [DictionaryKeys.data.rawValue: data, DictionaryKeys.peer.rawValue: peerID]
		NotificationCenter.default.post(name: NSNotification.Name.oShareRecivedData, object: dictionary)
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		// Not implemented. Delegate method required.
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		// Not implemented. Delegate method required.
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		// Not implemented. Delegate method required.
	}

	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		// For the sake of simplicity, I am responding `true` for all cases here.
		// It simply sends acknowledgement that contact was made. If I return false here, or ignore it, the connection does not succeed.
		certificateHandler(true)
	}

}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {

	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		// Make sure that we don't re-add the same peer.
		guard foundPeers.contains(peerID) == false else { return }

		// Make sure ourselves don't appear in the list, even for a second.
		// This seemed to happen on iOS 11.2, but not in 11.2.1. Better safe than sorry.
		foundPeers = foundPeers.filter { $0 != localPeer }
		foundPeers.append(peerID)
		delegate?.foundPeer(peerID)
	}

	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		foundPeers = foundPeers.filter { $0 != peerID && $0 != localPeer }
		delegate?.lostPeer(peerID)
	}

}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {

	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {

		// We're going to ask the user if they'd like to chat with us. So, we'll store this temporarily.

		self.invitationHandler = invitationHandler
		delegate?.receivedInvitation(fromPeer: peerID, context: context)
	}

}

// MARK: - DictionaryKeys Enum

private enum DictionaryKeys: String {
	case peer
	case data
}
