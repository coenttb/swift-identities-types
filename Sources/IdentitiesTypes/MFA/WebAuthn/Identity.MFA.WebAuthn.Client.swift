//
//  Identity.Client.MFA.WebAuthn.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.WebAuthn {
    /// WebAuthn/FIDO2 authentication client operations.
    @Witness
    public struct Client: @unchecked Sendable {
        /// Begin WebAuthn registration process.
        ///
        /// Returns challenge and options for credential creation.
        public var beginRegistration:
            () async throws(any Swift.Error) -> Identity.MFA.WebAuthn.BeginRegistrationResponse

        /// Complete WebAuthn registration.
        ///
        /// - Parameters:
        ///   - credentialName: A friendly name for the credential
        ///   - response: The credential response from the browser
        public var finishRegistration:
            (
                _ credentialName: String,
                _ response: String
            ) async throws(any Swift.Error) -> Void

        /// Begin WebAuthn authentication process.
        ///
        /// Returns challenge and options for credential assertion.
        public var beginAuthentication:
            () async throws(any Swift.Error) -> Identity.MFA.WebAuthn.BeginAuthenticationResponse

        /// Complete WebAuthn authentication.
        ///
        /// - Parameters:
        ///   - response: The credential response from the browser
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        public var finishAuthentication:
            (
                _ response: String,
                _ sessionToken: String
            ) async throws(any Swift.Error) -> Identity.Authentication.Response

        /// List registered WebAuthn credentials.
        public var listCredentials:
            () async throws(any Swift.Error) -> [Identity.MFA.WebAuthn.Credential]

        /// Remove a WebAuthn credential.
        ///
        /// - Parameters:
        ///   - credentialId: The ID of the credential to remove
        ///   - reauthorizationToken: Token from reauthorization
        public var removeCredential:
            (
                _ credentialId: String,
                _ reauthorizationToken: String
            ) async throws(any Swift.Error) -> Void

        /// Disable all WebAuthn authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        public var disable: (_ reauthorizationToken: String) async throws(any Swift.Error) -> Void
    }
}
