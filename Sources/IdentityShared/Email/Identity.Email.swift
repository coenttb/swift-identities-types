//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import EmailAddress
import Foundation
import URLRouting

extension Identity {
    /// Namespace for email-related functionality within the Identity system.
    public enum Email {}
}

extension Identity.Email {
    /// Namespace containing email change functionality.
    ///
    /// The email change flow consists of multiple steps:
    /// 1. Requesting an email change with the new email address
    /// 2. Potentially requiring reauthorization for security
    /// 3. Confirming the change with a verification token
    public enum Change {}
}

extension Identity.Email.Change {
    /// Type alias for reauthorization requirements during email changes.
    ///
    /// While this type alias creates an indirect namespace path
    /// (`Identity.Email.Change.Reauthorization`), this approach offers several benefits:
    ///
    /// - **Domain Context**: The alias clearly indicates this reauthorization is specifically
    ///   for email changes, making the code's intent more explicit
    ///
    /// - **Feature Isolation**: Allows email-change-specific reauthorization behavior or
    ///   extensions to be added without affecting the base `Identity.Reauthorization` type
    ///
    /// - **Discoverability**: Developers working with email changes will naturally find
    ///   reauthorization requirements through code completion within the `Password.Change` namespace
    ///
    /// - **Type Safety**: Provides semantic meaning - even though it's the same underlying type,
    ///   the alias signals this is specifically for email change flows
    ///
    /// - **Future Flexibility**: If email change reauthorization needs to diverge from the
    ///   base implementation, the alias can be replaced with a distinct type without changing
    ///   the public API
    public typealias Reauthorization = Identity.Reauthorization
}

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
            Path.request
            Body(.form(Identity.Email.Change.Request.self, decoder: .default))
        }
    }
}

extension Identity.Email.Change {
    /// Confirmation data for completing an email change.
    ///
    /// This type represents the final step in the email change flow where
    /// a user confirms their new email address using a verification token.
    public struct Confirmation: Codable, Hashable, Sendable {
        /// The verification token received via email.
        public let token: String
        
        /// Creates a new email change confirmation.
        ///
        /// - Parameter token: The verification token received via email.
        public init(
            token: String = ""
        ) {
            self.token = token
        }
        
        /// Keys for coding and decoding Confirmation instances.
        public enum CodingKeys: String, CodingKey {
            case token
        }
    }
}

extension Identity.Email.Change.Confirmation {
    /// Router for handling email change confirmation endpoints.
    ///
    /// Routes POST requests to the "/confirm" path with form-encoded body.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Email.Change.Confirmation> {
            Method.post
            Path.confirm
            Body(.form(Identity.Email.Change.Confirmation.self, decoder: .default))
        }
    }
}

extension Identity.Client.Email.Change {
    /// Namespace for client-specific email change request types.
    ///
    /// This empty enum serves as a namespace for organizing client-side
    /// email change request functionality.
    public enum Request { }
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

extension Identity.Email.Change.Confirmation {
    /// The response type for a successful email change confirmation.
    ///
    /// This typealias indicates that after confirming an email change,
    /// the user receives a new set of authentication credentials.
    public typealias Response = Identity.Authentication.Response
}
