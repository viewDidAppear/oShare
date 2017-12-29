import XCTest
import MultipeerConnectivity
@testable import oShare

class ChatTableViewHandlerTests: XCTestCase {
	
	private var handler = ChatTableViewHandler()
	private var tableView: UITableView? = UITableView()
	private var appDelegate: AppDelegate?
	
	override func setUp() {
		super.setUp()
		
		appDelegate = UIApplication.shared.delegate as? AppDelegate
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
	
	func testMessageCount() {
		let testMessage = ["message": "Hi", "sender": "self"]
		handler.reloadData(messages: [testMessage])
		
		eventually(timeout: 1) {
			XCTAssert(self.handler.messages.first! == testMessage)
		}
	}
	
	func testSenderSelf() {
		let testMessage = ["message": "Hi", "sender": "self"]
		handler.reloadData(messages: [testMessage])
		let row = self.handler.tableView!.cellForRow(at: IndexPath(item: 0, section: 0))
		
		eventually(timeout: 1) {
			XCTAssert(row?.detailTextLabel?.text == "I said:")
		}
	}
	
	func testSenderForeign() {
		let testMessage = ["message": "Hi", "sender": "notchPhone"]
		handler.reloadData(messages: [testMessage])
		let row = self.handler.tableView!.cellForRow(at: IndexPath(item: 0, section: 0))
		
		eventually(timeout: 1) {
			XCTAssert(row?.detailTextLabel?.text == "notchPhone said:")
		}
	}
	
}

