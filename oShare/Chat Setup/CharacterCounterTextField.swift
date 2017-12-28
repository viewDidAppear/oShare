import Foundation
import UIKit

@IBDesignable class CharacterCounterTextField: UITextField {
	
	@IBInspectable var characterLimit: Int = 20
	@IBInspectable var paddingFromEdge: CGFloat = 5
	@IBInspectable var characterCountLabelWidth: CGFloat = 30
	
	private var characterCountLabel = UILabel()
	private var characterCountLabelSize: CGSize = .zero
	private var characterCountLabelXOffset: CGFloat = 0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// The height of the character counting label should always be the height of the parent text field.
		characterCountLabelSize.height = frame.size.height
		
		// Assign the width predetermined in Interface Builder. Otherwise use the default value.
		characterCountLabelSize.width = characterCountLabelWidth
		
		// Apply the offset from the edge of the view. This can be left, or right.
		characterCountLabelXOffset = characterCountLabelWidth+paddingFromEdge
		
		if characterLimit > 0 {
			setCountLabel()
		}
	}
	
	private func setCountLabel() {
		characterCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
		characterCountLabel.textAlignment = .center
		characterCountLabel.text = "0"
		
		// Assumption that the supplementary view will always be on the right. This can be changed to `left` if needed.
		rightView = characterCountLabel
		rightViewMode = .always
	}
	
	func updateWith(count: Int) {
		characterCountLabel.text = "\(count)"
		
		if count > Constants.Numbers.maximumDisplayNameLength || count == 0 {
			// Indicate to the user that this is VERY BAD (i.e. not allowed).
			characterCountLabel.textColor = .red
		} else {
			// If the count is within the limit, indicate that it's OK by remaining black.
			characterCountLabel.textColor = .black
		}
	}
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		// Assumption that the supplementary view will always be on the right. This can be changed to `frame.origin.x+padding` if needed.
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
