//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Case_Macro
import Coder
import HTML_Form_Coder_Codable
import HTTP
import HTTP_Router

extension Identity.Reauthorization {
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
    /// let reauth = Identity.Reauthorization.Request(password: "current_password")
    /// try await client.reauthorize(reauth)
    /// ```
    public struct Request: Codable, Hashable, Sendable {
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

extension Identity.Reauthorization.Request: HTTP.Routable {
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
    public static var router: some HTTP.Router.`Protocol`<Identity.Reauthorization.Request> {
        Coder::Coder(HTTP.Router.Request.self, HTTP.Router.Request.self) {
            HTTP.Method.post
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.Reauthorization.Request.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }
    }
}
