//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import EmailAddress
import URLRouting

extension Identity.Password.Reset {
    /// A request to initiate the password reset process.
    ///
    /// This type represents the first step in the password reset flow where
    /// a user requests to reset their password by providing their email address.
    public struct Request: Codable, Hashable, Sendable {
        /// The email address associated with the identity for password reset.
        public let email: String

        /// Creates a new password reset request.
        ///
        /// - Parameter email: The email address for the identity.
        public init(
            email: String = ""
        ) {
            self.email = email
        }

        /// Keys for coding and decoding Request instances.
        public enum CodingKeys: String, CodingKey {
            case email
        }
    }
}

extension Identity.Password.Reset.Request {
    /// Creates a new password reset request using an EmailAddress value.
    ///
    /// - Parameter email: A validated email address
    public init(
        email: EmailAddress
    ) {
        self.email = email.rawValue
    }
}

extension Identity.Password.Reset.Request {
    /// Router for handling password reset request endpoints.
    ///
    /// Routes POST requests to the "/request" path with form-encoded body.
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Reset.Request> {
            // Route-level wrap (W3): a bare Take-sequence body leaves the Skip-chain's
            // `Either` failure uncollapsed; the `URLRouting.Route` node collapses it to
            // `RFC_3986.URI.Routing.Error` (pinned by url-routing FormBodyRouteTests).
            // `.identity()` is the struct-output analogue of the tested `.case` form.
            URLRouting.Route(.identity()) {
                Method.post
                Path<PathBuilder.Component<String>>.request
                URLRouting.Body(
                    coding: .form(Identity.Password.Reset.Request.self, decoder: .identities)
                )
            }
        }
    }
}
