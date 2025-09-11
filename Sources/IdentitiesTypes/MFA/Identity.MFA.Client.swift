//
//  Identity.Client.MFA.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.MFA {
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
    public struct Client: @unchecked Sendable {
        /// TOTP authentication support.
        public var totp: Identity.MFA.TOTP.Client?
        
        /// SMS authentication support.
        public var sms: Identity.MFA.SMS.Client?
        
        /// Email authentication support.
        public var email: Identity.MFA.Email.Client?
        
        /// WebAuthn authentication support.
        public var webauthn: Identity.MFA.WebAuthn.Client?
        
        /// Backup codes support.
        public var backupCodes: Identity.MFA.BackupCodes.Client?
        
        /// General MFA status operations.
        public var status: Identity.MFA.Status.Client
        
        public init(
            totp: Identity.MFA.TOTP.Client? = nil,
            sms: Identity.MFA.SMS.Client? = nil,
            email: Identity.MFA.Email.Client? = nil,
            webauthn: Identity.MFA.WebAuthn.Client? = nil,
            backupCodes: Identity.MFA.BackupCodes.Client? = nil,
            status: Identity.MFA.Status.Client = .init()
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
