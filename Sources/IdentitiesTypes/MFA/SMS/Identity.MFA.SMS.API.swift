//
//  Identity.MFA.SMS.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA.SMS {
    /// SMS-based authentication operations.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Setup SMS with phone number
        case setup(Identity.MFA.SMS.Setup)

        /// Request a new SMS code
        case requestCode

        /// Verify SMS code during authentication
        case verify(Identity.MFA.SMS.Verify)

        /// Update phone number
        case updatePhoneNumber(Identity.MFA.SMS.UpdatePhoneNumber)

        /// Disable SMS authentication
        case disable(Identity.MFA.DisableRequest)
    }
}

extension Identity.MFA.SMS.API: HTTP.Routable {
    /// Router for SMS endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.SMS.API> {
        Coder::Case(
            Identity.MFA.SMS.API.cases.setup.prism,
            Identity.MFA.SMS.API.cases.setup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.setup
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.SMS.Setup>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.SMS.API.cases.requestCode.prism,
            Identity.MFA.SMS.API.cases.requestCode.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment("request")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.SMS.API.cases.verify.prism,
            Identity.MFA.SMS.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.verify
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.SMS.Verify>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.SMS.API.cases.updatePhoneNumber.prism,
            Identity.MFA.SMS.API.cases.updatePhoneNumber.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.update
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.SMS.UpdatePhoneNumber>())
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.SMS.API.cases.disable.prism,
            Identity.MFA.SMS.API.cases.disable.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.disable
            HTTP.Body.Coded(HTTP.Body.JSON<Identity.MFA.DisableRequest>())
            HTTP.Segment.End()
        }
    }
}
