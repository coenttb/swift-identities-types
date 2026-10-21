//
//  Identity.Authentication.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Case_Macro
import Coder
import Foundation
import HTML_Form_Coder_Codable
import HTTP
import HTTP_Router
import JWT
import RFC_6750

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
    @Prisms
    @Folds
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
    @Prisms
    @Folds
    @Cases
    public enum Token: Codable, Hashable, Sendable {
        /// Authenticates using a JWT access token
        case access(JWT)

        /// Authenticates using a JWT refresh token to obtain a new access token
        case refresh(JWT)
    }
}

extension Identity.Authentication.API: HTTP.Routable {

    public static var router: some HTTP.Router.`Protocol`<Self> {
        Coder::Case(Self.cases.credentials.prism, Self.cases.credentials.fold, absent: .mismatch) {
            HTTP.Method.post
            HTTP.Segment.End()
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(
                    Identity.Authentication.Credentials.self,
                    decoder: .identities
                )
            )
        }
        Coder::Case(Self.cases.token.prism, Self.cases.token.fold, absent: .mismatch) {
            HTTP.Method.post
            Identity.Authentication.API.Token.router
        }
        Coder::Case(Self.cases.apiKey.prism, Self.cases.apiKey.fold, absent: .mismatch) {
            HTTP.Method.post
            HTTP.Segment.apiKey
            HTTP.Segment.End()
            HTTP.Bearer()
        }
    }
}

extension Identity.Authentication.API.Token: HTTP.Routable {

    public static var router: some HTTP.Router.`Protocol`<Self> {
        Coder::Case(Self.cases.access.prism, Self.cases.access.fold, absent: .mismatch) {
            HTTP.Segment.access
            HTTP.Segment.End()
            HTTP.Cookie.Field("access_token", HTTP.Body.JSON<JWT>())
        }
        Coder::Case(Self.cases.refresh.prism, Self.cases.refresh.fold, absent: .mismatch) {
            HTTP.Segment.refresh
            HTTP.Segment.End()
            Coder::OneOf.Two(
                HTTP.Body.Coded(HTTP.Body.JSON<JWT>()),
                HTTP.Cookie.Field("refresh_token", HTTP.Body.JSON<JWT>()),
                absent: HTTP.Router.Error.mismatch
            )
        }
    }
}
