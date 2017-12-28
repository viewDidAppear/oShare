import UIKit

/// A simple protocol, in the form of a delegate, to pass along a notification when this view controller is dismissed to its parent. This is because its `next` UIResponder is `nil`.
protocol ChatSetupViewControllerDelegate: class {
	func dismissed()
}

class ChatSetupViewController: UIViewController {

	// As per recent WWDC sessions, IBOutlet properties should be `strong`. I generally prefer to keep them `weak` as old habits die hard, however for standards sake, I'll keep them strong.
	@IBOutlet private var displayNameTextField: CharacterCounterTextField!
	@IBOutlet private var informationLabel: UILabel!
	@IBOutlet private var continueButton: UIBarButtonItem!
	
	// A delegate declaration should always be `weak` and Optional, so as to avoid reference cycles.
	weak var delegate: ChatSetupViewControllerDelegate?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// To display this "partially" over the previous view controller, this needs to be set to prevent the "origin" (during presentation) and "destination" (during dismissal) from being removed.
		modalPresentationStyle = .overCurrentContext
	}
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		registerKeyboardNotifications()
		configureSaveButton()
		configureInformationText()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		configureTextField()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - UI Configuration
	
	private func configureInformationText() {
		// Note that due to the custom presentation of this view controller, responding _live_ to the changes made in Accessibility proved a challenge. For simplicity reasons, I won't handle it, however I will support the preferred font style/size.
		informationLabel.font = UIFont.preferredFont(forTextStyle: .body)
	}
	
	private func configureSaveButton() {
		continueButton.isEnabled = false
	}
	
	private func configureTextField() {
		displayNameTextField.delegate = self
		displayNameTextField.becomeFirstResponder()
		displayNameTextField.updateWith(count: 0)
		
		if let displayName = UserDefaults.standard.value(forKey: "displayName") as? String {
			displayNameTextField.text = displayName
			displayNameTextField.updateWith(count: displayName.count)
			continueButton.isEnabled = true
		}
	}
	
	private func updateCharacterCountLabel(withCount count: Int) {
		// The MCPeerID documentation states that the hard limit for display names is 63 bytes in UTF-8 encoding. I could set the limit to 63 characters, however a user may be partial to using Emoji, or may use a language such as 日本語, which characters have a variable byte length. 20 seems like a safe value here.
		
		continueButton.isEnabled = count <= Constants.Numbers.maximumDisplayNameLength && count > 0
		displayNameTextField.updateWith(count: count)
	}
	
	// MARK: - Notifications
	
	private func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(ChatSetupViewController.adjustForDisplayKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(ChatSetupViewController.adjustForHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc private func adjustForDisplayKeyboard(_ notification: Notification) {
		if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
			UIView.animate(withDuration: 0.5) { [weak self] in
				guard let strongSelf = self else { return }
				strongSelf.view.frame.origin.y = keyboardSize.origin.y - strongSelf.view.frame.size.height
			}
		}
	}
	
	@objc private func adjustForHideKeyboard(_ notification: Notification) {
			UIView.animate(withDuration: 0.5) { [weak self] in
				guard let strongSelf = self else { return }
				strongSelf.view.frame.origin.y = UIScreen.main.bounds.size.height-strongSelf.view.frame.size.height
			}
	}
	
	// MARK: - Call To Action (Save Name)
	
	@IBAction private func saveDisplayName(sender: UIButton) {
		guard let displayName = displayNameTextField.text, displayNameTextField.text?.isEmpty == false else { return }
		
		displayNameTextField.resignFirstResponder()
		
		UserDefaults.standard.set(displayName, forKey: "displayName")
		
		dismiss(animated: true, completion: { [weak self] in
			self?.delegate?.dismissed()
		})
	}
	
}

// MARK: - UITextFieldDelegate

extension ChatSetupViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		
		let newLength = text.utf16.count + string.utf16.count - range.length
		
		updateCharacterCountLabel(withCount: newLength)
		
		return true
	}
}
