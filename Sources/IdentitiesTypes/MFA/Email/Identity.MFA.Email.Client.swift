//
//  Identity.Client.MFA.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.Email {
    /// Email-based authentication client operations.
    @Witness
    public struct Client: @unchecked Sendable {
        /// Setup email authentication.
        ///
        /// - Parameter email: The email address to receive codes
        public var setup: (_ email: String) async throws(any Swift.Error) -> Void

        /// Request a new email code.
        public var requestCode: () async throws(any Swift.Error) -> Void

        /// Verify email code during authentication.
        ///
        /// - Parameters:
        ///   - code: The email code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        public var verify:
            (
                _ code: String,
                _ sessionToken: String
            ) async throws(any Swift.Error) -> Identity.Authentication.Response

        /// Update email address for MFA.
        ///
        /// - Parameters:
        ///   - email: The new email address
        ///   - reauthorizationToken: Token from reauthorization
        public var updateEmail:
            (
                _ email: String,
                _ reauthorizationToken: String
            ) async throws(any Swift.Error) -> Void

        /// Disable email authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        public var disable: (_ reauthorizationToken: String) async throws(any Swift.Error) -> Void
    }
}
