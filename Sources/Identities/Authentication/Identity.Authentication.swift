//
//  Identity.Authentication.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import BearerAuth
import CasePaths
import Coenttb_Authentication
import EmailAddress
import Swift_Web

extension Identity {
   /// Authentication methods supported by the Identity system.
   ///
   /// The system supports two primary authentication methods:
   /// - Username/password credentials
   /// - Token-based authentication (access and refresh tokens)
   ///
   /// This design implements a robust authentication system with support for
   /// both initial authentication and session maintenance through token refresh.
    @CasePathable
    @dynamicMemberLookup
    public enum Authentication: Equatable, Sendable {
       /// Authenticate using username and password credentials
       case credentials(Credentials)
       /// Authenticate using an access or refresh token
       case token(Identity.Authentication.Token)
   }
}

extension Identity.Authentication {
   /// Credentials for username/password authentication.
   ///
   /// This type represents the basic authentication credentials where a user
   /// provides their username (typically their email) and password.
   ///
   /// Example usage:
   /// ```swift
   /// let credentials = Identity.Authentication.Credentials(
   ///     username: "user@example.com",
   ///     password: "secretPassword123"
   /// )
   /// let response = try await client.authenticate.credentials(credentials)
   /// ```
   public struct Credentials: Codable, Hashable, Sendable {
       /// The user's username (typically their email address).
       public let username: String

       /// The user's password.
       public let password: String

       /// Creates a new credentials instance.
       ///
       /// - Parameters:
       ///   - username: The user's username.
       ///   - password: The user's password.
       public init(
           username: String = "",
           password: String = ""
       ) {
           self.username = username
           self.password = password
       }

       /// Keys for coding and decoding Credentials instances.
       public enum CodingKeys: String, CodingKey {
           case username
           case password
       }
   }
}

extension Identity.Authentication.Credentials {
   /// Creates credentials using a validated email address.
   ///
   /// This convenience initializer allows creating credentials using a validated
   /// `EmailAddress` type, ensuring the email format is valid.
   ///
   /// - Parameters:
   ///   - email: A validated email address to use as the username
   ///   - password: The user's password
   public init(
       email: EmailAddress,
       password: String
   ) {
       self = .init(
           username: email.rawValue,
           password: password
       )
   }
}

extension Identity.Authentication {
   /// Types of authentication tokens supported by the system.
   ///
   /// The system uses a dual-token approach:
   /// - Access tokens for API authentication
   /// - Refresh tokens for obtaining new access tokens
   ///
   /// This approach enhances security by limiting access token lifetimes
   /// while maintaining session persistence through refresh tokens.
   public enum Token: Equatable, Sendable {
       /// Short-lived token for API authentication
       case access(BearerAuth)
       /// Long-lived token for obtaining new access tokens
       case refresh(JWT.Token)
   }
}

extension Identity.Authentication {
   /// Response containing authentication tokens after successful authentication.
   ///
   /// This type encapsulates both the access and refresh tokens returned
   /// after successful authentication, whether via credentials or token refresh.
   ///
   /// > Important: The access token should be included in subsequent API requests,
   /// > while the refresh token should be securely stored for session renewal.
   public struct Response: Codable, Hashable, Sendable {
       /// The JWT access token for API authentication.
       public let accessToken: JWT.Token

       /// The JWT refresh token for obtaining new access tokens.
       public let refreshToken: JWT.Token

       /// Creates a new authentication response.
       ///
       /// - Parameters:
       ///   - accessToken: The JWT access token
       ///   - refreshToken: The JWT refresh token
       public init(
           accessToken: JWT.Token,
           refreshToken: JWT.Token
       ) {
           self.accessToken = accessToken
           self.refreshToken = refreshToken
       }
   }
}

extension Identity.Authentication.Response: TestDependencyKey {
   /// Provides a test instance of the authentication response.
   ///
   /// This implementation uses test values for both tokens, suitable for
   /// testing authentication flows without real credentials.
   public static let testValue: Self = .init(
       accessToken: .testValue,
       refreshToken: .testValue
   )
}
