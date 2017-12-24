import UIKit

class ChatSetupViewController: UIViewController {

	// As per recent WWDC sessions, IBOutlet properties should be `strong`. I generally prefer to keep them `weak` as old habits die hard.
	@IBOutlet var displayNameTextField: UITextField!
	@IBOutlet var displayNameCharacterCountLabel: UILabel!
	@IBOutlet var continueButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		displayNameTextField.delegate = self
	}
	
	@IBAction private func saveDisplayName(sender: UIButton) {
		
	}
	
	private func updateCharacterCountLabel(withCount count: Int) {
		// The MCPeerID documentation states that the hard limit for display names is 63 bytes in UTF-8 encoding. I could set the limit to 63 characters, however a user may be partial to using Emoji, or may use a language such as 日本語, which characters have a variable byte length. 20 seems like a safe value here.
		
		continueButton.isEnabled = count <= 20
		displayNameCharacterCountLabel.textColor = count > 20 ? .red : .black
	}
	
}

extension ChatSetupViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		updateCharacterCountLabel(withCount: string.count)
		
		return true
	}
}
