//
//  Identity.API.MFA.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API.MFA {
    /// Email-based authentication operations.
    @CasePathable
    @dynamicMemberLookup
    public enum Email: Equatable, Sendable {
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

extension Identity.API.MFA.Email {
    /// Router for Email endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MFA.Email> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MFA.Email.setup)) {
                    Method.post
                    Path.setup
                    Body(.json(Identity.MFA.Email.Setup.self))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Email.requestCode)) {
                    Method.post
                    Path { "request" }
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Email.verify)) {
                    Method.post
                    Path.verify
                    Body(.json(Identity.MFA.Email.Verify.self))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Email.updateEmail)) {
                    Method.post
                    Path.update
                    Body(.json(Identity.MFA.Email.UpdateEmail.self))
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Email.disable)) {
                    Method.post
                    Path.disable
                    Body(.json(Identity.MFA.DisableRequest.self))
                }
            }
        }
    }
}