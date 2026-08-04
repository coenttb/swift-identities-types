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
        /// Regenerate backup codes.
        ///
        /// Returns a new set of single-use backup codes.
        public var regenerate: () async throws(any Swift.Error) -> [String]

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
            ) async throws(any Swift.Error) -> Identity.Authentication.Response

        /// Get count of remaining backup codes.
        public var remaining: () async throws(any Swift.Error) -> Int
    }
}
