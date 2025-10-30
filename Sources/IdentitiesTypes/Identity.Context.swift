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

extension Identity {
  /// Context object providing access to identity information
  public struct Context: Sendable {
    /// The underlying JWT token containing identity claims
    public let jwt: JWT

    /// The authenticated identity's ID
    public var id: Identity.ID {
      guard let sub = jwt.payload.sub,
        let components = parseSubject(sub),
        let id = UUID(uuidString: components.id)
      else {
        fatalError("Invalid token subject - missing or malformed identity ID")
      }
      return Identity.ID(id)
    }

    /// The authenticated identity's email address
    public var email: EmailAddress {
      guard let sub = jwt.payload.sub,
        let components = parseSubject(sub)
      else {
        fatalError("Invalid token subject - missing or malformed email")
      }
      return try! .init(components.email)
    }

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

    public init(jwt: JWT) {
      self.jwt = jwt
    }

    /// Gets additional claim value from the JWT payload
    /// - Parameters:
    ///   - key: Claim name
    ///   - type: The type to cast the claim value to
    /// - Returns: Claim value if present and castable to the specified type
    public func additionalClaim<T>(_ key: String, as type: T.Type) -> T? {
      jwt.payload.additionalClaim(key, as: type)
    }

    /// Parse subject string "id:email" into components
    private func parseSubject(_ subject: String) -> (id: String, email: String)? {
      let components = subject.split(separator: ":", maxSplits: 1).map(String.init)
      guard components.count == 2 else { return nil }
      return (components[0], components[1])
    }
  }
}
