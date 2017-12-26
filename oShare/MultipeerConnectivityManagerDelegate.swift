import MultipeerConnectivity

/// This protocol simplifies tracking various events in the application.
/// It is class-bound, so this protocol cannot apply to `struct` or `enum` types.

protocol MultipeerConnectivityManagerDelegate: class {
	
	/// This function will be triggered whenever a peer is discovered.
	///
	/// - Parameter peer: the peer we just discovered.
	func foundPeer(_ peer: MCPeerID)
	
	/// This function will be triggered whenever we lose a peer.
	///
	/// - Parameter peer: the peer we just lost.
	func lostPeer(_ peer: MCPeerID)
	
	/// This function will be triggered whenever we receive an invitation to chat from a peer.
	///
	/// - Parameter peer: the peer who wishes to connect with us.
	/// - Parameter context: any contextual data from the peer who wishes to connect with us.
	func receivedInvitation(fromPeer peer: MCPeerID, context: Data?)
	
	/// This function will be triggered whenever we successfully connect with a peer.
	///
	/// - Parameter peer: the peer who we successfully connected with.
	func connected(withPeer peer: MCPeerID)
	
	/// This function will be triggred whenever we unsuccessfully attempt to browse for peers.
	func failedToBrowseForPeers(withError error: Error)
	
	/// This function will be triggered whenever we start advertising ourselves to nearby peers.
	func beganAdvertising()
	
	/// This function will be triggered whenever we stop advertising ourselves to nearby peers.
	func stoppedAdvertising()
	
	/// This function will be triggered whenever we start browsing for nearby peers.
	func beganBrowsing()
	
	/// This function will be triggered whenever we stop browsing for nearby peers.
	func stoppedBrowsing()

}
