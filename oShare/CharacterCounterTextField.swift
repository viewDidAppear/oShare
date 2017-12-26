import Foundation
import UIKit

@IBDesignable class CharacterCounterTextField: UITextField {
	
	@IBInspectable var characterLimit: Int = 20
	
	private let characterCountLabel = UILabel()
	private let characterCountLabelSize: CGSize = CGSize(width: 30, height: 30)
	private let characterCountLabelXOffset: CGFloat = 35
	
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
			return CGRect(
				origin: CGPoint(x: frame.width-characterCountLabelXOffset, y: 0),
				size: characterCountLabelSize
			)
		} else {
			return CGRect()
		}
	}
}
