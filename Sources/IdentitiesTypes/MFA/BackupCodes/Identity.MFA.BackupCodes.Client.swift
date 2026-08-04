//
//  Identity.Client.MFA.BackupCodes.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.BackupCodes {
    /// Backup codes client operations.
    @Witness
    public struct Client: @unchecked Sendable {
        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Regenerate backup codes.
        ///
        /// Returns a new set of single-use backup codes.
        public var regenerate: () async throws(any Swift.Error) -> [String]
        // swiftlint:enable no_any_protocol_existential

        /// Verify a backup code during authentication.
        ///
        /// - Parameters:
        ///   - code: The backup code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        public var verify:
            (
                _ code: String,
                _ sessionToken: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.Authentication.Response
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Get count of remaining backup codes.
        public var remaining: () async throws(any Swift.Error) -> Int
        // swiftlint:enable no_any_protocol_existential
    }
}
