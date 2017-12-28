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
	
	/// This function will be triggered whenever we unsuccessfully attempt to connect with a peer.
	///
	/// - Parameter peer: the peer who we did not connect with.
	func failedToConnect(withPeer peer: MCPeerID)
	
	/// This function will be triggred whenever we unsuccessfully attempt to browse for peers.
	func failedToBrowseForPeers(withError error: Error)

}
