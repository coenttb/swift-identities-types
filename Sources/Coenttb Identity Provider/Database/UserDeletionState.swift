////
////  File.swift
////  coenttb-web
////
////  Created by Coen ten Thije Boonkkamp on 06/10/2024.
////
//
//import Foundation
//import CasePaths
//
///// Represents the state of a user's account in the user deletion workflow.
/////
///// This enum is used to track the current status of the deletion process, ensuring that actions like deletion requests,
///// grace periods, and final deletion confirmations are handled correctly.
/////
///// - `pending`: Indicates that a deletion request has been made, and the account is currently in a grace period.
/////   The `requestedAt` date represents when the deletion was requested, and the account can still be recovered until the grace period expires.
///// - `deleted`: Indicates that the account has been permanently deleted, and the associated data is no longer recoverable.
///// - `nil`: The `UserDeletionState` is typically used as an optional value, where a `nil` state represents that the user's account is still active
/////   and no deletion process has been initiated.
/////
///// The `UserDeletionState` can be used in the implementation of the user deletion process to manage transitions between
///// active, pending deletion, and permanent deletion.
/////
///// Example Usage:
///// ```
///// var deletionState: UserDeletionState? = nil // User is active
///// deletionState = .pending(requestedAt: Date())
/////
///// if case let .pending(requestedAt) = deletionState {
/////     print("Deletion requested at: \(requestedAt)")
///// }
///// ```
/////
///// - Note: This enum is designed to be used as an optional value. A `nil` value represents that the user account is active and no deletion has been requested.
/////   Additionally, this design is extensible, allowing the state to be integrated into workflows such as database tracking,
/////   scheduled tasks for automatic deletion after a grace period, or providing recovery mechanisms for users.
/////
//@dynamicMemberLookup
//@CasePathable
//public enum UserDeletionState: Codable, Hashable, Sendable {
//    /// Indicates that the user has requested account deletion, and the request was made at the specified `requestedAt` date.
//    /// The account is pending deletion and may be recovered during the grace period.
//    case pending(requestedAt: Date)
//    
//    /// Indicates that the account has been permanently deleted, and any associated user data is no longer accessible.
//    case deleted
//}
