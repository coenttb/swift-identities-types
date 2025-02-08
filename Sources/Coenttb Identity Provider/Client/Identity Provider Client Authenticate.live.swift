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

import Coenttb_Web
import Coenttb_Server
import Fluent
import Coenttb_Vapor
@preconcurrency import Mailgun
import Identity_Provider
import FluentKit
import JWT

extension Identity_Provider.Identity.Provider.Client.Authenticate {
    package static func live(
        database: Fluent.Database,
        logger: Logger,
        issuer: String
    ) -> Self  {
        .init(
            credentials: { credentials in
                
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let email: EmailAddress = try .init(credentials.email)
                
                guard let identity = try await Database.Identity.query(on: request.db)
                    .filter(\.$email == email.rawValue)
                    .first()
                else {
                    logger.warning("Login attempt failed: User not found for email: \(email)")
                    throw Abort(.unauthorized, reason: "Invalid credentials")
                }
                
                guard try identity.verifyPassword(credentials.password) else {
                    logger.warning("Login attempt failed: Invalid password for email: \(email)")
                    throw Abort(.unauthorized, reason: "Invalid credentials")
                }
                
                guard identity.emailVerificationStatus == .verified else {
                    logger.warning("Login attempt failed: Email not verified for: \(email)")
                    throw Abort(.unauthorized, reason: "Email not verified")
                }
                
                
                let response = try await identity.generateJWTResponse()
                
                // HOW TO CORRECT THIS ALSO?
                request.headers.bearerAuthorization = .init(token: response.accessToken.value)
                
                identity.lastLoginAt = Date()
                try await identity.save(on: request.db)
                
                request.auth.login(identity)
                
                logger.notice("Login successful for email: \(email)")
                
                return response
                
            },
            token: .init(
                access: { token in
                    @Dependency(\.logger) var logger
                    
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    
                    do {
                        let payload = try await request.jwt.verify(as: JWT.Token.Access.self)
                        
                        guard payload.audience.value.contains("access") else {
                            throw JWTError.claimVerificationFailure(
                                failedClaim: payload.audience,
                                reason: "Invalid audience for access token"
                            )
                        }
                        
                        guard payload.issuer.value == issuer else {
                            throw JWTError.claimVerificationFailure(
                                failedClaim: payload.issuer,
                                reason: "Invalid issuer"
                            )
                        }
                        
                        let identity = try await Database.Identity.get(by: .id(payload.identityId), on: request.db)
                        
                        guard identity.email == payload.email else {
                            throw Abort(.unauthorized, reason: "Identity details have changed")
                        }
                        
                        identity.lastLoginAt = Date()
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
                        let payload = try await request.jwt.verify(as: JWT.Token.Refresh.self)
                        
                        guard payload.audience.value.contains("refresh") else {
                            throw JWTError.claimVerificationFailure(
                                failedClaim: payload.audience,
                                reason: "Invalid audience for refresh token"
                            )
                        }
                        
                        guard payload.issuer.value == issuer else {
                            throw JWTError.claimVerificationFailure(
                                failedClaim: payload.issuer,
                                reason: "Invalid issuer"
                            )
                        }
                        
                        let identity = try await Database.Identity.get(by: .id(payload.identityId), on: request.db)
                                                   
                        guard identity.sessionVersion == payload.sessionVersion else {
                            throw Abort(.unauthorized, reason: "Token has been revoked")
                        }
                        
                        logger.notice("Refresh token verification successful for identity: \(identity.id?.uuidString ?? "unknown")")
                        
                        let response = try await identity.generateJWTResponse()
                        
                        request.auth.login(identity)
                        
                        return response
                        
                    } catch let error as JWTError {
                        logger.warning("Refresh token verification failed: \(error.localizedDescription)")
                        throw Abort(.unauthorized, reason: "Invalid refresh token")
                    } catch {
                        logger.error("Unexpected error during refresh token verification: \(error.localizedDescription)")
                        throw Abort(.internalServerError)
                    }
                }
            ),
            apiKey: { apiKey in
                @Dependency(\.request) var request
                @Dependency(\.logger) var logger
                guard let request else { throw Abort.requestUnavailable }
                
                do {
                    
                    guard let apiKey = try await Database.ApiKey.query(on: request.db)
                        .filter(\.$key == apiKey)
                        .with(\.$identity)
                        .first() else {
                            logger.warning("API key authentication failed: No identity found for API key \(apiKey)")
                            throw Abort(.unauthorized, reason: "Invalid API key")
                    }
                    
                    let identity = apiKey.identity
                    
                    let response = try await identity.generateJWTResponse()
                    
                    request.headers.bearerAuthorization = .init(token: response.accessToken.value)
                    
                    identity.lastLoginAt = Date()
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
