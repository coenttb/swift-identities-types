//
//  Identity.Consumer.Client.login.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Dependencies
import Identities

extension Identity.Client {
    public func login(
        accessToken: String?,
        refreshToken: (Vapor.Request) -> String?,
        expirationBuffer: TimeInterval = 300
    ) async throws -> Identity.Authentication.Response {
        
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        @Dependency(\.date) var date
        
        // First, try to use the access token if available
        if let accessToken = accessToken {
            do {
                try await authenticate.token.access(token: accessToken)
                
                // Check if token is near expiration and needs refresh
                guard let currentToken = request.auth.get(JWT.Token.Access.self)
                else { throw Identity.Client.Authenticate.Error.unauthorizedAccess }
                
                // If token is valid and not near expiration, no refresh needed
                if date().addingTimeInterval(expirationBuffer) < currentToken.expiration.value {
                    throw Identity.Client.Authenticate.Error.tokenNearExpiration
                }
                
                // Token is near expiration, try to refresh it
                guard let refreshTokenValue = refreshToken(request) else {
                    throw Identity.Client.Authenticate.Error.noTokensAvailable
                }
                
                return try await authenticate.token.refresh(token: refreshTokenValue)
            } catch let error as Identity.Client.Authenticate.Error {
                // Propagate authenticate errors
                throw error
            } catch {
                // Access token failed, try refresh token as fallback
                // Let it continue to the refresh token flow below
            }
        }
        
        // If we get here, either there was no access token or it failed validation
        // Try to use refresh token
        if let refreshTokenValue = refreshToken(request) {
            do {
                return try await authenticate.token.refresh(token: refreshTokenValue)
            } catch {
                // Just propagate the error, response handling is done in the response layer
                throw error
            }
        }
        
        // No tokens available
        throw Identity.Client.Authenticate.Error.noTokensAvailable
    }
}

extension Identity.Client.Authenticate {
    enum Error: Swift.Error {
        case noTokensAvailable
        case tokenNearExpiration
        case unauthorizedAccess
    }
}
