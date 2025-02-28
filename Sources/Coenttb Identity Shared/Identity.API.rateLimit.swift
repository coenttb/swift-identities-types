//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension Identity.API {
    package static func rateLimit(
        api: Identity.API
    ) async throws -> RateLimiter<String>.Client {
        
        @Dependency(RateLimiters.self) var rateLimiter

        switch api {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials(let credentials):
                let rateLimit = await rateLimiter.credentials.checkLimit(credentials.username)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort(.tooManyRequests, headers: [
                        "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                    ])
                }
                
                return .init(limiter: rateLimiter.credentials, key: credentials.username)

            case .token(let token):
                switch token {
                case .access(let access):
                    let rateLimit = await rateLimiter.tokenAccess.checkLimit(access.token)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort(.tooManyRequests, headers: [
                            "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                        ])
                    }
                    
                    return .init(limiter: rateLimiter.tokenAccess, key: access.token)

                case .refresh(let refresh):
                    let rateLimit = await rateLimiter.tokenRefresh.checkLimit(refresh.value)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort(.tooManyRequests, headers: [
                            "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                        ])
                    }
                    
                    return .init(limiter: rateLimiter.tokenRefresh, key: refresh.value)
                }

            case .apiKey(let apiKey):
                let rateLimit = await rateLimiter.apiKey.checkLimit(apiKey.token)
                
                guard rateLimit.isAllowed
                else {
                    if let nextAttempt = rateLimit.nextAllowedAttempt {
                        throw Abort.rateLimit(delay: nextAttempt.timeIntervalSinceNow)
                    }
                    throw Abort(.tooManyRequests)
                }
                
                return .init(limiter: rateLimiter.apiKey, key: apiKey.token)
            }

        case .create(let create):
            switch create {
            case .request(let request):
                let rateLimit = await rateLimiter.createRequest.checkLimit(request.email)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.createRequest, key: request.email)

            case .verify(let verify):
                let rateLimit = await rateLimiter.createVerify.checkLimit(verify.token)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.createVerify, key: verify.token)
            }

        case .delete(let delete):
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            
            let key = request.realIP
            switch delete {
            case .request:
                let rateLimit = await rateLimiter.deleteRequest.checkLimit(key)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.deleteRequest, key: key)

            case .confirm:
                let rateLimit = await rateLimiter.deleteConfirm.checkLimit(key)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.deleteConfirm, key: key)

            case .cancel:
                let rateLimit = await rateLimiter.deleteCancel.checkLimit(key)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.deleteCancel, key: key)
            }

        case .email(let email):
            switch email {
            case .change(let change):
                switch change {
                case .request(let request):
                    let rateLimit = await rateLimiter.emailChangeRequest.checkLimit(request.newEmail)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    return .init(limiter: rateLimiter.emailChangeRequest, key: request.newEmail)

                case .confirm(let confirm):
                    let rateLimit = await rateLimiter.emailChangeConfirm.checkLimit(confirm.token)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    return .init(limiter: rateLimiter.emailChangeConfirm, key: confirm.token)
                }
            }

        case .logout:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            let key = request.realIP
            let rateLimit = await rateLimiter.logout.checkLimit(key)
            
            guard rateLimit.isAllowed
            else {
                throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
            }
            return .init(limiter: rateLimiter.logout, key: key)

        case .password(let password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request(let request):
                    let rateLimit = await rateLimiter.passwordResetRequest.checkLimit(request.email)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    return .init(limiter: rateLimiter.passwordResetRequest, key: request.email)

                case .confirm(let confirm):
                    let rateLimit = await rateLimiter.passwordResetConfirm.checkLimit(confirm.token)
                    
                    guard rateLimit.isAllowed
                    else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    return .init(limiter: rateLimiter.passwordResetConfirm, key: confirm.token)
                }

            case .change:
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                let key = request.realIP
                let rateLimit = await rateLimiter.passwordChangeRequest.checkLimit(key)
                
                guard rateLimit.isAllowed
                else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                return .init(limiter: rateLimiter.passwordChangeRequest, key: key)
            }

        case .reauthorize:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            let key = request.realIP
            let rateLimit = await rateLimiter.reauthorize.checkLimit(key)
            
            guard rateLimit.isAllowed
            else {
                throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
            }
            return .init(limiter: rateLimiter.reauthorize, key: key)
        }
    }
}
