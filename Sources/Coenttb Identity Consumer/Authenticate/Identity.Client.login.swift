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
        refreshToken: @escaping (Vapor.Request) -> String?,
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
                
                // If token is still valid and NOT near expiration, return existing auth
                if date().addingTimeInterval(expirationBuffer) < currentToken.expiration.value {
                    // Token is still valid and not near expiration
                    // Return a response with the current token information
                    return .init(
                        accessToken: .init(value: accessToken, expiresIn: currentToken.expiration.value.timeIntervalSince(date())),
                        refreshToken: try await refreshOrReuse(refreshToken(request))
                    )
                }
                
                // Token is near expiration, try to refresh it
                guard let refreshTokenValue = refreshToken(request) else {
                    throw Identity.Client.Authenticate.Error.noTokensAvailable
                }
                
                return try await authenticate.token.refresh(token: refreshTokenValue)
            } catch let error as Identity.Client.Authenticate.Error {
                // Handle specific authentication errors
                if case .tokenNearExpiration = error {
                    // Try to refresh using the refresh token
                    if let refreshTokenValue = refreshToken(request) {
                        return try await authenticate.token.refresh(token: refreshTokenValue)
                    }
                }
                
                throw error
            } catch {
                // Access token failed, try refresh token as fallback
            }
        }
        
        // If we get here, either there was no access token or it failed validation
        // Try to use refresh token
        if let refreshTokenValue = refreshToken(request) {
            do {
                return try await authenticate.token.refresh(token: refreshTokenValue)
            } catch {
                throw error
            }
        }
        
        // No tokens available
        throw Identity.Client.Authenticate.Error.noTokensAvailable
    }
    
    // Helper method to reuse existing refresh token or get a new one
    private func refreshOrReuse(_ refreshToken: String?) async throws -> JWT.Token {
        if let refreshToken = refreshToken {
            return .init(value: refreshToken, expiresIn: 86400) // Default to 24 hours if we can't determine
        }
        
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
