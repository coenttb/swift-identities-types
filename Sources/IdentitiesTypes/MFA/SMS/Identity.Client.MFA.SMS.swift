//
//  Identity.Client.MFA.SMS.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client.MFA {
    /// SMS-based authentication client operations.
    @DependencyClient
    public struct SMS: @unchecked Sendable {
        /// Setup SMS authentication with phone number.
        ///
        /// - Parameter phoneNumber: The phone number to receive SMS codes
        @DependencyEndpoint
        public var setup: (_ phoneNumber: String) async throws -> Void
        
        /// Request a new SMS code.
        @DependencyEndpoint
        public var requestCode: () async throws -> Void
        
        /// Verify SMS code during authentication.
        ///
        /// - Parameters:
        ///   - code: The SMS code
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        @DependencyEndpoint
        public var verify: (
            _ code: String,
            _ sessionToken: String
        ) async throws -> Identity.Authentication.Response
        
        /// Update phone number for SMS authentication.
        ///
        /// - Parameters:
        ///   - phoneNumber: The new phone number
        ///   - reauthorizationToken: Token from reauthorization
        @DependencyEndpoint
        public var updatePhoneNumber: (
            _ phoneNumber: String,
            _ reauthorizationToken: String
        ) async throws -> Void
        
        /// Disable SMS authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        @DependencyEndpoint
        public var disable: (_ reauthorizationToken: String) async throws -> Void
    }
}