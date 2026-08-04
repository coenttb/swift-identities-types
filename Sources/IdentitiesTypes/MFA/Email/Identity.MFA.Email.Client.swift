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
        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Setup email authentication.
        ///
        /// - Parameter email: The email address to receive codes
        public var setup: (_ email: String) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Request a new email code.
        public var requestCode: () async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

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
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.Authentication.Response
        // swiftlint:enable no_any_protocol_existential

        /// Update email address for MFA.
        ///
        /// - Parameters:
        ///   - email: The new email address
        ///   - reauthorizationToken: Token from reauthorization
        public var updateEmail:
            (
                _ email: String,
                _ reauthorizationToken: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Disable email authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        public var disable: (_ reauthorizationToken: String) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential
    }
}
