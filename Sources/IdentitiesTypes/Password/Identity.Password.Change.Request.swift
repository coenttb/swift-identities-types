//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Password.Change {
    /// A request to change an authenticated user's password.
    ///
    /// This type handles password changes for already authenticated users,
    /// requiring both their current password and desired new password.
    public struct Request: Codable, Hashable, Sendable {
        /// The user's current password for verification.
        public let currentPassword: String

        /// The new password to set for the identity.
        public let newPassword: String

        /// Creates a new password change request.
        ///
        /// - Parameters:
        ///   - currentPassword: The user's current password.
        ///   - newPassword: The desired new password.
        public init(
            currentPassword: String = "",
            newPassword: String = ""
        ) {
            self.currentPassword = currentPassword
            self.newPassword = newPassword
        }

        /// Keys for coding and decoding Request instances.
        public enum CodingKeys: String, CodingKey {
            case currentPassword
            case newPassword
        }
    }
}

extension Identity.Password.Change.Request {
    /// Router for handling password change request endpoints.
    ///
    /// Routes POST requests to the "/request" path with form-encoded body.
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Change.Request> {
            Method.post
            Path { "request" }
            Body(.form(Identity.Password.Change.Request.self, decoder: .identities))
        }
    }
}

