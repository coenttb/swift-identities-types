//
//  Identity.API.MFA.BackupCodes.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API.MFA {
    /// Backup code operations.
    @CasePathable
    @dynamicMemberLookup
    public enum BackupCodes: Equatable, Sendable {
        /// Regenerate backup codes
        case regenerate
        
        /// Verify a backup code during authentication
        case verify(Identity.MFA.BackupCodes.Verify)
        
        /// Get count of remaining codes
        case remaining
    }
}

extension Identity.API.MFA.BackupCodes {
    /// Router for BackupCodes endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MFA.BackupCodes> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MFA.BackupCodes.regenerate)) {
                    Method.post
                    Path { "regenerate" }
                }
                
                URLRouting.Route(.case(Identity.API.MFA.BackupCodes.verify)) {
                    Method.post
                    Path.verify
                    Body(.json(Identity.MFA.BackupCodes.Verify.self))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.BackupCodes.remaining)) {
                    Method.get
                    Path { "remaining" }
                }
            }
        }
    }
}
