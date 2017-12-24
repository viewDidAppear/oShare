/// An enum to keep track of any errors that happen across the internals of the application.
///
/// - internalFailure: thrown when preconditions are not met, for any reason.
/// - peerHasNoName: thrown if the user sets their display name to an empty string.
enum MultipeerConnectivityError: Error {

	case internalFailure
	case peerHasNoName

}
