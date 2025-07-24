//
//  Identity.API.Create.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import CasePaths
import Swift_Web

extension Identity.API {
    /// Identity creation endpoints that handle new user registration and verification.
    ///
    /// The creation flow consists of two steps:
    /// 1. Initial identity creation request with email and password
    /// 2. Email verification using a token
    ///
    /// Example of initiating identity creation:
    /// ```swift
    /// let create = Identity.API.Create.request(
    ///   .init(email: "new@example.com", password: "password123")
    /// )
    /// ```
    ///
    /// After the initial request, the user receives a verification email. They complete
    /// registration by verifying their email:
    /// ```swift
    /// let verify = Identity.API.Create.verify(
    ///   .init(token: "verification-token", email: "new@example.com")
    /// )
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Create: Equatable, Sendable {
        /// Initiates identity creation with email and password
        case request(Identity.Creation.Request)

        /// Verifies the email address using a token sent to the user
        case verify(Identity.Creation.Verification)
    }
}

extension Identity.API.Create {
    /// Routes identity creation requests to their appropriate handlers.
    ///
    /// Defines the URL structure and request formats for identity creation:
    /// - Initial request: `POST /create/request`
    /// - Email verification: `POST /create/verify`
    ///
    /// Both endpoints expect form-encoded request bodies containing the necessary
    /// identity creation or verification data.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        /// The routing logic for identity creation endpoints.
        ///
        /// Composes routes for both steps of the identity creation process:
        /// - The initial identity creation request
        /// - The email verification step
        ///
        /// Each route is handled by its respective router that defines the
        /// specific request format and validation rules.
        public var body: some URLRouting.Router<Identity.API.Create> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Create.request)) {
                    Identity.Creation.Request.Router()
                }
                URLRouting.Route(.case(Identity.API.Create.verify)) {
                    Identity.Creation.Verification.Router()
                }
            }
        }
    }
}
