import Foundation
import UIKit

@IBDesignable class CharacterCounterTextField: UITextField {
	
	@IBInspectable var characterLimit: Int = 20
	
	private let characterCountLabel = UILabel()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if characterLimit > 0 {
			setCountLabel()
		}
	}
	
	private func setCountLabel() {
		characterCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
		characterCountLabel.textAlignment = .center
		characterCountLabel.text = "0"
		
		rightView = characterCountLabel
		rightViewMode = .always
	}
	
	func updateWith(count: Int) {
		characterCountLabel.text = "\(count)"
		
		if count > Constants.Numbers.maximumDisplayNameLength || count == 0 {
			characterCountLabel.textColor = .red
		} else {
			characterCountLabel.textColor = .black
		}
	}
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		if characterLimit > 0 {
			return CGRect(x: frame.width-35, y: 0, width: 30, height:
				30)
		} else {
			return CGRect()
		}
	}
}
