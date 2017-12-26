import UIKit
import Foundation

class SheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var isPresenting = true
	
	private var popoverHeight: CGFloat = 0
	private var originFrame = CGRect(
		x: 0,
		y: UIScreen.main.bounds.size.height,
		width: UIScreen.main.bounds.size.width,
		height: Constants.Numbers.displayNamePopoverHeight
	)
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return Constants.Numbers.displayNamePopoverTransitionDuration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let bottomInset = Constants.appDelegate?.window?.safeAreaInsets.bottom ?? 0
		
		// We want to ensure we actually have a destination.
		guard let sheetView = isPresenting ? transitionContext.view(forKey: .to) : transitionContext.view(forKey: .from) else { return }
		
		popoverHeight = sheetView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.size.width, height: 100), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
		
		sheetView.frame.size.height = popoverHeight+bottomInset
		
		if isPresenting {
			sheetView.frame.origin.y = originFrame.origin.y
		}

		containerView.addSubview(sheetView)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [weak self] in
			guard let strongSelf = self else { return }
			
			if strongSelf.isPresenting {
				sheetView.frame.origin.y = UIScreen.main.bounds.size.height-(strongSelf.popoverHeight+bottomInset)
			} else {
				sheetView.frame.origin.y = strongSelf.originFrame.origin.y
			}
		}, completion: { _ in
			transitionContext.completeTransition(true)
		})
	}
}
