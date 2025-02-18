//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Dependencies
import Identity_Consumer
import Identity_Shared

extension Identity.Client {
    public func login(
        request: Request,
        accessToken: String?,
        refreshToken: (Vapor.Request) -> String?,
        expirationBuffer: TimeInterval = 300
    ) async throws -> Identity.Authentication.Response? {
        
        @Dependency(\.date) var date
        
        guard let accessToken = accessToken
        else {
            guard let refreshToken = request.cookies.refreshToken?.string
            else { return nil }
            
            return try await authenticate.token.refresh(token: refreshToken)
        }

        do {
            try await authenticate.token.access(token: accessToken)
            
            guard let currentToken = request.auth.get(JWT.Token.Access.self)
            else { throw Abort(.unauthorized) }
            
            guard date().addingTimeInterval(expirationBuffer) < currentToken.expiration.value
            else {
                guard let refreshToken = refreshToken(request)
                else { throw Abort(.unauthorized) }
                
                return try await authenticate.token.refresh(token: refreshToken)
            }
            
            return nil
        } catch {
            guard let refreshToken = request.cookies.refreshToken?.string else {
                return nil
            }
            return try await authenticate.token.refresh(token: refreshToken)
        }
    }
}
