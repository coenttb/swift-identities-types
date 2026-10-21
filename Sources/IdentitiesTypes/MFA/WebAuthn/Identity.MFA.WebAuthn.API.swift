//
//  Identity.MFA.WebAuthn.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA.WebAuthn {
    /// WebAuthn/FIDO2 authentication operations.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Initialize WebAuthn registration
        case beginRegistration

        /// Complete WebAuthn registration
        case finishRegistration(Identity.MFA.WebAuthn.FinishRegistration)

        /// Begin WebAuthn authentication
        case beginAuthentication

        /// Complete WebAuthn authentication
        case finishAuthentication(Identity.MFA.WebAuthn.FinishAuthentication)

        /// List registered credentials
        case listCredentials

        /// Remove a credential
        case removeCredential(Identity.MFA.WebAuthn.RemoveCredential)

        /// Disable all WebAuthn
        case disable(Identity.MFA.DisableRequest)
    }
}

extension Identity.MFA.WebAuthn.API: HTTP.Routable {
    /// Router for WebAuthn endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.WebAuthn.API> {
        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.beginRegistration.prism,
            Identity.MFA.WebAuthn.API.cases.beginRegistration.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("register")
            HTTP.Segment("begin")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.finishRegistration.prism,
            Identity.MFA.WebAuthn.API.cases.finishRegistration.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("register")
            HTTP.Segment("finish")
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.WebAuthn.FinishRegistration>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.beginAuthentication.prism,
            Identity.MFA.WebAuthn.API.cases.beginAuthentication.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("authenticate")
            HTTP.Segment("begin")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.finishAuthentication.prism,
            Identity.MFA.WebAuthn.API.cases.finishAuthentication.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("authenticate")
            HTTP.Segment("finish")
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.WebAuthn.FinishAuthentication>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.listCredentials.prism,
            Identity.MFA.WebAuthn.API.cases.listCredentials.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("credentials")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.removeCredential.prism,
            Identity.MFA.WebAuthn.API.cases.removeCredential.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("credentials")
            HTTP.Segment("remove")
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.WebAuthn.RemoveCredential>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.WebAuthn.API.cases.disable.prism,
            Identity.MFA.WebAuthn.API.cases.disable.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.disable
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.DisableRequest>())
            HTTP.Segment.End()
        }
    }
}
