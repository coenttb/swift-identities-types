//
//  Identity.Authentication.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Dual
import Foundation
import JWT
import RFC_6750
import URLRouting
import URL_Routing_Foundation_Integration

extension Identity.Authentication {
    /// Authentication endpoints for managing user sessions and access.
    ///
    /// The `API` provides three authentication methods:
    /// - Username/password credentials
    /// - JWT tokens (access and refresh)
    /// - API keys
    ///
    /// Each authentication method follows RESTful conventions and returns
    /// standardized authentication responses. For example:
    ///
    /// ```swift
    /// // Authenticate with credentials
    /// let auth = Identity.Authentication.API.credentials(
    ///   .init(username: "user@example.com", password: "password123")
    /// )
    ///
    /// // Authenticate with a refresh token
    /// let auth = Identity.Authentication.API.token(.refresh(bearerToken))
    /// ```
    @Cases
    public enum API: Sendable, Hashable, Codable {

        /// Authenticates using username/password credentials
        case credentials(Identity.Authentication.Credentials)

        /// Authenticates using JWT tokens (access or refresh)
        case token(Token)

        /// Authenticates using an API key
        case apiKey(RFC_6750.Bearer)
    }
}

extension Identity.Authentication.API {
    /// Token-based authentication methods.
    ///
    /// Supports two types of JWT tokens:
    /// - Access tokens for direct API authentication
    /// - Refresh tokens for obtaining new access tokens
    ///
    /// Access tokens have shorter lifetimes but grant full API access, while
    /// refresh tokens have longer lifetimes but can only be used to obtain new
    /// access tokens.
    @Cases
    public enum Token: Codable, Hashable, Sendable {
        /// Authenticates using a JWT access token
        case access(JWT)

        /// Authenticates using a JWT refresh token to obtain a new access token
        case refresh(JWT)
    }
}

extension Identity.Authentication.API {
    /// Routes authentication requests to their appropriate handlers.
    ///
    /// Defines the URL structure and request/response formats for all authentication
    /// endpoints:
    ///
    /// - Credentials: `POST /authenticate` with form-encoded credentials
    /// - Access Token: `POST /authenticate/access` with bearer token
    /// - Refresh Token: `POST /authenticate/refresh` with bearer token
    /// - API Key: `POST /authenticate/api-key` with bearer token
    ///
    /// All authentication endpoints use POST methods for security and accept
    /// appropriate authentication data in their request bodies.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        /// The routing logic for authentication endpoints.
        ///
        /// Routes are composed using the `OneOf` parser-printer to match requests
        /// against the supported authentication methods. Each route specifies:
        /// - The HTTP method (POST for all auth endpoints)
        /// - The path components
        /// - The request body format
        public var body: some URLRouting.Router<Identity.Authentication.API> {
            OneOf {
                URLRouting.Route(.case(Identity.Authentication.API.cases.credentials)) {
                    Method.post
                    URLRouting.Body(
                        coding: .form(
                            Identity.Authentication.Credentials.self,
                            decoder: .identities
                        )
                    )
                }

                URLRouting.Route(.case(Identity.Authentication.API.cases.token)) {
                    Method.post
                    OneOf {
                        URLRouting.Route(.case(Identity.Authentication.API.Token.cases.access)) {
                            Path.access
                            // The former Bearer-header alternative was dead code: its
                            // `.convert` closures returned nil in BOTH directions, so the
                            // branch never parsed nor printed (OneOf always fell through
                            // to the cookie). branch:main's `.convert(apply:)` is total,
                            // so the always-nil spelling no longer compiles; the branch is
                            // deleted rather than migrated (behavior-preserving).
                            Cookies {
                                Field("access_token", .utf8.data.json(JWT.self))
                            }
                        }

                        URLRouting.Route(.case(Identity.Authentication.API.Token.cases.refresh)) {
                            Path.refresh
                            OneOf {
                                URLRouting.Body(coding: .json(JWT.self))

                                Cookies {
                                    Field("refresh_token", .utf8.data.json(JWT.self))
                                }
                            }
                        }
                    }
                }

                URLRouting.Route(.case(Identity.Authentication.API.cases.apiKey)) {
                    Path.apiKey
                    RFC_6750.Bearer.Router()
                }
            }
        }
    }
}
