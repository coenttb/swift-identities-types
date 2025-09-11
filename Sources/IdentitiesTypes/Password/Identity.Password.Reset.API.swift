//
//  Identity.Password.Reset.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import CasePaths
import TypesFoundation

extension Identity.Password.Reset {
    /// Password reset API endpoints.
    @CasePathable
    @dynamicMemberLookup
    public enum API: Equatable, Sendable {
        /// Request a password reset via email
        case request(Identity.Password.Reset.Request)
        
        /// Confirm password reset with token and new password
        case confirm(Identity.Password.Reset.Confirm)
    }
}

extension Identity.Password.Reset.API {
    /// Router for password reset endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Password.Reset.API> {
            OneOf {
                URLRouting.Route(.case(Identity.Password.Reset.API.request)) {
                    Identity.Password.Reset.Request.Router()
                }
                
                URLRouting.Route(.case(Identity.Password.Reset.API.confirm)) {
                    Identity.Password.Reset.Confirm.Router()
                }
            }
        }
    }
}
