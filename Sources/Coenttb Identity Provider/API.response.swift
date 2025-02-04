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

extension Identity_Shared.Identity.API {
    public static func response(
        api: Identity_Shared.Identity.API,
        client: Identity_Shared.Identity.Provider.Client,
//        userInit: () -> User?,
        reauthenticateForEmailChange: (_ password: String) async throws -> Void,
        reauthenticateForPasswordChange: (_ password: String) async throws -> Void,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {
        switch api {
        case .create(let create):
            switch create {
            case .request(let request):
                do {
                    try await client.create.request(email: .init(request.email), password: request.password)
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.critical, "Failed to create account. Error: \(String(describing: error))")
                    
                    throw Abort(.internalServerError, reason: "Failed to create account")
                }
            case .verify(let verify):
                do {
                    try await client.create.verify(token: verify.token, email: .init(verify.email))
                    return Response.success(true)
                } catch {
                    print(error)
                    return Response.success(false)
                }
            }
            
//        case .update(let user):
//            
//            guard let user = try await client.update(user) else {
//                throw Abort(.notFound, reason: "Account not found")
//            }
//            
//            return Response.success(true, data: user)
//            
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
            
        case .login(let login):
            do {
                try await client.login(email: .init(login.email), password: login.password)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to login")
            }
            
//        case .currentUser:
//            do {
//                return try await Response.json(success: true, data: client.currentUser())
//            } catch {
//                throw Abort(.internalServerError, reason: "No current user")
//            }
            
        case .logout:
            try await client.logout()
            @Dependency(\.request) var request
            
            guard let request else { throw Abort(.internalServerError) }
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
                case let .reauthorization(reauthorization):
                    do {
                        try await reauthenticateForPasswordChange(reauthorization.password)
                        return Response.success(true)
                    } catch {
                        @Dependencies.Dependency(\.logger) var logger
                        logger.log(.error, "Failed to reauthorize for password change. Error: \(String(describing: error))")
                        throw Abort(.unauthorized, reason: "Failed to reauthorize")
                    }
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
            case .reauthorization(let reauthorization):
                do {
                    try await reauthenticateForEmailChange(reauthorization.password)
                    
                    return Response.success(true)
                } catch {
                    return Response.success(false)
                }
            case .request(let request):
                do {
                    let _ = try await client.emailChange.request(
                        newEmail: .init(request.newEmail)
                    )
                    
                    return Response.success(true)
                    
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to request email change. Error: \(String(describing: error))")
                    throw error
                }
                
            case .confirm(let confirm):
                do {
                    let newEmail = try await client.emailChange.confirm(token: confirm.token)
                    
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.info, "Email change confirmed for new email: \(newEmail)")
                    
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to confirm email change. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to confirm email change")
                }
            }
//        case .multifactorAuthentication(let multifactorAuthentication):
//            guard let mfa = client.multifactorAuthentication else {
//                throw Abort(.notImplemented, reason: "Multi-factor authentication is not supported")
//            }
//            
//            switch multifactorAuthentication {
//            case .setup(let userId, let setup):
//                switch setup {
//                case .initialize(let request):
//                    do {
//                        let response = try await mfa.setup.initialize(userId, request.method, request.identifier)
//                        return Response.success(true, data: response)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to initialize MFA setup")
//                    }
//                    
//                case .confirm(let confirm):
//                    do {
//                        try await mfa.setup.confirm(userId, confirm.code)
//                        return Response.success(true)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to confirm MFA setup")
//                    }
//                }
//                
//            case .challenge(let userId, let challenge):
//                switch challenge {
//                case .create(let request):
//                    do {
//                        let challenge = try await mfa.verification.createChallenge(userId, request.method)
//                        return Response.success(true, data: challenge)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to create MFA challenge")
//                    }
//                }
//                
//            case .verify(let userId, let verify):
//                switch verify {
//                case .verify(let verification):
//                    do {
//                        try await mfa.verification.verify(userId, verification.challengeId, verification.code)
//                        return Response.success(true)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to verify MFA code")
//                    }
//                }
//                
//            case .recovery(let userId, let recovery):
//                switch recovery {
//                case .generate:
//                    do {
//                        let codes = try await mfa.recovery.generateNewCodes(userId: userId)
//                        return Response.success(true, data: codes)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to generate recovery codes")
//                    }
//                    
//                case .count:
//                    do {
//                        let count = try await mfa.recovery.getRemainingCodeCount(userId: userId)
//                        return Response.success(true, data: count)
//                    } catch {
//                        throw Abort(.internalServerError, reason: "Failed to get remaining recovery code count")
//                    }
//                }
//                
//            case .configuration(let userId):
//                do {
//                    let config = try await mfa.configuration(userId: userId)
//                    return Response.success(true, data: config)
//                } catch {
//                    throw Abort(.internalServerError, reason: "Failed to get MFA configuration")
//                }
//                
//            case .disable(let userId):
//                do {
//                    try await mfa.disable(userId: userId)
//                    return Response.success(true)
//                } catch {
//                    throw Abort(.internalServerError, reason: "Failed to disable MFA")
//                }
//            }
        }
    }
}
