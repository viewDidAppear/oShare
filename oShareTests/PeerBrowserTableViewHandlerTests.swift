import XCTest
import MultipeerConnectivity
@testable import oShare

class PeerBrowserTableViewHandlerTests: XCTestCase {
	
	private var handler = PeerBrowserTableViewHandler()
	private var tableView: UITableView? = UITableView()
	private var appDelegate: AppDelegate?
	
	override func setUp() {
		super.setUp()
		
		appDelegate = UIApplication.shared.delegate as? AppDelegate
		tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
		tableView?.delegate = handler
		tableView?.dataSource = handler
		handler.appDelegate = appDelegate!
		handler.tableView = tableView!
	}
	
	override func tearDown() {
		tableView = nil
		appDelegate = nil
		
		super.tearDown()
	}
	
	func testPeerCount() {
		let testPeer = MCPeerID(displayName: "Testy McTesterson")
		handler.reloadData(foundPeers: [testPeer])
		
		eventually(timeout: 1) {
			XCTAssert(self.handler.foundPeers == [testPeer])
		}
	}
	
	func testRowCount() {
		let testPeer = MCPeerID(displayName: "Testy McTesterson")
		handler.reloadData(foundPeers: [testPeer])
		
		eventually(timeout: 1) {
			XCTAssert(self.tableView?.numberOfRows(inSection: 0) == 1)
		}
	}
	
	func testFoundPeer() {
		let testPeer = MCPeerID(displayName: "Testy McTesterson")
		handler.reloadData(foundPeers: [testPeer])
		
		eventually(timeout: 1) {
			let row = self.tableView?.cellForRow(at: IndexPath(row: 0, section: 0))
			XCTAssert(row?.textLabel?.text == testPeer.displayName)
		}
	}
	
	func testDynamicRowHeight() {
		let testPeer = MCPeerID(displayName: "Testy McTesterson")
		handler.reloadData(foundPeers: [testPeer])
		
		eventually(timeout: 1) {
			XCTAssert(self.tableView!.rowHeight == UITableViewAutomaticDimension)
		}
	}
	
}
