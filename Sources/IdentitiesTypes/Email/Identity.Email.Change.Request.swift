//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Email.Change {
    /// A request to change a user's email address.
    ///
    /// This type represents the initial step in the email change flow where
    /// a user requests to update their email address to a new one.
    public struct Request: Codable, Hashable, Sendable {
        /// The new email address to associate with the identity.
        public let newEmail: String

        /// Creates a new email change request.
        ///
        /// - Parameter newEmail: The desired new email address.
        public init(
            newEmail: String = ""
        ) {
            self.newEmail = newEmail
        }

        /// Keys for coding and decoding Request instances.
        public enum CodingKeys: String, CodingKey {
            case newEmail
        }
    }
}

extension Identity.Email.Change.Request {
    /// Creates a new email change request using a validated EmailAddress value.
    ///
    /// - Parameter newEmail: A validated email address to change to
    public init(
        newEmail: EmailAddress
    ) {
        self.newEmail = newEmail.rawValue
    }
}

extension Identity.Email.Change.Request {
    /// Router for handling email change request endpoints.
    ///
    /// Routes POST requests to the "/request" path with form-encoded body.
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Email.Change.Request> {
            Method.post
            Path { "request" }
            Body(.form(Identity.Email.Change.Request.self, decoder: .identities))
        }
    }
}

extension Identity.Email.Change.Request {
    /// Possible outcomes of an email change request.
    ///
    /// This enum represents the two possible states after requesting an email change:
    /// - The request was successful and can proceed to confirmation
    /// - The request requires additional authentication for security
    public enum Result: Codable, Hashable, Sendable {
        /// The email change request was successful
        case success

        /// Additional authentication is required before proceeding
        case requiresReauthentication
    }
}
