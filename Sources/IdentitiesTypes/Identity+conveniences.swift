//
//  Identity+conveniences.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Foundation
import JWT

extension Identity {
  /// Convenience method to authenticate an identity with username and password credentials.
  ///
  /// - Parameters:
  ///   - username: The user's email address or username
  ///   - password: The user's password
  /// - Returns: An authentication response containing access and refresh tokens
  public func login(
    username: String,
    password: String
  ) async throws -> Identity.Authentication.Response {
    try await self.authenticate.client.credentials(username: username, password: password)
  }

  /// Convenience method to authenticate an identity with an access token.
  ///
  /// - Parameter accessToken: A valid JWT access token
  public func login(accessToken: String) async throws {
    try await self.authenticate.token.access(accessToken)
  }

  public func login(refreshToken: String) async throws -> Identity.Authentication.Response {
    try await self.authenticate.token.refresh(refreshToken)
  }

  /// Convenience method to authenticate an identity with an API key.
  ///
  /// - Parameter apiKey: A valid API key
  /// - Returns: An authentication response containing access and refresh tokens
  public func login(apiKey: String) async throws -> Identity.Authentication.Response {
    try await self.authenticate.client.apiKey(apiKey: apiKey)
  }
}

extension Identity {
  public func logout() async throws {
    try await self.logout.client.current()
  }
}

extension Identity.Creation {
  /// Convenience method to request identity creation without accessing client.
  ///
  /// - Parameters:
  ///   - email: The email address for the new identity
  ///   - password: The password for the new identity
  public func request(email: String, password: String) async throws {
    try await self.client.request(email: email, password: password)
  }

  /// Convenience method to request identity creation using a Request object without accessing client.
  ///
  /// - Parameter request: The identity creation request
  public func request(_ request: Identity.Creation.Request) async throws {
    try await self.client.request(request)
  }

  /// Convenience method to verify email without accessing client.
  ///
  /// - Parameters:
  ///   - email: The email address being verified
  ///   - token: The verification token from the email
  public func verify(email: String, token: String) async throws {
    try await self.client.verify(email: email, token: token)
  }

  /// Convenience method to verify email using a Verification object without accessing client.
  ///
  /// - Parameter verification: The verification details
  public func verify(_ verification: Identity.Creation.Verification) async throws {
    try await self.client.verify(verification)
  }
}

extension Identity.Password.Reset {
  /// Convenience method to request password reset without accessing client.
  ///
  /// - Parameter email: The email address of the identity
  public func request(email: String) async throws {
    try await self.client.request(email: email)
  }

  /// Convenience method to request password reset using a Request object without accessing client.
  ///
  /// - Parameter request: The reset request
  public func request(_ request: Identity.Password.Reset.Request) async throws {
    try await self.client.request(request)
  }

  /// Convenience method to confirm password reset without accessing client.
  ///
  /// - Parameters:
  ///   - newPassword: The new password to set
  ///   - token: The verification token from the reset email
  public func confirm(newPassword: String, token: String) async throws {
    try await self.client.confirm(newPassword: newPassword, token: token)
  }

  /// Convenience method to confirm password reset using a Confirm object without accessing client.
  ///
  /// - Parameter confirm: The confirmation details
  public func confirm(_ confirm: Identity.Password.Reset.Confirm) async throws {
    try await self.client.confirm(confirm)
  }
}

extension Identity.Password.Change {
  /// Convenience method to change password without accessing client.
  ///
  /// - Parameters:
  ///   - currentPassword: The user's current password
  ///   - newPassword: The new password to set
  public func request(currentPassword: String, newPassword: String) async throws {
    try await self.client.request(currentPassword: currentPassword, newPassword: newPassword)
  }

  /// Convenience method to change password using a Request object without accessing client.
  ///
  /// - Parameter request: The change request
  public func request(_ request: Identity.Password.Change.Request) async throws {
    try await self.client.request(request)
  }
}

extension Identity.Email.Change {
  /// Convenience method to request email change without accessing client.
  ///
  /// - Parameter newEmail: The new email address to change to
  /// - Returns: The result of the change request
  public func request(newEmail: String) async throws -> Identity.Email.Change.Request.Result {
    try await self.client.request(newEmail: newEmail)
  }

  /// Convenience method to request email change using a Request object without accessing client.
  ///
  /// - Parameter request: The email change request
  /// - Returns: The result of the change request
  public func request(
    _ request: Identity.Email.Change.Request
  ) async throws -> Identity.Email.Change.Request.Result {
    try await self.client.request(request)
  }

  /// Convenience method to confirm email change without accessing client.
  ///
  /// - Parameter token: The verification token from the confirmation email
  /// - Returns: Response containing updated authentication information
  public func confirm(token: String) async throws -> Identity.Email.Change.Confirmation.Response {
    try await self.client.confirm(token: token)
  }

  /// Convenience method to confirm email change using a Confirmation object without accessing client.
  ///
  /// - Parameter confirmation: The confirmation details
  /// - Returns: Response containing updated authentication information
  public func confirm(
    _ confirmation: Identity.Email.Change.Confirmation
  ) async throws -> Identity.Email.Change.Confirmation.Response {
    try await self.client.confirm(confirmation)
  }
}

extension Identity.Deletion {
  /// Convenience method to request identity deletion without accessing client.
  ///
  /// - Parameter reauthToken: A fresh authentication token to verify the user's identity
  public func request(reauthToken: String) async throws {
    try await self.client.request(reauthToken: reauthToken)
  }

  /// Convenience method to request identity deletion using a Request object without accessing client.
  ///
  /// - Parameter request: The deletion request
  public func request(_ request: Identity.Deletion.Request) async throws {
    try await self.client.request(request)
  }

  /// Convenience method to cancel a pending identity deletion without accessing client.
  public func cancel() async throws {
    try await self.client.cancel()
  }

  /// Convenience method to confirm and execute identity deletion without accessing client.
  ///
  /// > Warning: This operation is irreversible.
  public func confirm() async throws {
    try await self.client.confirm()
  }
}

extension Identity.Reauthorization {
  /// Convenience method to reauthorize without accessing client.
  ///
  /// - Parameter password: The user's current password
  /// - Returns: A JWT token for the re-authenticated session
  public func reauthorize(password: String) async throws -> JWT {
    try await self.client.reauthorize(password: password)
  }
}

extension Identity.Authentication {
  /// Convenience method to authenticate with credentials without accessing client.
  ///
  /// - Parameters:
  ///   - username: The user's email address or username
  ///   - password: The user's password
  /// - Returns: An authentication response containing access and refresh tokens
  public func credentials(
    username: String,
    password: String
  ) async throws -> Identity.Authentication.Response {
    try await self.client.credentials(username: username, password: password)
  }

  /// Convenience method to authenticate with credentials object without accessing client.
  ///
  /// - Parameter credentials: The authentication credentials
  /// - Returns: An authentication response containing access and refresh tokens
  public func credentials(
    _ credentials: Identity.Authentication.Credentials
  ) async throws -> Identity.Authentication.Response {
    try await self.client.credentials(credentials)
  }

  /// Convenience method to authenticate with API key without accessing client.
  ///
  /// - Parameter apiKey: The API key to authenticate with
  /// - Returns: An authentication response containing access and refresh tokens
  public func apiKey(_ apiKey: String) async throws -> Identity.Authentication.Response {
    try await self.client.apiKey(apiKey)
  }
}
