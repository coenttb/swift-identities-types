//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Dependencies
@preconcurrency import Fluent
import Foundation
import JWT



extension Identity.Authentication.Response {
    /**
     * Creates an authentication response with access and refresh tokens
     * for the given identity
     */
    public init(_ identity: Database.Identity) async throws {
        
        var accessToken: JWT.Token {
            get async throws {
                @Dependency(\.identity.provider.cookies.accessToken) var config
                
                @Dependency(\.application) var application
                
                let payload: JWT.Token.Access = try .init(identity: identity)
                
                return try await .init(
                    value: application.jwt.keys.sign(payload),
                    type: "Bearer",
                    expiresIn: config.expires
                )
            }
        }
        
        var refreshToken: JWT.Token {
            get async throws {
                
                @Dependency(\.application) var application
                let payload = try JWT.Token.Refresh(identity: identity)
                
                @Dependency(\.identity.provider.cookies.refreshToken) var config
                
                return .init(
                    value: try await application.jwt.keys.sign(payload),
                    type: "Bearer",
                    expiresIn: config.expires
                )
            }
        }
        
        self = try await .init(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

extension JWT.Token.Access {
    /**
     * Creates an access token from a Database.Identity
     *
     * IMPORTANT: The subject claim will contain both the identity ID and email
     * in the format "UUID:email" to ensure both pieces of information are preserved.
     */
    package init(identity: Database.Identity) throws {
        @Dependency(\.identity.provider.cookies.accessToken) var config
        @Dependency(\.date) var date

        let currentTime = date()
        let expirationTime = currentTime.addingTimeInterval(config.expires)
        
        // Ensure we have the identity ID and email address
        let identityId = try identity.requireID()
        let emailAddress = identity.emailAddress
        
        print("Creating JWT.Token.Access: ID=\(identityId), email=\(emailAddress.rawValue)")
        
        self = .init(
            expiration: ExpirationClaim(value: expirationTime),
            issuedAt: IssuedAtClaim(value: currentTime),
            identityId: identityId,
            email: emailAddress
        )
        
        // Verify the subject was correctly formatted
        let components = self.subject.value.components(separatedBy: ":")
        guard components.count == 2, components[0] == identityId.uuidString, components[1] == emailAddress.rawValue else {
            print("ERROR: Subject not correctly formatted: \(self.subject.value)")
            throw Abort(.internalServerError, reason: "Invalid token subject format")
        }
    }
}

extension JWT.Token.Refresh {
    /**
     * Creates a refresh token from a Database.Identity
     */
    package init(identity: Database.Identity) throws {
        @Dependency(\.uuid) var uuid
        @Dependency(\.identity.provider.cookies.refreshToken) var config
        @Dependency(\.date) var date

        let currentTime = date()
        let expirationTime = currentTime.addingTimeInterval(config.expires)
        let identityId = try identity.requireID()
        
        self = .init(
            expiration: ExpirationClaim(value: expirationTime),
            issuedAt: IssuedAtClaim(value: currentTime),
            identityId: identityId,
            tokenId: .init(uuid()),
            sessionVersion: identity.sessionVersion
        )
    }
}

extension IDClaim {
    public init(_ uuid: UUID) {
        self = .init(value: uuid.uuidString)
    }
}

extension JWT.Token.Reauthorization {
    /**
     * Creates a reauthorization token from a Database.Identity
     *
     * IMPORTANT: This now uses the same "UUID:email" format for subject
     * to be consistent with access tokens.
     */
    package init(
        identity: Database.Identity,
        audience: AudienceClaim? = nil
    ) throws {
        @Dependency(\.date) var date
        @Dependency(\.uuid) var uuid
        @Dependency(\.identity.provider.cookies.reauthorizationToken) var config
        @Dependency(\.identity.provider.issuer) var issuer
        
        let currentTime = date()
        let identityId = try identity.requireID()
        
        // Ensure the email is valid
        let email = identity.email
        
        // Use the same subject format as access tokens (UUID:email)
        let subjectValue = "\(identityId.uuidString):\(email)"
        
        self = .init(
            expiration: ExpirationClaim(value: currentTime.addingTimeInterval(config.expires)),
            issuedAt: IssuedAtClaim(value: currentTime),
            subject: SubjectClaim(value: subjectValue),
            issuer: issuer.map { IssuerClaim(value: $0) },
            audience: audience,
            tokenId: IDClaim(value: uuid().uuidString),
            notBefore: NotBeforeClaim(value: currentTime),
            identityId: identityId,
            email: email,
            sessionVersion: identity.sessionVersion
        )
    }
}
