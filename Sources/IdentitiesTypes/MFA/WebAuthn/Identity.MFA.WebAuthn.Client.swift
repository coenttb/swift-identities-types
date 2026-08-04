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
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            () async throws(any Swift.Error) -> Identity.MFA.WebAuthn.BeginRegistrationResponse
        // swiftlint:enable no_any_protocol_existential

        /// Complete WebAuthn registration.
        ///
        /// - Parameters:
        ///   - credentialName: A friendly name for the credential
        ///   - response: The credential response from the browser
        public var finishRegistration:
            (
                _ credentialName: String,
                _ response: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        /// Begin WebAuthn authentication process.
        ///
        /// Returns challenge and options for credential assertion.
        public var beginAuthentication:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            () async throws(any Swift.Error) -> Identity.MFA.WebAuthn.BeginAuthenticationResponse
        // swiftlint:enable no_any_protocol_existential

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
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.Authentication.Response
        // swiftlint:enable no_any_protocol_existential

        /// List registered WebAuthn credentials.
        public var listCredentials:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            () async throws(any Swift.Error) -> [Identity.MFA.WebAuthn.Credential]
        // swiftlint:enable no_any_protocol_existential

        /// Remove a WebAuthn credential.
        ///
        /// - Parameters:
        ///   - credentialId: The ID of the credential to remove
        ///   - reauthorizationToken: Token from reauthorization
        public var removeCredential:
            (
                _ credentialId: String,
                _ reauthorizationToken: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Disable all WebAuthn authentication.
        ///
        /// - Parameter reauthorizationToken: Token from reauthorization
        public var disable: (_ reauthorizationToken: String) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential
    }
}
