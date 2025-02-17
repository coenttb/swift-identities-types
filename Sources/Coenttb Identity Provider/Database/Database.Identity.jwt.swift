//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Dependencies
@preconcurrency import Fluent
import Foundation
import JWT

extension Database.Identity {
    package func generateJWTAccess(
    ) async throws -> String {
        @Dependency(\.application) var application

        let payload = try JWT.Token.Access(identity: self)
        
        return try await application.jwt.keys.sign(payload)
    }

    package func generateJWTRefresh() async throws -> String {
        @Dependency(\.application) var application

        let payload = try JWT.Token.Refresh(identity: self)
        
        return try await application.jwt.keys.sign(payload)
    }
    
    package func generateJWTAccess() async throws -> JWT.Token {
        @Dependency(\.identity.provider.cookies.accessToken) var config
        return try await .init(
            value: self.generateJWTAccess(),
            type: "Bearer",
            expiresIn: config.expiration
        )
    }
    
    package func generateJWTRefresh() async throws -> JWT.Token {
        @Dependency(\.identity.provider.cookies.refreshToken) var config
        return try await .init(
            value: self.generateJWTAccess(),
            type: "Bearer",
            expiresIn: config.expiration
        )
    }

}

extension Identity.Authentication.Response {
    public init(_ identity: Database.Identity) async throws {

        self = try await .init(
            accessToken: identity.generateJWTAccess(),
            refreshToken: identity.generateJWTRefresh()
        )
    }
}

extension JWT.Token.Access {
    package init(
        identity: Database.Identity
    ) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.identity.provider.cookies.accessToken) var config
        @Dependency(\.date) var date

        let currentTime = date()
        
        self = try .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            identityId: identity.requireID(),
            email: identity.emailAddress
        )
    }
}

extension JWT.Token.Refresh {
    package init(
        identity: Database.Identity
    ) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.identity.provider.cookies.refreshToken) var config
        @Dependency(\.date) var date

        let currentTime = date()
        
        self = .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            identityId: try identity.requireID(),
            tokenId: .init(uuid()),
            sessionVersion: identity.sessionVersion
        )
    }
}

extension IDClaim {
    public init(_ uuid: UUID){
        self = .init(value: uuid.uuidString)
    }
}

extension JWT.Token.Reauthorization {
    package init(
        identity: Database.Identity,
        currentTime: Date = .init(),
        includeTokenId: Bool = false,
        includeNotBefore: Bool = false
    ) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.identity.provider.cookies.reauthorizationtoken) var config

        self = .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expiration)),
            issuedAt: IssuedAtClaim(value: currentTime),
            subject: SubjectClaim(value: try identity.requireID().uuidString),
            issuer: IssuerClaim(value: config.issuer),
            audience: "reauthorization",
            tokenId: IDClaim(value: uuid().uuidString),
            notBefore: includeNotBefore ? NotBeforeClaim(value: currentTime) : nil,
            identityId: try identity.requireID(),
            email: identity.email,
            sessionVersion: identity.sessionVersion
        )
    }
}
