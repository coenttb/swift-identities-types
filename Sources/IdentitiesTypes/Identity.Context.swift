//
//  Identity.Context.swift
//  swift-identities-types
//
//  Context object providing access to authenticated identity information.
//  Stores the JWT token and provides computed properties for common fields.
//

import EmailAddress
import Foundation
import JWT
import Tagged_Primitives

extension Identity {
    /// Context object providing access to identity information
    public struct Context: Sendable {
        /// The underlying JWT token containing identity claims
        public let jwt: JWT

        /// The authenticated identity's ID
        public let id: Identity.ID

        /// The authenticated identity's email address
        public let email: EmailAddress

        /// The authenticated identity's display name
        public var displayName: String {
            jwt.payload.additionalClaim("displayName", as: String.self) ?? "User"
        }

        /// Whether the request is authenticated (always true if context exists)
        public var isAuthenticated: Bool { true }

        /// Session version for token invalidation
        public var sessionVersion: Int {
            jwt.payload.additionalClaim("sev", as: Int.self) ?? 0
        }

        /// Token expiration date if available
        public var expiresAt: Date? {
            jwt.payload.exp
        }

        /// Check if the token is expired
        public var isExpired: Bool {
            if let exp = jwt.payload.exp {
                return Date() > exp
            }
            return false
        }

        public init(jwt: JWT) throws(Identity.Context.Error) {
            guard let sub = jwt.payload.sub else { throw .subjectMissing }

            let parts = sub.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { throw .subjectMalformed(sub) }

            guard let uuid = UUID(uuidString: parts[0]) else {
                throw .identifierInvalid(parts[0])
            }
            guard let address = try? EmailAddress(parts[1]) else {
                throw .emailInvalid(parts[1])
            }

            self.jwt = jwt
            self.id = Identity.ID(_unchecked: uuid)
            self.email = address
        }

        /// Gets additional claim value from the JWT payload
        /// - Parameters:
        ///   - key: Claim name
        ///   - type: The type to cast the claim value to
        /// - Returns: Claim value if present and castable to the specified type
        public func additionalClaim<T>(_ key: String, as type: T.Type) -> T? {
            jwt.payload.additionalClaim(key, as: type)
        }
    }
}

extension Identity.Context {
    public enum Error: Swift.Error {
        case subjectMissing
        case subjectMalformed(String)
        case identifierInvalid(String)
        case emailInvalid(String)
    }
}
