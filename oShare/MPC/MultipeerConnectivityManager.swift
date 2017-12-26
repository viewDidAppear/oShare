import MultipeerConnectivity

class MultipeerConnectivityManager: NSObject {
	
	weak var delegate: MultipeerConnectivityManagerDelegate?

	var localPeer: MCPeerID
	var foundPeers: [MCPeerID] = []
	var invitationHandler: ((Bool, MCSession) -> Void)?

	private var connectivityBrowser: MCNearbyServiceBrowser
	private var connectivityAdvertiser: MCNearbyServiceAdvertiser
	
	private(set) var session: MCSession
	
	init(peer: MCPeerID) {
		self.localPeer = peer
		self.session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .optional)
		
		self.connectivityBrowser = MCNearbyServiceBrowser(
			peer: peer,
			serviceType: Constants.Strings.serviceType
		)
		
		self.connectivityAdvertiser = MCNearbyServiceAdvertiser(
			peer: peer,
			discoveryInfo: nil,
			serviceType: Constants.Strings.serviceType
		)

		super.init()

		self.session.delegate = self
		self.connectivityAdvertiser.delegate = self
		self.connectivityBrowser.delegate = self
	}
	
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
		invitationHandler?(accepted, session)
	}
	
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
			// TODO: - Display Indicator?
			break
		default:
			startAdvertising()
			startBrowsingForDevices()

			delegate?.failedToConnect(withPeer: peerID)
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		// TODO: - Handle in next commits
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		// TODO: - Handle in next commits
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		// TODO: - Handle in next commits
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		// TODO: - Handle in next commits
	}

	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		// For the sake of simplicity, I am responding `true` for all cases here.
		certificateHandler(true)
	}

}

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {

	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		guard peerID != localPeer else { return }

		foundPeers.append(peerID)
		delegate?.foundPeer(peerID)
	}

	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		foundPeers = foundPeers.filter({ $0.displayName != peerID.displayName })
		delegate?.lostPeer(peerID)
	}

}

extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {

	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		// We're going to ask the user if they'd like to chat with us. So, we'll store this temporarily.
		self.invitationHandler = invitationHandler

		delegate?.receivedInvitation(fromPeer: peerID, context: context)
	}

}
