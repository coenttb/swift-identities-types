//
//  Identity.Client.MFA.TOTP.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client.MFA {
    /// TOTP (Time-based One-Time Password) client operations.
    @DependencyClient
    public struct TOTP: @unchecked Sendable {
        /// Initialize TOTP setup.
        ///
        /// Returns secret and QR code URL for authenticator app setup.
        @DependencyEndpoint
        public var setup: () async throws -> Identity.MFA.TOTP.SetupResponse
        
        /// Confirm TOTP setup with verification code.
        ///
        /// - Parameter code: The TOTP code from the authenticator app
        /// - Returns: Backup codes for account recovery
        @DependencyEndpoint
        public var confirmSetup: (_ code: String) async throws -> [String]
        
        /// Verify TOTP code during authentication.
        ///
        /// - Parameters:
        ///   - code: The TOTP code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        @DependencyEndpoint
        public var verify: (
            _ code: String,
            _ sessionToken: String
        ) async throws -> Identity.Authentication.Response
        
        /// Disable TOTP authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        @DependencyEndpoint
        public var disable: (_ reauthorizationToken: String) async throws -> Void
    }
}