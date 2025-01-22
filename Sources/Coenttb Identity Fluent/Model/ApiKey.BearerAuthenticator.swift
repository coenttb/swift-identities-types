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
    public struct BearerAuthenticator: AsyncBearerAuthenticator {
        public typealias User = Identity
        
        public init() {}

        public func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
            guard let token = try await Identity.Token.query(on: request.db)
                .filter(\.$value == bearer.token)
                .filter(\.$type == .apiAccess)
                .with(\.$identity)
                .first()
            else { return }
            
            // Verify token is still valid
            guard token.isValid else {
                try await token.delete(on: request.db)
                return
            }
            
            // Update usage timestamp
            token.lastUsedAt = Date()
            try await token.save(on: request.db)
            
            // Handle token rotation if needed
            
            do {
                let rotatedToken: Identity.Token = try await token.rotateIfNecessary(on: request.db)
                guard
                 rotatedToken.id != token.id
                else {
                    fatalError()
                }
                request.headers.bearerAuthorization = .init(token: rotatedToken.value)
                
                request.auth.login(token.identity)
            }
        }
    }
}
