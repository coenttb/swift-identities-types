//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Coenttb_Server
import Coenttb_Vapor
import Coenttb_Web
import Fluent
@preconcurrency import FluentKit
import Identities
import JWT
@preconcurrency import Mailgun

extension Identity.Provider.Client.Authenticate {
    package static func live(
    ) -> Self {
        @Dependency(\.logger) var logger
        
        return .init(
            credentials: { username, password in
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }

                let email: EmailAddress = try .init(username)

                do {
                    let identity = try await Database.Identity.get(by: .email(email), on: request.db)

                    guard try identity.verifyPassword(password)
                    else {
                        logger.warning("Login attempt failed: Invalid password for email: \(email)")
                        throw Abort(.unauthorized, reason: "Invalid credentials")
                    }

                    guard identity.emailVerificationStatus == .verified
                    else {
                        logger.warning("Login attempt failed: Email not verified for: \(email)")
                        throw Abort(.unauthorized, reason: "Email not verified")
                    }

                    let response: Identity.Authentication.Response = try await .init(identity)
                    
                    @Dependency(\.date) var date
                    
                    identity.lastLoginAt = date()
                    try await identity.save(on: request.db)

                    request.auth.login(identity)

                    logger.notice("Login successful for email: \(email)")

                    return response

                } catch {
                    logger.warning("Login attempt failed: User not found for email: \(email)")
                    throw Abort(.unauthorized, reason: "Invalid credentials")
                }
            },
            token: .init(
                access: { token in
                    @Dependency(\.logger) var logger
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }

                    do {
                        let payload = try await request.jwt.verify(
                            token,
                            as: JWT.Token.Access.self
                        )

                        print("payload", payload)
                        
                        let identity = try await Database.Identity.get(by: .id(payload.identityId), on: request.db)
                        
                        guard identity.emailAddress == payload.emailAddress
                        else { throw Abort(.unauthorized, reason: "Identity details have changed") }
                        
                        @Dependency(\.date) var date

                        identity.lastLoginAt = date()
                        try await identity.save(on: request.db)

                        request.auth.login(identity)

                        logger.notice("Access token verification successful for identity: \(identity.id?.uuidString ?? "unknown")")

                    } catch let error as JWTError {
                        logger.warning("Access token verification failed: \(error.localizedDescription)")
                        throw Abort(.unauthorized, reason: "Invalid access token")
                    } catch {
                        logger.error("Unexpected error during access token verification: \(error.localizedDescription)")
                        throw Abort(.internalServerError)
                    }
                },
                refresh: { token in
                    @Dependency(\.logger) var logger

                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }

                    do {
                        let payload = try await request.jwt.verify(
                            token,
                            as: JWT.Token.Refresh.self
                        )

                        let identity = try await Database.Identity.get(by: .id(payload.identityId), on: request.db)

                        guard identity.sessionVersion == payload.sessionVersion
                        else { throw Abort(.unauthorized, reason: "Token has been revoked") }

                        logger.notice("Refresh token verification successful for identity: \(identity.id?.uuidString ?? "unknown")")

                        let response: Identity.Authentication.Response = try await .init(identity)

                        request.auth.login(identity)

                        return response

                    }
                    catch let error as JWTError {
                        logger.warning("Refresh token verification failed: \(error.localizedDescription)")
                        throw Abort(.unauthorized, reason: "Invalid refresh token")
                    }
                    catch {
                        logger.error("Unexpected error during refresh token verification: \(error.localizedDescription)")
                        throw Abort(.internalServerError)
                    }
                }
            ),
            apiKey: { apiKey in
                @Dependency(\.request) var request
                @Dependency(\.logger) var logger
                @Dependency(\.date) var date
                guard let request else { throw Abort.requestUnavailable }

                do {

                    guard let apiKey = try await Database.ApiKey.query(on: request.db)
                        .filter(\.$key == apiKey)
                        .with(\.$identity)
                        .first()
                    else {
                        logger.warning("API key authentication failed: No identity found for API key \(apiKey)")
                        throw Abort(.unauthorized, reason: "Invalid API key")
                    }

                    guard date() < apiKey.validUntil
                    else {
                        apiKey.isActive = false
                        try await apiKey.save(on: request.db)
                        throw Abort(.unauthorized)
                    }
                    
                    let identity = apiKey.identity

                    let response: Identity.Authentication.Response = try await .init(identity)

                    @Dependency(\.date) var date
                    
                    identity.lastLoginAt = date()
                    try await identity.save(on: request.db)

                    request.auth.login(identity)

                    logger.notice("API key authentication successful for identity: \(identity.id?.uuidString ?? "unknown")")

                    return response
                } catch {
                    logger.error("Unexpected error during api key verification: \(error.localizedDescription)")
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
