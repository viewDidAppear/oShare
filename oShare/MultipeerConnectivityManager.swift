import MultipeerConnectivity

class MultipeerConnectivityManager: NSObject {
	
	weak var delegate: MultipeerConnectivityManagerDelegate?

	var peer: MCPeerID
	var foundPeers: [MCPeerID] = []
	var invitationHandler: ((Bool, MCSession) -> Void)?

	private var session: MCSession
	private var connectivityBrowser: MCNearbyServiceBrowser
	private var connectivityAdvertiser: MCNearbyServiceAdvertiser
	
	init(peer: MCPeerID) {
		self.peer = peer
		self.session = MCSession(peer: peer)
		
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
	
}

extension MultipeerConnectivityManager: MCSessionDelegate {

	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		delegate?.failedToBrowseForPeers(withError: error)
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		// TODO: - Handle in next commits
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
		// TODO: - Handle in next commits
	}

}

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {

	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
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
		delegate?.receivedInvitation(fromPeer: peerID, context: context)
	}

}
