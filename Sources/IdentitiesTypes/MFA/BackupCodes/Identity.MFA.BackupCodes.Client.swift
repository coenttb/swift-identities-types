//
//  Identity.Client.MFA.BackupCodes.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.MFA.BackupCodes {
    /// Backup codes client operations.
    @DependencyClient
    public struct Client: @unchecked Sendable {
        /// Regenerate backup codes.
        ///
        /// Returns a new set of single-use backup codes.
        @DependencyEndpoint
        public var regenerate: () async throws -> [String]
        
        /// Verify a backup code during authentication.
        ///
        /// - Parameters:
        ///   - code: The backup code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        @DependencyEndpoint
        public var verify: (
            _ code: String,
            _ sessionToken: String
        ) async throws -> Identity.Authentication.Response
        
        /// Get count of remaining backup codes.
        @DependencyEndpoint
        public var remaining: () async throws -> Int
    }
}
