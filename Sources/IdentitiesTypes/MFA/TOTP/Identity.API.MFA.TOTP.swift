//
//  Identity.API.MFA.TOTP.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API.MFA {
    /// TOTP (Time-based One-Time Password) operations.
    ///
    /// Supports authenticator apps like Google Authenticator, Authy, etc.
    @CasePathable
    @dynamicMemberLookup
    public enum TOTP: Equatable, Sendable {
        /// Initialize TOTP setup (returns secret and QR code)
        case setup
        
        /// Confirm TOTP setup with verification code
        case confirmSetup(Identity.MFA.TOTP.ConfirmSetup)
        
        /// Verify TOTP code during authentication
        case verify(Identity.MFA.TOTP.Verify)
        
        /// Disable TOTP authentication
        case disable(Identity.MFA.DisableRequest)
        
        public static let confirmSetup: Self = .confirmSetup(.init(code: ""))
    }
}

extension Identity.API.MFA.TOTP {
    /// Router for TOTP endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MFA.TOTP> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MFA.TOTP.setup)) {
                    Method.post
                    Path.setup
                }
                
                URLRouting.Route(.case(Identity.API.MFA.TOTP.confirmSetup)) {
                    Method.post
                    Path.confirm
                    Body(.form(Identity.MFA.TOTP.ConfirmSetup.self, decoder: .identities))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.TOTP.verify)) {
                    Method.post
                    Path.verify
                    Body(.json(Identity.MFA.TOTP.Verify.self))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.TOTP.disable)) {
                    Method.post
                    Path.disable
                    Body(.json(Identity.MFA.DisableRequest.self))
                }
            }
        }
    }
}
