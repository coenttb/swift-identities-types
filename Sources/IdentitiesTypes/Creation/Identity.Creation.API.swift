//
//  Identity.Creation.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Case_Macro
import Coder
import HTML_Form_Coder_Codable
import HTTP
import HTTP_Router

extension Identity.Creation {
    /// Identity creation endpoints that handle new user registration and verification.
    ///
    /// The creation flow consists of two steps:
    /// 1. Initial identity creation request with email and password
    /// 2. Email verification using a token
    ///
    /// Example of initiating identity creation:
    /// ```swift
    /// let create = Identity.Creation.API.request(
    ///   .init(email: "new@example.com", password: "password123")
    /// )
    /// ```
    ///
    /// After the initial request, the user receives a verification email. They complete
    /// registration by verifying their email:
    /// ```swift
    /// let verify = Identity.Creation.API.verify(
    ///   .init(token: "verification-token", email: "new@example.com")
    /// )
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Initiates identity creation with email and password
        case request(Identity.Creation.Request)

        /// Verifies the email address using a token sent to the user
        case verify(Identity.Creation.Verification)
    }
}

extension Identity.Creation.API: HTTP.Routable {
    /// Routes identity creation requests to their appropriate handlers.
    ///
    /// Defines the URL structure and request formats for identity creation:
    /// - Initial request: `POST /create/request`
    /// - Email verification: `POST /create/verify`
    ///
    /// Both endpoints expect form-encoded request bodies containing the necessary
    /// identity creation or verification data.
    public static var router: some HTTP.Router.`Protocol`<Identity.Creation.API> {
        Coder::Case(
            Identity.Creation.API.cases.request.prism,
            Identity.Creation.API.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.request
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.Creation.Request.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }
        Coder::Case(
            Identity.Creation.API.cases.verify.prism,
            Identity.Creation.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.verify
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.Creation.Verification.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }
    }
}
