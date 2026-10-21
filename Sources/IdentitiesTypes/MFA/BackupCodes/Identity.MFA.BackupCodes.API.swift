//
//  Identity.MFA.BackupCodes.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA.BackupCodes {
    /// Backup code operations.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Regenerate backup codes
        case regenerate

        /// Verify a backup code during authentication
        case verify(Identity.MFA.BackupCodes.Verify)

        /// Get count of remaining codes
        case remaining
    }
}

extension Identity.MFA.BackupCodes.API: HTTP.Routable {
    /// Router for BackupCodes endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.BackupCodes.API> {
        Coder::Case(
            Identity.MFA.BackupCodes.API.cases.regenerate.prism,
            Identity.MFA.BackupCodes.API.cases.regenerate.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("regenerate")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.BackupCodes.API.cases.verify.prism,
            Identity.MFA.BackupCodes.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.verify
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.BackupCodes.Verify>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.BackupCodes.API.cases.remaining.prism,
            Identity.MFA.BackupCodes.API.cases.remaining.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("remaining")
            HTTP.Segment.End()
        }
    }
}
