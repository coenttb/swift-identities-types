//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Case_Macro
import Coder
import EmailAddress
import HTML_Form_Coder_Codable
import HTTP
import HTTP_Router

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
        self.email = email.address
    }
}

extension Identity.Password.Reset.Request: HTTP.Routable {
    /// Router for handling password reset request endpoints.
    ///
    /// Routes POST requests to the "/request" path with form-encoded body.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.Reset.Request> {
        Coder::Coder(HTTP.Router.Request.self, HTTP.Router.Request.self) {
            HTTP.Method.post
            HTTP.Segment.request
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.Password.Reset.Request.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }
    }
}
