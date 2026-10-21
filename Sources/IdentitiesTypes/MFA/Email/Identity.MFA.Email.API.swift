//
//  Identity.MFA.Email.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA.Email {
    /// Email-based authentication operations.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Setup email MFA
        case setup(Identity.MFA.Email.Setup)

        /// Request a new email code
        case requestCode

        /// Verify email code during authentication
        case verify(Identity.MFA.Email.Verify)

        /// Update email address for MFA
        case updateEmail(Identity.MFA.Email.UpdateEmail)

        /// Disable email authentication
        case disable(Identity.MFA.DisableRequest)
    }
}

extension Identity.MFA.Email.API: HTTP.Routable {
    /// Router for Email endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.Email.API> {
        Coder::Case(
            Identity.MFA.Email.API.cases.setup.prism,
            Identity.MFA.Email.API.cases.setup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.setup
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.Email.Setup>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.Email.API.cases.requestCode.prism,
            Identity.MFA.Email.API.cases.requestCode.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("request")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.Email.API.cases.verify.prism,
            Identity.MFA.Email.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.verify
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.Email.Verify>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.Email.API.cases.updateEmail.prism,
            Identity.MFA.Email.API.cases.updateEmail.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.update
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.Email.UpdateEmail>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.Email.API.cases.disable.prism,
            Identity.MFA.Email.API.cases.disable.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.disable
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.DisableRequest>())
            HTTP.Segment.End()
        }
    }
}
