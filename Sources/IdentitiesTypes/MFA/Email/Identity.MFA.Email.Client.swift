//
//  Identity.Client.MFA.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.MFA.Email {
  /// Email-based authentication client operations.
  @DependencyClient
  public struct Client: @unchecked Sendable {
    /// Setup email authentication.
    ///
    /// - Parameter email: The email address to receive codes
    @DependencyEndpoint
    public var setup: (_ email: String) async throws -> Void

    /// Request a new email code.
    @DependencyEndpoint
    public var requestCode: () async throws -> Void

    /// Verify email code during authentication.
    ///
    /// - Parameters:
    ///   - code: The email code
    ///   - sessionToken: The MFA session token from initial authentication
    /// - Returns: Full authentication response with access and refresh tokens
    @DependencyEndpoint
    public var verify:
      (
        _ code: String,
        _ sessionToken: String
      ) async throws -> Identity.Authentication.Response

    /// Update email address for MFA.
    ///
    /// - Parameters:
    ///   - email: The new email address
    ///   - reauthorizationToken: Token from reauthorization
    @DependencyEndpoint
    public var updateEmail:
      (
        _ email: String,
        _ reauthorizationToken: String
      ) async throws -> Void

    /// Disable email authentication.
    ///
    /// - Parameter reauthorizationToken: Token from reauthorization
    @DependencyEndpoint
    public var disable: (_ reauthorizationToken: String) async throws -> Void
  }
}
