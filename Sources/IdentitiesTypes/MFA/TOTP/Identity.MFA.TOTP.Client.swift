//
//  Identity.MFA.TOTP.Client.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.MFA.TOTP {
  /// Client for managing TOTP operations
  @DependencyClient
  public struct Client: @unchecked Sendable {

    // MARK: - Setup Operations

    /// Generate a new TOTP secret for initial setup
    @DependencyEndpoint
    public var generateSecret: () async throws -> SetupData

    /// Confirm TOTP setup by verifying the initial code
    @DependencyEndpoint
    public var confirmSetup:
      (
        _ identityId: Identity.ID,
        _ secret: String,
        _ code: String
      ) async throws -> Void

    // MARK: - Verification Operations

    /// Verify a TOTP code during authentication
    @DependencyEndpoint
    public var verifyCode:
      (
        _ identityId: Identity.ID,
        _ code: String
      ) async throws -> Bool

    /// Verify a TOTP code with custom window
    @DependencyEndpoint
    public var verifyCodeWithWindow:
      (
        _ identityId: Identity.ID,
        _ code: String,
        _ window: Int
      ) async throws -> Bool

    /// Verify a TOTP code during MFA login flow.
    ///
    /// This method is used during the MFA challenge after initial authentication.
    /// It validates the TOTP code and exchanges the session token for full authentication tokens.
    ///
    /// - Parameters:
    ///   - code: The TOTP code from the authenticator app
    ///   - sessionToken: The MFA session token from initial authentication
    /// - Returns: Full authentication response with access and refresh tokens
    @DependencyEndpoint
    public var verify:
      (
        _ code: String,
        _ sessionToken: String
      ) async throws -> Identity.Authentication.Response

    // MARK: - Backup Code Operations

    /// Generate backup codes for recovery
    @DependencyEndpoint
    public var generateBackupCodes:
      (
        _ identityId: Identity.ID,
        _ count: Int
      ) async throws -> [String]

    /// Verify a backup code
    @DependencyEndpoint
    public var verifyBackupCode:
      (
        _ identityId: Identity.ID,
        _ code: String
      ) async throws -> Bool

    /// Get remaining backup codes count
    @DependencyEndpoint
    public var remainingBackupCodes:
      (
        _ identityId: Identity.ID
      ) async throws -> Int

    // MARK: - Management Operations

    /// Check if TOTP is enabled for an identity
    @DependencyEndpoint
    public var isEnabled:
      (
        _ identityId: Identity.ID
      ) async throws -> Bool

    /// Disable TOTP for an identity
    @DependencyEndpoint
    public var disable:
      (
        _ identityId: Identity.ID
      ) async throws -> Void

    /// Get TOTP status for an identity
    @DependencyEndpoint
    public var getStatus:
      (
        _ identityId: Identity.ID
      ) async throws -> Status

    // MARK: - QR Code Generation

    /// Generate QR code URL for authenticator apps
    @DependencyEndpoint
    public var generateQRCodeURL:
      (
        _ secret: String,
        _ email: String,
        _ issuer: String
      ) async throws -> URL
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
