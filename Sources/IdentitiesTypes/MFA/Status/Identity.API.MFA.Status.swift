//
//  Identity.API.MFA.Status.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API.MFA {
    /// General MFA status operations.
    @CasePathable
    @dynamicMemberLookup
    public enum Status: Equatable, Sendable {
        /// Get configured MFA methods
        case configured
        
        /// Check if MFA is required by policy
        case isRequired
        
        /// Get MFA challenge after authentication
        case challenge
    }
}

extension Identity.API.MFA.Status {
    /// Router for Status endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MFA.Status> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MFA.Status.configured)) {
                    Method.get
                    Path { "configured" }
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Status.isRequired)) {
                    Method.get
                    Path { "required" }
                }
                
                URLRouting.Route(.case(Identity.API.MFA.Status.challenge)) {
                    Method.get
                    Path.challenge
                }
            }
        }
    }
}