//
//  Identity.MFA.TOTP.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTML_Form_Coder_Codable
import HTTP
import HTTP_Router

extension Identity.MFA.TOTP {
    /// TOTP (Time-based One-Time Password) operations.
    ///
    /// Supports authenticator apps like Google Authenticator, Authy, etc.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
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

extension Identity.MFA.TOTP.API: HTTP.Routable {
    /// Router for TOTP endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.TOTP.API> {
        Coder::Case(
            Identity.MFA.TOTP.API.cases.setup.prism,
            Identity.MFA.TOTP.API.cases.setup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.setup
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.TOTP.API.cases.confirmSetup.prism,
            Identity.MFA.TOTP.API.cases.confirmSetup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.confirm
            HTTP.Body.Coded(
                HTML.Form.Coder.Value(Identity.MFA.TOTP.ConfirmSetup.self, decoder: .identities)
            )
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.TOTP.API.cases.verify.prism,
            Identity.MFA.TOTP.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.verify
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.TOTP.Verify>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.TOTP.API.cases.disable.prism,
            Identity.MFA.TOTP.API.cases.disable.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.disable
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.DisableRequest>())
            HTTP.Segment.End()
        }
    }
}
