@testable import oShare
import XCTest
import Foundation
import UIKit
import MultipeerConnectivity

class MultipeerConnectivityManagerTests: XCTestCase {
	private var manager: MultipeerConnectivityManager!
	
	override func setUp() {
		super.setUp()
		
		let localPeer = MCPeerID(displayName: "Local")
		manager = MultipeerConnectivityManager(peer: localPeer)
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testFoundPeer() {
		let testNewPeer = MCPeerID(displayName: "New")
		manager.browser(manager.connectivityBrowser, foundPeer: testNewPeer, withDiscoveryInfo: nil)
		
		eventually(timeout: 1) {
			XCTAssert(self.manager.foundPeers.count == 1)
			XCTAssert(self.manager.foundPeers[0].displayName == "New")
		}
	}
	
	func testLostPeer() {
		let currentPeers = [MCPeerID(displayName: "Old"), MCPeerID(displayName: "New")]
		manager.foundPeers = currentPeers
		manager.browser(manager.connectivityBrowser, lostPeer: currentPeers.last!)
		
		eventually(timeout: 1) {
			XCTAssert(self.manager.foundPeers.count == 1)
			XCTAssert(self.manager.foundPeers[0].displayName == "Old")
		}
	}
	
	func testDataReceived() {
		let testNewPeer = MCPeerID(displayName: "New")
		manager.session(manager.session, didReceive: Data(), fromPeer: testNewPeer)
		
		expectation(forNotification: NSNotification.Name.oShareRecivedData, object: nil, handler: nil)
		NotificationCenter.default.post(name: NSNotification.Name.oShareRecivedData, object: nil)
		waitForExpectations(timeout: 1, handler: nil)
	}
}
