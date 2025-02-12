//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Web
import Coenttb_Vapor
import Favicon
import Identity_Consumer

extension Identity.Consumer.API {
         
    public static func response(
        api: Identity.Consumer.API,
        tokenDomain: String?
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Consumer.Client.self) var client
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        do {
            if let response = try Identity.Consumer.API.protect(
                api: api,
                with: JWT.Token.Access.self
            ) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }
        
        switch api {
        case .authenticate(let authenticate):
            do {
                switch authenticate {
                case .token(let token):
                    switch token {
                    case .access(let access):
                        try await client.authenticate.token.access(token: access.token)
                        return Response.success(true)
                        
                    case .refresh(let refresh):
                        let apiResponse = try await client.authenticate.token.refresh(token: refresh.token)
                        
                        let response = Response.success(true, data: apiResponse)
                        response.cookies.refreshToken = .refreshToken(response: apiResponse, domain: nil)
                        response.cookies.refreshToken?.sameSite = .strict
                        response.cookies.refreshToken?.isHTTPOnly = true
                        
                        return response
                    }
                    
                case .credentials(let credentials):
                    do {
                        let apiResponse = try await client.authenticate.credentials(credentials: credentials)
                        let response = Response.success(true, data: apiResponse)
                        response.cookies.accessToken = .accessToken(response: apiResponse, domain: tokenDomain)
                        response.cookies.refreshToken = .refreshToken(response: apiResponse, domain: tokenDomain)
                        return response
                    } catch {
                        print("Failed in credentials case with error:", error)
                        throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                    }
                    
                case .apiKey(let apiKey):
                    let apiResponse = try await client.authenticate.apiKey(apiKey: apiKey.token)
                    return Response.success(true, data: apiResponse)
                }
                
            } catch {
                throw Abort(.internalServerError, reason: "Failed to authenticate account")
            }
            
            
        case .create(let create):
            switch create {
            case .request(let request):
                do {
                    try await client.create.request(email: try .init(request.email), password: request.password)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to request account creation")
                }
                
            case .verify(let verify):
                do {
                    try await client.create.verify(email: try .init(verify.email), token: verify.token)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to verify account creation")
                }
            }
            
        case .delete(let delete):
            switch delete {
            case .request(let request):
                do {
                    try await client.delete.request(reauthToken: request.reauthToken)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to delete account")
                }
                
            case .cancel:
                do {
                    try await client.delete.cancel()
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to cancel account deletion")
                }
                
            case .confirm:
                do {
                    try await client.delete.confirm()
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to confirm account deletion")
                }
            }
            
        case .emailChange(let emailChange):
            switch emailChange {
            case .request(let request):
                do {
                    try await client.emailChange.request(newEmail: try .init(request.newEmail))
                    return Response.success(true)
                }
                catch let error as Identity.EmailChange.Request.Error {
                    throw error
                }
                catch {
                    throw Abort(.internalServerError, reason: "Failed to request email change")
                }
                
            case .confirm(let confirm):
                do {
                    try await client.emailChange.confirm(token: confirm.token)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to confirm email change")
                }
            }
            
        case .logout:
            do {
                try await client.logout()
                let response = Response.success(true)
                var accessToken = request.cookies.accessToken
                accessToken?.expires = .distantPast
                
                var refreshToken = request.cookies.refreshToken
                refreshToken?.expires = .distantPast
                 
                response.cookies.accessToken = accessToken
                response.cookies.refreshToken = refreshToken
                return response
            } catch {
                throw Abort(.internalServerError, reason: "Failed to logout")
            }
            
        case .password(let password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request(let request):
                    do {
                        try await client.password.reset.request(email: try .init(request.email))
                        return Response.success(true)
                    } catch {
                        throw Abort(.internalServerError, reason: "Failed to request password reset")
                    }
                    
                case .confirm(let confirm):
                    do {
                        try await client.password.reset.confirm(newPassword: confirm.newPassword, token: confirm.token)
                        return Response.success(true)
                    } catch {
                        throw Abort(.internalServerError, reason: "Failed to confirm password reset")
                    }
                }
            case .change(let change):
                switch change {
                case .request(let request):
                    do {
                        try await client.password.change.request(
                            currentPassword: request.currentPassword,
                            newPassword: request.newPassword
                        )
                        return Response.success(true)
                    } catch {
                        throw Abort(.internalServerError, reason: "Failed to request password change")
                    }
                }
            }
            
        case .reauthorize(let reauthorize):
            do {
                let apiResponse = try await client.reauthorize(password: reauthorize.password)
                return Response.success(true, data: apiResponse)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to reauthorize")
            }
        }
    }
}

