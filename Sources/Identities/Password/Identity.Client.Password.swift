//
//  Identity.Client.Password.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
   /// A client interface for managing password operations.
   ///
   /// The `Password` struct provides two main sets of functionality:
   /// - Password reset for forgotten passwords
   /// - Password change for authenticated users
   ///
   /// Example usage:
   /// ```swift
   /// let client = Identity.Client.Password(...)
   ///
   /// // Reset forgotten password
   /// try await client.reset.request("user@example.com")
   /// try await client.reset.confirm("newPassword123", "reset_token")
   ///
   /// // Change password while authenticated
   /// try await client.change.request("currentPass", "newPass123")
   /// ```
   @DependencyClient
   public struct Password: @unchecked Sendable {
       /// Interface for password reset operations.
       public var reset: Password.Reset
       
       /// Interface for password change operations.
       public var change: Password.Change

       /// Creates a new Password client with the specified handlers.
       ///
       /// - Parameters:
       ///   - reset: The handler for password reset operations
       ///   - change: The handler for password change operations
       public init(reset: Password.Reset, change: Password.Change) {
           self.reset = reset
           self.change = change
       }
   }
}

extension Identity.Client.Password {
   /// Handles the password reset process for forgotten passwords.
   ///
   /// The reset process consists of two steps:
   /// 1. Requesting a reset (sends email with token)
   /// 2. Confirming the reset with the token and new password
   ///
   /// > Important: Password resets require email verification to prevent
   /// unauthorized access to identities.
   @DependencyClient
   public struct Reset: @unchecked Sendable {
       /// Initiates a password reset request.
       ///
       /// This method:
       /// 1. Validates the email address
       /// 2. Generates a reset token
       /// 3. Sends a reset email
       ///
       /// - Parameter email: The email address of the identity
       public var request: (_ email: String) async throws -> Void

       /// Confirms a password reset with a verification token.
       ///
       /// This method:
       /// 1. Validates the reset token
       /// 2. Updates the password
       /// 3. Invalidates all existing sessions
       ///
       /// - Parameters:
       ///   - newPassword: The new password to set
       ///   - token: The verification token from the reset email
       public var confirm: (_ newPassword: String, _ token: String) async throws -> Void
   }
}

extension Identity.Client.Password {
   /// Handles password changes for authenticated users.
   ///
   /// > Important: Password changes require the current password to verify
   /// the user's identity.
   @DependencyClient
   public struct Change: @unchecked Sendable {
       /// Changes the password for an authenticated user.
       ///
       /// This method:
       /// 1. Verifies the current password
       /// 2. Validates the new password
       /// 3. Updates the password
       ///
       /// - Parameters:
       ///   - currentPassword: The user's current password
       ///   - newPassword: The new password to set
       public var request: (_ currentPassword: String, _ newPassword: String) async throws -> Void
   }
}

extension Identity.Client.Password.Reset {
   /// Convenience method for requesting a password reset using a Reset Request object.
   ///
   /// - Parameter request: The reset request containing the identity's email
   public func request(_ request: Identity.Password.Reset.Request) async throws {
       try await self.request(email: request.email)
   }
}

extension Identity.Client.Password.Reset {
   /// Convenience method for confirming a password reset using a Reset Confirm object.
   ///
   /// - Parameter confirm: The confirmation details containing the new password and token
   public func confirm(_ confirm: Identity.Password.Reset.Confirm) async throws {
       try await self.confirm(newPassword: confirm.newPassword, token: confirm.token)
   }
}

extension Identity.Client.Password.Change {
   /// Convenience method for requesting a password change using a Change Request object.
   ///
   /// - Parameter request: The change request containing current and new passwords
   public func request(_ request: Identity.Password.Change.Request) async throws {
       try await self.request(
           currentPassword: request.currentPassword,
           newPassword: request.newPassword
       )
   }
}
