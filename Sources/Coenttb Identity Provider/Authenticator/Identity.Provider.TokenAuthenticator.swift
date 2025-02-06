//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import JWT
import Coenttb_Identity_Shared


extension Identity.Provider {
    public struct TokenAuthenticator: JWTAuthenticator {
        public typealias Payload = Coenttb_Identity_Shared.JWT.Payload
        public typealias User = Database.Identity
        
        public func authenticate(jwt: Coenttb_Identity_Shared.JWT.Payload, for request: Request) async throws {
            guard let identity = try await Database.Identity.find(jwt.identityId, on: request.db) else {
                throw Abort(.unauthorized, reason: "Identity not found")
            }
            
            // Verify the session version matches to handle revocation
            guard identity.sessionVersion == jwt.sessionVersion else {
                throw Abort(.unauthorized, reason: "Session has been invalidated")
            }
            
            // Verify email hasn't changed
            guard identity.email == jwt.email else {
                throw Abort(.unauthorized, reason: "Identity details have changed")
            }
            
            request.auth.login(identity)
        }
    }
}
