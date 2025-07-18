//
//  Identity.Client.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
   /// A client interface for managing email-related operations.
   ///
   /// The `Email` struct provides functionality for:
   /// - Changing a user's email address
   /// - Verifying email changes through confirmation tokens
   ///
   /// Example usage:
   /// ```swift
   /// let client = Identity.Client.Email(...)
   ///
   /// // Request email change
   /// let result = try await client.change.request("new@example.com")
   ///
   /// // Confirm change with token
   /// let response = try await client.change.confirm("confirmation_token")
   /// ```
   @DependencyClient
   public struct Email: @unchecked Sendable {
       /// Interface for email change operations.
       public var change: Identity.Client.Email.Change = .init()

       public init(change: Identity.Client.Email.Change) {
           self.change = change
       }
   }
}

extension Identity.Client.Email {
   /// Handles the email change process.
   ///
   /// The change process consists of two steps:
   /// 1. Requesting the email change
   /// 2. Confirming the change with a token
   ///
   /// > Important: Email changes require verification to prevent unauthorized changes
   /// and ensure the new email is valid and accessible.
   @DependencyClient
   public struct Change: @unchecked Sendable {
       /// Initiates an email change request.
       ///
       /// This method:
       /// 1. Validates the new email address
       /// 2. Sends a confirmation email
       /// 3. Returns the request result
       ///
       /// - Parameter newEmail: The new email address to change to
       /// - Returns: The result of the change request, indicating success or if re-authentication is required
       public var request: (_ newEmail: String) async throws -> Identity.Email.Change.Request.Result

       /// Confirms an email change with a verification token.
       ///
       /// This method:
       /// 1. Validates the confirmation token
       /// 2. Updates the email address
       /// 3. Returns the confirmation response
       ///
       /// - Parameter token: The verification token from the confirmation email
       /// - Returns: Response containing updated authentication information
       public var confirm: (_ token: String) async throws -> Identity.Email.Change.Confirmation.Response
   }
}

// MARK: - Conveniences
extension Identity.Client.Email.Change {
   /// Convenience method for requesting an email change using a Change Request object.
   ///
   /// - Parameter request: The email change request containing the new email
   /// - Returns: The result of the change request
   public func request(_ request: Identity.Email.Change.Request) async throws -> Identity.Email.Change.Request.Result {
       return try await self.request(newEmail: request.newEmail)
   }
}

extension Identity.Client.Email.Change {
   /// Convenience method for requesting an email change using an EmailAddress object.
   ///
   /// - Parameter newEmail: The new email address
   /// - Returns: The confirmation response
   public func request(_ newEmail: EmailAddress) async throws -> Identity.Email.Change.Confirmation.Response {
       return try await self.confirm(token: newEmail.rawValue)
   }
}

extension Identity.Client.Email.Change {
   /// Convenience method for confirming an email change using a Confirmation object.
   ///
   /// - Parameter confirm: The confirmation details containing the verification token
   /// - Returns: The confirmation response
   public func confirm(_ confirm: Identity.Email.Change.Confirmation) async throws -> Identity.Email.Change.Confirmation.Response {
       return try await self.confirm(token: confirm.token)
   }
}
