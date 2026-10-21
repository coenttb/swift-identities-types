//
//  Identity.MFA.Status.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA.Status {
    /// General MFA status operations.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Get the current MFA status including configured methods and requirements
        case get

        /// Get MFA challenge after authentication
        case challenge
    }
}

extension Identity.MFA.Status.API: HTTP.Routable {
    /// Router for Status endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.Status.API> {
        Coder::Case(
            Identity.MFA.Status.API.cases.get.prism,
            Identity.MFA.Status.API.cases.get.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.Status.API.cases.challenge.prism,
            Identity.MFA.Status.API.cases.challenge.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment.challenge
            HTTP.Segment.End()
        }
    }
}
