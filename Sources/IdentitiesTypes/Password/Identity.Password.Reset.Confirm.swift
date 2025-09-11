//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Password.Reset {
    /// Confirmation data for completing a password reset.
    ///
    /// This type represents the second step in the password reset flow where
    /// a user confirms their reset request using a token and provides their new password.
    public struct Confirm: Codable, Hashable, Sendable {
        /// The verification token received via email.
        public let token: String

        /// The new password to set for the identity.
        public let newPassword: String

        /// Creates a new password reset confirmation.
        ///
        /// - Parameters:
        ///   - token: The verification token received via email.
        ///   - newPassword: The new password to set.
        public init(
            token: String = "",
            newPassword: String = ""
        ) {
            self.token = token
            self.newPassword = newPassword
        }

        /// Keys for coding and decoding Confirm instances.
        public enum CodingKeys: String, CodingKey {
            case token
            case newPassword
        }
    }
}

extension Identity.Password.Reset.Confirm {
    /// Router for handling password reset confirmation endpoints.
    ///
    /// Routes POST requests to the "/confirm" path with form-encoded body.
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Reset.Confirm> {
            Method.post
            Path.confirm
            Body(.form(Identity.Password.Reset.Confirm.self, decoder: .identities))
        }
    }
}
