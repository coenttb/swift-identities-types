//
//  Identity.Password.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import SwiftWeb

extension Identity {
    /// Namespace for password-related functionality within the Identity system.
    public enum Password {}
}

extension Identity.Password {
    /// Namespace containing password reset functionality.
    ///
    /// The reset flow consists of two steps:
    /// 1. Requesting a password reset via email
    /// 2. Confirming the reset with a token and new password
    public enum Reset {}
}

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
            Method.post
            Path.request
            Body(.form(Identity.Password.Reset.Request.self, decoder: .default))
        }
    }
}

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
            Body(.form(Identity.Password.Reset.Confirm.self, decoder: .default))
        }
    }
}

extension Identity.Password {
    /// Namespace containing password change functionality for authenticated users.
    public enum Change {}
}

extension Identity.Password.Change {
    /// Type alias for reauthorization requirements during password changes.
    ///
    /// While this type alias creates an indirect namespace path
    /// (`Identity.Password.Change.Reauthorization`), this approach offers several benefits:
    ///
    /// - **Domain Context**: The alias clearly indicates this reauthorization is specifically
    ///   for password changes, making the code's intent more explicit
    ///
    /// - **Feature Isolation**: Allows password-change-specific reauthorization behavior or
    ///   extensions to be added without affecting the base `Identity.Reauthorization` type
    ///
    /// - **Discoverability**: Developers working with password changes will naturally find
    ///   reauthorization requirements through code completion within the `Password.Change` namespace
    ///
    /// - **Type Safety**: Provides semantic meaning - even though it's the same underlying type,
    ///   the alias signals this is specifically for password change flows
    ///
    /// - **Future Flexibility**: If password change reauthorization needs to diverge from the
    ///   base implementation, the alias can be replaced with a distinct type without changing
    ///   the public API
    public typealias Reauthorization = Identity.Reauthorization
}

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
            Path.request
            Body(.form(Identity.Password.Change.Request.self, decoder: .default))
        }
    }
}
