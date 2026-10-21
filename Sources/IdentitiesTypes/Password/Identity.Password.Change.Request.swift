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

extension Identity.Password.Change.Request: HTTP.Routable {
    /// Router for handling password change request endpoints.
    ///
    /// Routes POST requests to the "/request" path with form-encoded body.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.Change.Request> {
        Coder::Coder(HTTP.Router.Request.self, HTTP.Router.Request.self) {
            HTTP.Method.post
            HTTP.Segment("request")
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.Password.Change.Request.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }
    }
}
