//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 22/01/2025.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

extension Identity {
    public struct SessionAuthenticator: AsyncSessionAuthenticator {
        public typealias User = Identity
        
        public init() {}

        
        public func authenticate(sessionID: UUID, for request: Request) async throws {
            guard let identity = try await Identity.find(sessionID, on: request.db)
            else { return }
            
            if
                let storedVersion = request.session.data[Identity.FieldKeys.sessionVersion.description].flatMap({ Int($0) }),
                storedVersion != identity.sessionVersion {
                request.session.unauthenticate(Identity.self)
                return
            }
            
            identity.lastLoginAt = Date()
            try await identity.save(on: request.db)
            
            request.auth.login(identity)
            
            request.session.data[Identity.FieldKeys.sessionVersion.description] = "\(identity.sessionVersion)"
        }
    }
}

