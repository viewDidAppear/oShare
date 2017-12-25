import UIKit

class PeerBrowserViewController: UIViewController {
	
	@IBOutlet var peerTableView: UITableView!
	@IBOutlet var discoverabilitySwitch: UISwitch!
	
	private let transitionAnimator = SheetAnimator()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkDisplayName()
	}
	
	private func checkDisplayName() {
		guard let setupViewController = Constants.mainStoryboard.instantiateViewController(withIdentifier: "setupViewController") as? ChatSetupViewController else { return }
		setupViewController.transitioningDelegate = self
		setupViewController.delegate = self
		
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 0.6
		})
		
		present(setupViewController, animated: true, completion: nil)
	}
	
}

extension PeerBrowserViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transitionAnimator.isPresenting = true
		return transitionAnimator
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transitionAnimator.isPresenting = false
		return transitionAnimator
	}
}

extension PeerBrowserViewController: ChatSetupViewControllerDelegate {
	func dismissed() {
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			self?.view.alpha = 1.0
		})
	}
}
