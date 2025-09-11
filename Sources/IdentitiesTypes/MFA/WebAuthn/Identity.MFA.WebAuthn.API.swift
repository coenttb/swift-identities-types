//
//  Identity.MFA.WebAuthn.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.WebAuthn {
    /// WebAuthn/FIDO2 authentication operations.
    @CasePathable
    @dynamicMemberLookup
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

extension Identity.MFA.WebAuthn.API {
    /// Router for WebAuthn endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.WebAuthn.API> {
            OneOf {
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.beginRegistration)) {
                    Method.post
                    Path { "register" }
                    Path { "begin" }
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.finishRegistration)) {
                    Method.post
                    Path { "register" }
                    Path { "finish" }
                    Body(.json(Identity.MFA.WebAuthn.FinishRegistration.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.beginAuthentication)) {
                    Method.post
                    Path { "authenticate" }
                    Path { "begin" }
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.finishAuthentication)) {
                    Method.post
                    Path { "authenticate" }
                    Path { "finish" }
                    Body(.json(Identity.MFA.WebAuthn.FinishAuthentication.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.listCredentials)) {
                    Method.get
                    Path { "credentials" }
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.removeCredential)) {
                    Method.post
                    Path { "credentials" }
                    Path { "remove" }
                    Body(.json(Identity.MFA.WebAuthn.RemoveCredential.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.WebAuthn.API.disable)) {
                    Method.post
                    Path.disable
                    Body(.json(Identity.MFA.DisableRequest.self))
                }
            }
        }
    }
}
