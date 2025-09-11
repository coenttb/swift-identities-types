//
//  Identity.MFA.Email.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.Email {
    /// Email-based authentication operations.
    @CasePathable
    @dynamicMemberLookup
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

extension Identity.MFA.Email.API {
    /// Router for Email endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.Email.API> {
            OneOf {
                URLRouting.Route(.case(Identity.MFA.Email.API.setup)) {
                    Method.post
                    Path.setup
                    Body(.json(Identity.MFA.Email.Setup.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.Email.API.requestCode)) {
                    Method.post
                    Path { "request" }
                }
                
                URLRouting.Route(.case(Identity.MFA.Email.API.verify)) {
                    Method.post
                    Path.verify
                    Body(.json(Identity.MFA.Email.Verify.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.Email.API.updateEmail)) {
                    Method.post
                    Path.update
                    Body(.json(Identity.MFA.Email.UpdateEmail.self))
                }
                
                URLRouting.Route(.case(Identity.MFA.Email.API.disable)) {
                    Method.post
                    Path.disable
                    Body(.json(Identity.MFA.DisableRequest.self))
                }
            }
        }
    }
}
