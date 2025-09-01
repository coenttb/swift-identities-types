//
//  Identity.Client.MFA.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client {
    /// Multi-factor authentication client interface.
    ///
    /// Each optional property represents an available MFA method.
    /// If a property is nil, that method is not available.
    ///
    /// Example usage:
    /// ```swift
    /// if let mfa = client.mfa {
    ///     // MFA is available
    ///     if let totp = mfa.totp {
    ///         // TOTP is available
    ///         let setup = try await totp.setup()
    ///     }
    /// }
    /// ```
    public struct MFA: @unchecked Sendable {
        /// TOTP authentication support.
        public var totp: TOTP?
        
        /// SMS authentication support.
        public var sms: SMS?
        
        /// Email authentication support.
        public var email: Email?
        
        /// WebAuthn authentication support.
        public var webauthn: WebAuthn?
        
        /// Backup codes support.
        public var backupCodes: BackupCodes?
        
        /// General MFA status operations.
        public var status: Status
        
        public init(
            totp: TOTP? = nil,
            sms: SMS? = nil,
            email: Email? = nil,
            webauthn: WebAuthn? = nil,
            backupCodes: BackupCodes? = nil,
            status: Status = .init()
        ) {
            self.totp = totp
            self.sms = sms
            self.email = email
            self.webauthn = webauthn
            self.backupCodes = backupCodes
            self.status = status
        }
    }
}