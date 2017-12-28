import Foundation
import UIKit

// Define the custom NSNotification into an extension on `.Name` to avoid using the "Stringly-Typed" API for non-predefined notifications.
public extension NSNotification.Name {
	public static let oShareRecivedData = NSNotification.Name("receivedData")
}
