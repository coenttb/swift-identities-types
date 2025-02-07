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

extension Database.Identity {
    public func generateJWTAccess(
        config: JWT.Token.PayloadConfig,
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) async throws -> String {
        @Dependency(\.request) var request
        
        guard let request else { throw Abort(.internalServerError) }
        
        let payload = try JWT.Token.Access(
            identity: self,
            config: config,
            includeTokenId: includeTokenId,
            includeNotBefore: includeNotBefore
        )
        return try await request.jwt.sign(payload)
    }
    
    public func generateJWTRefresh(
        config: JWT.Token.PayloadConfig,
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) async throws -> String {
        @Dependency(\.request) var request
        
        guard let request else { throw Abort(.internalServerError) }
        
        let payload = try JWT.Token.Access(
            identity: self,
            config: config,
            includeTokenId: includeTokenId,
            includeNotBefore: includeNotBefore
        )
        return try await request.jwt.sign(payload)
    }
    
    public func generateJWTResponse(
        accessTokenConfig: JWT.Token.PayloadConfig,
        refreshTokenConfig: JWT.Token.PayloadConfig
    ) async throws -> JWT.Response {
        
        @Dependency(\.request) var request
        // Generate access token with short lifetime and token ID
        let accessToken = try await self.generateJWTAccess(
            config: accessTokenConfig,
            includeTokenId: true,  // Always include jti for access tokens
            includeNotBefore: true // Immediate validity
        )
        
        // Generate refresh token with longer lifetime and token ID
        let refreshToken = try await self.generateJWTRefresh(
            config: refreshTokenConfig,
            includeTokenId: true,   // Always include jti for refresh tokens
            includeNotBefore: false // Allow some clock skew for refresh
        )
        
        return .init(
            accessToken: .init(
                value: accessToken,
                type: "Bearer",
                expiresIn: accessTokenConfig.expiration
            ),
            refreshToken: .init(
                value: refreshToken,
                type: "Bearer",
                expiresIn: refreshTokenConfig.expiration
            )
        )
    }
}


extension JWT.Token.Access {
    public init(
        identity: Database.Identity,
        config: JWT.Token.PayloadConfig,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        self = .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            subject: SubjectClaim(value: try identity.requireID().uuidString),
            issuer: IssuerClaim(value: config.issuer),
            audience: "access",
            notBefore: includeNotBefore ? NotBeforeClaim(value: currentTime) : nil,
            tokenId: includeTokenId ? IDClaim(value: uuid().uuidString) : nil,
            identityId: try identity.requireID(),
            email: identity.email
        )
    }
}

extension JWT.Token.Refresh {
    public init(
        identity: Database.Identity,
        config: JWT.Token.PayloadConfig,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        self = .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            subject: SubjectClaim(value: try identity.requireID().uuidString),
            issuer: IssuerClaim(value: config.issuer),
            audience: "refresh",
            tokenId: IDClaim(value: uuid().uuidString),
            notBefore: includeNotBefore ? NotBeforeClaim(value: currentTime) : nil,
            identityId: try identity.requireID(),
            email: identity.email,
            sessionVersion: identity.sessionVersion
        )
    }
}
