//
//  Identity.MFA.TOTP.Client.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.TOTP {
    /// Client for managing TOTP operations
    @Witness
    public struct Client: @unchecked Sendable {

        // MARK: - Setup Operations

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Generate a new TOTP secret for initial setup
        public var generateSecret: () async throws(any Swift.Error) -> SetupData
        // swiftlint:enable no_any_protocol_existential

        /// Confirm TOTP setup by verifying the initial code
        public var confirmSetup:
            (
                _ identityId: Identity.ID,
                _ secret: String,
                _ code: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        // MARK: - Verification Operations

        /// Verify a TOTP code during authentication
        public var verifyCode:
            (
                _ identityId: Identity.ID,
                _ code: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Bool
        // swiftlint:enable no_any_protocol_existential

        /// Verify a TOTP code with custom window
        public var verifyCodeWithWindow:
            (
                _ identityId: Identity.ID,
                _ code: String,
                _ window: Int
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Bool
        // swiftlint:enable no_any_protocol_existential

        /// Verify a TOTP code during MFA login flow.
        ///
        /// This method is used during the MFA challenge after initial authentication.
        /// It validates the TOTP code and exchanges the session token for full authentication tokens.
        ///
        /// - Parameters:
        ///   - code: The TOTP code from the authenticator app
        ///   - sessionToken: The MFA session token from initial authentication
        /// - Returns: Full authentication response with access and refresh tokens
        public var verify:
            (
                _ code: String,
                _ sessionToken: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.Authentication.Response
        // swiftlint:enable no_any_protocol_existential

        // MARK: - Backup Code Operations

        /// Generate backup codes for recovery
        public var generateBackupCodes:
            (
                _ identityId: Identity.ID,
                _ count: Int
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> [String]
        // swiftlint:enable no_any_protocol_existential

        /// Verify a backup code
        public var verifyBackupCode:
            (
                _ identityId: Identity.ID,
                _ code: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Bool
        // swiftlint:enable no_any_protocol_existential

        /// Get remaining backup codes count
        public var remainingBackupCodes:
            (
                _ identityId: Identity.ID
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Int
        // swiftlint:enable no_any_protocol_existential

        // MARK: - Management Operations

        /// Check if TOTP is enabled for an identity
        public var isEnabled:
            (
                _ identityId: Identity.ID
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Bool
        // swiftlint:enable no_any_protocol_existential

        /// Disable TOTP for an identity
        public var disable:
            (
                _ identityId: Identity.ID
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        /// Get TOTP status for an identity
        public var getStatus:
            (
                _ identityId: Identity.ID
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Status
        // swiftlint:enable no_any_protocol_existential

        // MARK: - QR Code Generation

        /// Generate QR code URL for authenticator apps
        public var generateQRCodeURL:
            (
                _ secret: String,
                _ email: String,
                _ issuer: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> URL
        // swiftlint:enable no_any_protocol_existential
    }
}

// MARK: - Types

extension Identity.MFA.TOTP.Client {
    public struct SetupData: Codable, Equatable, Sendable {
        public let secret: String  // Base32 encoded
        public let qrCodeURL: URL
        public let manualEntryKey: String

        public init(
            secret: String,
            qrCodeURL: URL,
            manualEntryKey: String
        ) {
            self.secret = secret
            self.qrCodeURL = qrCodeURL
            self.manualEntryKey = manualEntryKey
        }
    }

    public struct Status: Codable, Equatable, Sendable {
        public let isEnabled: Bool
        public let isConfirmed: Bool
        public let backupCodesRemaining: Int
        public let lastUsedAt: Date?

        public init(
            isEnabled: Bool,
            isConfirmed: Bool,
            backupCodesRemaining: Int,
            lastUsedAt: Date? = nil
        ) {
            self.isEnabled = isEnabled
            self.isConfirmed = isConfirmed
            self.backupCodesRemaining = backupCodesRemaining
            self.lastUsedAt = lastUsedAt
        }
    }
}

// MARK: - Errors

extension Identity.MFA.TOTP.Client {
    public enum ClientError: Swift.Error, Equatable {
        case totpNotEnabled
        case totpAlreadyEnabled
        case invalidSecret
        case invalidCode
        case setupNotConfirmed
        case verificationFailed
        case backupCodeGenerationFailed
        case noBackupCodesRemaining
        case configurationError(String)
    }
}
