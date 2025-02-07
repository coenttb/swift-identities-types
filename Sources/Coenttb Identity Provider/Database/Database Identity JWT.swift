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
    package func generateJWTAccess(
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) async throws -> String {
        @Dependency(\.request) var request
        @Dependency(\.accessTokenConfig) var config
        
        guard let request else { throw Abort(.internalServerError) }
        
        let payload = try JWT.Token.Access(
            identity: self,
            includeTokenId: includeTokenId,
            includeNotBefore: includeNotBefore
        )
        return try await request.jwt.sign(payload)
    }
    
    package func generateJWTRefresh(
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) async throws -> String {
        @Dependency(\.request) var request
        @Dependency(\.refreshTokenConfig) var config
        
        guard let request else { throw Abort(.internalServerError) }
        
        let payload = try JWT.Token.Access(
            identity: self,
            includeTokenId: includeTokenId,
            includeNotBefore: includeNotBefore
        )
        return try await request.jwt.sign(payload)
    }
    
    package func generateJWTResponse(
    ) async throws -> JWT.Response {
        
        @Dependency(\.request) var request
        
        let accessToken = try await self.generateJWTAccess(
            includeTokenId: true,
            includeNotBefore: true
        )
        
        let refreshToken = try await self.generateJWTRefresh(
            includeTokenId: true,
            includeNotBefore: false
        )
        
        @Dependency(\.accessTokenConfig) var accessTokenConfig
        @Dependency(\.refreshTokenConfig) var refreshTokenConfig
        
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
    package init(
        identity: Database.Identity,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.accessTokenConfig) var config
        
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
    package init(
        identity: Database.Identity,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.refreshTokenConfig) var config
        
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
