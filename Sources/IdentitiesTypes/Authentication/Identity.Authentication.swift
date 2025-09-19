//
//  Identity.Authentication.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Authenticating
import TypesFoundation
import DependenciesMacros

extension Identity {
    /// Authentication namespace containing all authentication-related types and operations.
    ///
    /// This namespace follows the domain-first pattern where the business capability
    /// (Authenticate) is primary, with technical implementations (Client, API, Route)
    /// as nested types.
    @DependencyClient
    public struct Authentication: @unchecked Sendable {
        public var client: Identity.Authentication.Client
        public var router: any URLRouting.Router<Identity.Authentication.Route>
        public var token: Identity.Authentication.Token.Client
        
        public init(
            client: Identity.Authentication.Client,
            router: any URLRouting.Router<Identity.Authentication.Route>,
            token: Identity.Authentication.Token.Client
        ) {
            self.client = client
            self.router = router
            self.token = token
        }
    }
}

extension Identity.Authentication {
    /// Authentication methods supported by the Identity system.
    ///
    /// The system supports three primary authentication methods:
    /// - Username/password credentials
    /// - Token-based authentication (access and refresh tokens)
    /// - OAuth provider authentication (GitHub, Google, etc.)
    ///
    /// This design implements a robust authentication system with support for
    /// both initial authentication and session maintenance through token refresh.
    @CasePathable
    @dynamicMemberLookup
    public enum Method: Equatable, Sendable {
        /// Authenticate using username and password credentials
        case credentials(Credentials)
        /// Authenticate using an access or refresh token
        case token(Identity.Authentication.Token)
        /// Authenticate using OAuth provider
        case oauth(Identity.OAuth.CallbackRequest)
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

