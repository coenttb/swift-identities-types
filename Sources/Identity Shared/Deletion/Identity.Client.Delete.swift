//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
   /// A client interface for handling identity deletion requests.
   ///
   /// The `Delete` struct manages the secure, multi-step process of deleting user identities:
   /// 1. Requesting deletion (requires re-authentication)
   /// 2. Confirming or canceling the deletion request
   ///
   /// > Important: Identity deletion is irreversible once confirmed. The multi-step process
   /// helps prevent accidental deletions.
   ///
   /// Example usage:
   /// ```swift
   /// let client = Identity.Client.Delete(...)
   ///
   /// // Request identity deletion
   /// try await client.request(reauthToken: "reauth_token")
   ///
   /// // Later, either confirm or cancel
   /// try await client.confirm() // Permanently deletes identity
   /// // or
   /// try await client.cancel()  // Cancels deletion request
   /// ```
   @DependencyClient
   public struct Delete: @unchecked Sendable {
       /// Initiates the identity deletion process.
       ///
       /// This method begins the identity deletion flow by:
       /// 1. Validating the re-authentication token
       /// 2. Creating a pending deletion request
       /// 3. Setting the identity status to pending deletion
       ///
       /// - Parameter reauthToken: A fresh authentication token to verify the user's identity
       public var request: (
           _ reauthToken: String
       ) async throws -> Void

       /// Cancels a pending identity deletion request.
       ///
       /// This method:
       /// 1. Removes the pending deletion status
       /// 2. Restores the identity to normal operation
       public var cancel: () async throws -> Void

       /// Confirms and executes identity deletion.
       ///
       /// > Warning: This operation is irreversible. Once confirmed, the identity
       /// and all associated data will be permanently deleted.
       ///
       /// This method:
       /// 1. Verifies the deletion request is still valid
       /// 2. Permanently deletes the identity and all associated data
       /// 3. Invalidates all authentication tokens
       public var confirm: () async throws -> Void
   }
}

extension Identity.Client.Delete {
   /// Convenience method for requesting identity deletion using a Deletion Request object.
   ///
   /// - Parameter request: The deletion request containing the re-authentication token
   public func request(_ request: Identity.Deletion.Request) async throws {
       try await self.request(reauthToken: request.reauthToken)
   }
}
