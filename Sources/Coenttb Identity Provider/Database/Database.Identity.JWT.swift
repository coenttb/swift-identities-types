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
    public func generateJWT(
            req: Request,
            config: JWT.Payload.Config,
            includeTokenId: Bool = false,
            includeNotBefore: Bool = false
        ) async throws -> String {
            let payload = try JWT.Payload(
                identity: self,
                config: config,
                includeTokenId: includeTokenId,
                includeNotBefore: includeNotBefore
            )
            return try await req.jwt.sign(payload)
        }
    
    public func generateJWTResponse(
        req: Request,
        config: JWT.Payload.Config,
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) async throws -> JWT.Response {
        let token = try await self.generateJWT(
            req: req,
            config: config,
            includeTokenId: includeTokenId,
            includeNotBefore: includeNotBefore
        )
        return .init(token: token, expiresIn: config.expiration)
    }
}

extension JWT.Payload {
    public init(
        identity: Database.Identity,
        config: Config,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        self = JWT.Payload(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            subject: SubjectClaim(value: try identity.requireID().uuidString),
            issuer: IssuerClaim(value: config.issuer),
            notBefore: includeNotBefore ? NotBeforeClaim(value: currentTime) : nil,
            audience: config.audience.map(AudienceClaim.init),
            tokenId: includeTokenId ? IDClaim(value: uuid().uuidString) : nil,
            identityId: try identity.requireID(),
            email: identity.email,
            sessionVersion: identity.sessionVersion
        )
    }
}
