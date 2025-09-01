//
//  Identity.Client.MFA.WebAuthn.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client.MFA {
    /// WebAuthn/FIDO2 authentication client operations.
    @DependencyClient
    public struct WebAuthn: @unchecked Sendable {
        /// Begin WebAuthn registration process.
        ///
        /// Returns challenge and options for credential creation.
        @DependencyEndpoint
        public var beginRegistration: () async throws -> Identity.MFA.WebAuthn.BeginRegistrationResponse
        
        /// Complete WebAuthn registration.
        ///
        /// - Parameters:
        ///   - credentialName: A friendly name for the credential
        ///   - response: The credential response from the browser
        @DependencyEndpoint
        public var finishRegistration: (
            _ credentialName: String,
            _ response: String
        ) async throws -> Void
        
        /// Begin WebAuthn authentication process.
        ///
        /// Returns challenge and options for credential assertion.
        @DependencyEndpoint
        public var beginAuthentication: () async throws -> Identity.MFA.WebAuthn.BeginAuthenticationResponse
        
        /// Complete WebAuthn authentication.
        ///
        /// - Parameters:
        ///   - response: The credential response from the browser
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        @DependencyEndpoint
        public var finishAuthentication: (
            _ response: String,
            _ sessionToken: String
        ) async throws -> Identity.Authentication.Response
        
        /// List registered WebAuthn credentials.
        @DependencyEndpoint
        public var listCredentials: () async throws -> [Identity.MFA.WebAuthn.Credential]
        
        /// Remove a WebAuthn credential.
        ///
        /// - Parameters:
        ///   - credentialId: The ID of the credential to remove
        ///   - reauthorizationToken: Token from reauthorization
        @DependencyEndpoint
        public var removeCredential: (
            _ credentialId: String,
            _ reauthorizationToken: String
        ) async throws -> Void
        
        /// Disable all WebAuthn authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        @DependencyEndpoint
        public var disable: (_ reauthorizationToken: String) async throws -> Void
    }
}