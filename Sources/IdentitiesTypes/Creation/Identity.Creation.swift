//
//  Identity.Creation.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import ServerFoundation

extension Identity {
   /// Namespace for identity creation functionality within the Identity system.
   ///
   /// The identity creation process is a two-step flow:
   /// 1. Initial request with email and password
   /// 2. Email verification using a token
   ///
   /// This design ensures email ownership and reduces the creation of fraudulent identities.
   public enum Creation {}
}

extension Identity.Creation {
   /// A request to create a new identity.
   ///
   /// This type represents the first step in identity creation where a user
   /// provides their email and desired password. The system will send a
   /// verification email to complete the process.
   ///
   /// Example usage:
   /// ```swift
   /// let request = Identity.Creation.Request(
   ///     email: "user@example.com",
   ///     password: "securePassword123"
   /// )
   /// try await client.create.request(request)
   /// ```
   public struct Request: Codable, Hashable, Sendable {
       /// The email address for the new identity.
       public let email: String

       /// The desired password for the new identity.
       public let password: String

       /// Creates a new identity creation request.
       ///
       /// - Parameters:
       ///   - email: The email address for the identity.
       ///   - password: The desired password.
       public init(
           email: String = "",
           password: String = ""
       ) {
           self.email = email
           self.password = password
       }

       /// Keys for coding and decoding Request instances.
       public enum CodingKeys: String, CodingKey {
           case email
           case password
       }
   }
}

extension Identity.Creation.Request {
   /// Creates a new identity creation request using a validated EmailAddress.
   ///
   /// - Parameters:
   ///   - email: A validated email address
   ///   - password: The desired password
   public init(
       email: EmailAddress,
       password: String
   ) {
       self.email = email.rawValue
       self.password = password
   }
}

extension Identity.Creation {
   /// Data for verifying a new identity's email address.
   ///
   /// This type represents the second step in identity creation where
   /// the user confirms their email ownership using a verification token
   /// sent to their email address.
   ///
   /// > Important: The email provided must match the one used in the
   /// > original creation request.
   public struct Verification: Codable, Hashable, Sendable {
       /// The verification token received via email.
       public let token: String

       /// The email address being verified.
       public let email: String

       /// Creates a new identity verification request.
       ///
       /// - Parameters:
       ///   - token: The verification token received via email.
       ///   - email: The email address being verified.
       public init(
           token: String = "",
           email: String = ""
       ) {
           self.token = token
           self.email = email
       }

       /// Keys for coding and decoding Verification instances.
       public enum CodingKeys: String, CodingKey {
           case token
           case email
       }
   }
}

extension Identity.Creation.Verification {
   /// Creates a new verification request using a validated EmailAddress.
   ///
   /// - Parameters:
   ///   - token: The verification token received via email
   ///   - email: A validated email address
   public init(
       token: String,
       email: EmailAddress
   ) {
       self.token = token
       self.email = email.rawValue
   }
}
