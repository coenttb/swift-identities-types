//
//  Identity.Client.MFA.SMS.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.SMS {
    /// SMS-based authentication client operations.
    @Witness
    public struct Client: @unchecked Sendable {
        /// Setup SMS authentication with phone number.
        ///
        /// - Parameter phoneNumber: The phone number to receive SMS codes
        public var setup: (_ phoneNumber: String) async throws(any Swift.Error) -> Void

        /// Request a new SMS code.
        public var requestCode: () async throws(any Swift.Error) -> Void

        /// Verify SMS code during authentication.
        ///
        /// - Parameters:
        ///   - code: The SMS code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        public var verify:
            (
                _ code: String,
                _ sessionToken: String
            ) async throws(any Swift.Error) -> Identity.Authentication.Response

        /// Update phone number for SMS authentication.
        ///
        /// - Parameters:
        ///   - phoneNumber: The new phone number
        ///   - reauthorizationToken: Token from reauthorization
        public var updatePhoneNumber:
            (
                _ phoneNumber: String,
                _ reauthorizationToken: String
            ) async throws(any Swift.Error) -> Void

        /// Disable SMS authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        public var disable: (_ reauthorizationToken: String) async throws(any Swift.Error) -> Void
    }
}
