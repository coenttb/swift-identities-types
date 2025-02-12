//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Foundation
import Coenttb_Vapor
import Coenttb_Web
import Identity_Provider

extension Identity.Provider.API {
    public static func response(
        api: Identity.Provider.API,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Provider.Client.self) var client

        do {
            if let response = try Identity.API.protect(api: api, with: Database.Identity.self) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }
        
        switch api {
        case .authenticate(let authenticate):
            do {
                switch authenticate {
                case .credentials(let credentials):
                    let data = try await client.authenticate.credentials(credentials)
                    return Response.success(true, data: data)
                    
                case .token(let token):
                    switch token {
                    case .access(let access):
                        try await client.authenticate.token.access(access.token)
                        return Response.success(true)
                        
                    case .refresh(let refresh):
                        let data = try await client.authenticate.token.refresh(refresh.token)
                        return Response.success(true, data: data)
                    }
                case .apiKey(let apiKey):
                    let data = try await client.authenticate.apiKey(apiKey: apiKey.token)
                    return Response.success(true, data: data)
                    
                case .multifactor(let multifactor):
                    guard let mfa = client.authenticate.multifactor
                    else { throw Abort(.notImplemented, reason: "Multi-factor authentication is not supported") }
                    
                    switch multifactor {
                    case .setup(let setup):
                        switch setup {
                        case .initialize(let request):
                            do {
                                let data = try await mfa.setup.initialize(request.method, request.identifier)
                                return Response.success(true, data: data)
                            }
                            catch {
                                throw Abort(.internalServerError, reason: "Failed to initialize MFA setup")
                            }
                            
                        case .confirm(let confirm):
                            do {
                                try await mfa.setup.confirm(confirm.code)
                                return Response.success(true)
                            } catch {
                                throw Abort(.internalServerError, reason: "Failed to confirm MFA setup")
                            }
                        }
                        
                    case .challenge(let challenge):
                        switch challenge {
                        case .create(let request):
                            do {
                                let challenge = try await mfa.verification.createChallenge(request.method)
                                return Response.success(true, data: challenge)
                            } catch {
                                throw Abort(.internalServerError, reason: "Failed to create MFA challenge")
                            }
                        }
                        
                    case .verify(let verify):
                        switch verify {
                        case .verify(let verification):
                            do {
                                try await mfa.verification.verify(verification.challengeId, verification.code)
                                return Response.success(true)
                            } catch {
                                throw Abort(.internalServerError, reason: "Failed to verify MFA code")
                            }
                        }
                        
                    case .recovery(let recovery):
                        switch recovery {
                        case .generate:
                            do {
                                let codes = try await mfa.recovery.generateNewCodes()
                                return Response.success(true, data: codes)
                            } catch {
                                throw Abort(.internalServerError, reason: "Failed to generate recovery codes")
                            }
                            
                        case .count:
                            do {
                                let count = try await mfa.recovery.getRemainingCodeCount()
                                return Response.success(true, data: count)
                            } catch {
                                throw Abort(.internalServerError, reason: "Failed to get remaining recovery code count")
                            }
                        }
                        
                    case .configuration:
                        do {
                            let config = try await mfa.configuration()
                            return Response.success(true, data: config)
                        } catch {
                            throw Abort(.internalServerError, reason: "Failed to get MFA configuration")
                        }
                        
                    case .disable:
                        do {
                            try await mfa.disable()
                            return Response.success(true)
                        } catch {
                            throw Abort(.internalServerError, reason: "Failed to disable MFA")
                        }
                    }
                }
            } catch {
                @Dependencies.Dependency(\.logger) var logger
                logger.log(.critical, "Failed to authenticate account. Error: \(String(describing: error))")
                
                throw Abort(.internalServerError, reason: "Failed to authenticate account")
            }
            
        case .create(let create):
            
            switch create {
            case .request(let request):
                do {
                    try await client.create.request(email: .init(request.email), password: request.password)
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.critical, "Failed to create account. Error: \(String(describing: error))")
                    
                    throw Abort(.internalServerError, reason: "Failed to request account creation")
                }
            case .verify(let verify):
                do {
                    try await client.create.verify(email: .init(verify.email), token: verify.token)
                    return Response.success(true)
                } catch {
                    print(error)
                    throw Abort(.internalServerError, reason: "Failed to verify account creation")
                }
            }

        case .delete(let delete):
            switch delete {
            case .request(let request):
                if request.reauthToken.isEmpty {
                    throw Abort(.unauthorized, reason: "Invalid token")
                }
                
                do {
                    try await client.delete.request(reauthToken: request.reauthToken)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to delete")
                }
            case .cancel:
                do {
                    try await client.delete.cancel()
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to delete")
                }
            case .confirm:
                do {
                    try await client.delete.confirm()
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to confirm deletion")
                }
            }

        case .logout:
            try await client.logout()
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            
            return request.redirect(to: logoutRedirectURL().absoluteString)
            
        case let .password(password):
            switch password {
            case .reset(let reset):
                switch reset {
                case let .request(request):
                    do {
                        try await client.password.reset.request(email: .init(request.email))
                        return Response.success(true)
                    } catch {
                        @Dependencies.Dependency(\.logger) var logger
                        logger.log(.error, "Failed to request password reset. Error: \(String(describing: error))")
                        throw Abort(.internalServerError, reason: "Failed to request password reset")
                    }
                case let .confirm(confirm):
                    do {
                        try await client.password.reset.confirm(
                            newPassword: confirm.newPassword,
                            token: confirm.token
                        )
                        
                        return Response.success(true)
                    } catch {
                        @Dependencies.Dependency(\.logger) var logger
                        logger.log(.error, "Failed to reset password. Error: \(String(describing: error))")
                        throw Abort(.internalServerError, reason: "Failed to reset password")
                    }
                }
            case .change(let change):
                switch change {
                case let .request(change: request):
                    do {
                        try await client.password.change.request(
                            currentPassword: request.currentPassword,
                            newPassword: request.newPassword
                        )
                        return Response.success(true)
                    } catch {
                        @Dependencies.Dependency(\.logger) var logger
                        logger.log(.error, "Failed to change password. Error: \(String(describing: error))")
                        throw Abort(.internalServerError, reason: "Failed to change password")
                    }
                }
            }
        case let .emailChange(emailChange):
            switch emailChange {
            case .request(let request):
                do {
                    let data = try await client.emailChange.request(newEmail: .init(request.newEmail))
                    
                    return Response.success(true, data: data)
                    
                }
                catch let error as Identity.EmailChange.Request.Error {
                    throw error
                }
                catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to request email change. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to request email change")
                }
                
            case .confirm(let confirm):
                do {
                    try await client.emailChange.confirm(token: confirm.token)
                    
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.info, "Email change confirmed for new email")
                    
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to confirm email change. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to confirm email change")
                }
            }
        case .reauthorize(let reauthorize):
            let data = try await client.reauthorize(password: reauthorize.password)
            return Response.success(true, data: data)
        }
    }
}
