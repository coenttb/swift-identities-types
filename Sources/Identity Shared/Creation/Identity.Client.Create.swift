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
   /// A client interface for handling identity creation.
   ///
   /// The `Create` struct manages the two-step process of creating new identities:
   /// 1. Requesting identity creation with email and password
   /// 2. Verifying the email address with a token
   ///
   /// Example usage:
   /// ```swift
   /// let client = Identity.Client.Create(...)
   ///
   /// // Request identity creation
   /// try await client.request(
   ///     email: "user@example.com",
   ///     password: "password123"
   /// )
   ///
   /// // Verify email with token
   /// try await client.verify(
   ///     email: "user@example.com",
   ///     token: "verification_token"
   /// )
   /// ```
   @DependencyClient
   public struct Create: @unchecked Sendable {
       /// Initiates the identity creation process.
       ///
       /// This method starts the identity creation flow by:
       /// 1. Validating the email and password
       /// 2. Creating a pending identity
       /// 3. Sending a verification email to the provided address
       ///
       /// - Parameters:
       ///   - email: The email address for the new identity
       ///   - password: The password for the new identity
       /// - Throws: Creation errors if the email is invalid or already in use
       @DependencyEndpoint
       public var request: (_ email: String, _ password: String) async throws -> Void

       /// Verifies an email address to complete identity creation.
       ///
       /// This method completes the identity creation process by:
       /// 1. Validating the verification token
       /// 2. Activating the identity
       /// 3. Enabling login capabilities
       ///
       /// - Parameters:
       ///   - email: The email address being verified
       ///   - token: The verification token from the email
       /// - Throws: Verification errors if the token is invalid or expired
       @DependencyEndpoint
       public var verify: (_ email: String, _ token: String) async throws -> Void
   }
}

extension Identity.Client.Create {
   /// Convenience method for requesting identity creation using a Creation Request object.
   ///
   /// - Parameter request: The identity creation request containing email and password
   /// - Throws: Creation errors if the email is invalid or already in use
   public func request(_ request: Identity.Creation.Request) async throws {
       try await self.request(email: request.email, password: request.password)
   }
}

extension Identity.Client.Create {
   /// Convenience method for verifying an email using a Creation Verification object.
   ///
   /// - Parameter verify: The verification details containing email and token
   /// - Throws: Verification errors if the token is invalid or expired
   public func verify(_ verify: Identity.Creation.Verification) async throws {
       try await self.verify(email: verify.email, token: verify.token)
   }
}
