//
//  Identity.Reauthorization.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import ServerFoundation

extension Identity {
   /// A data structure representing a reauthorization request.
   ///
   /// Reauthorization is required for sensitive operations that need to verify
   /// the user's identity beyond their existing session, such as:
   /// - Changing email address
   /// - Deleting identity
   /// - Modifying security settings
   ///
   /// Example usage:
   /// ```swift
   /// let reauth = Identity.Reauthorization(password: "current_password")
   /// try await client.reauthorize(reauth)
   /// ```
   public struct Reauthorization: Codable, Hashable, Sendable {
       /// The user's current password for verification.
       public let password: String

       /// Creates a new reauthorization request.
       ///
       /// - Parameter password: The user's current password
       public init(
           password: String = ""
       ) {
           self.password = password
       }

       /// Keys for encoding and decoding reauthorization requests.
       public enum CodingKeys: String, CodingKey {
           case password
       }
   }
}

extension Identity.Reauthorization {
   /// Routes and parses reauthorization requests in the web API.
   ///
   /// This router handles the HTTP endpoint for reauthorization:
   /// - Method: POST
   /// - Path: /reauthorization
   /// - Body: Form-encoded password
   ///
   /// The router ensures that reauthorization requests are properly:
   /// - Routed to the correct endpoint
   /// - Encoded in the request body
   /// - Decoded from form data
   public struct Router: ParserPrinter, Sendable {
       /// Creates a new reauthorization router.
       public init() {}

       /// The routing configuration for reauthorization requests.
       public var body: some URLRouting.Router<Identity.Reauthorization> {
           Method.post
           Path.reauthorization
           Body(.form(Identity.Reauthorization.self, decoder: .identities))
       }
   }
}
