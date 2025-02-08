import Coenttb_Web
import Identity_Shared
import Dependencies
import EmailAddress
import Identity_Consumer
import Coenttb_Identity_Shared
import Vapor
import RateLimiter

extension Identity.Consumer.Client {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
//        @Dependency(Identity.Consumer.API.Router.self) var router
        
        let apiRouter = router.baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()
        
        let makeRequest = makeRequest(apiRouter)
        
        @Dependency(URLRequest.Handler.self) var handleRequest
        
        @Dependency(RateLimiters.self) var rateLimiter
        
        return .init(
            authenticate: .init(
                credentials: { credentials in
                    let rateLimit = await rateLimiter.credentials.checkLimit(credentials.email)
                    guard rateLimit.isAllowed else {
                        if let nextAttempt = rateLimit.nextAllowedAttempt {
                            throw Abort(.tooManyRequests,
                                        headers: ["Retry-After": "\(Int(nextAttempt.timeIntervalSinceNow))"])
                        }
                        throw Abort(.tooManyRequests)
                    }
                    do {
                        guard let response = try await handleRequest(
                            for: makeRequest(.authenticate(.credentials(credentials))),
                            decodingTo: JWT.Response.self
                        ) else {
                            throw Abort(.internalServerError, reason: "Invalid response format")
                        }
                        await rateLimiter.credentials.recordSuccess(credentials.email)
                        return response
                    } catch {
                        await rateLimiter.credentials.recordFailure(credentials.email)
                        throw Abort(.unauthorized)
                    }
                },
                token: .init(
                    access: { token in
                        let rateLimit = await rateLimiter.tokenAccess.checkLimit(token)
                        guard rateLimit.isAllowed else {
                            throw Abort(.tooManyRequests, headers: [
                                "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                            ])
                        }
                        
                        @Dependency(Identity.Consumer.Client.self) var client
                        @Dependency(\.request) var request
                        guard let request else { throw Abort.requestUnavailable }
                        
                        let currentToken = try await request.jwt.verify(token, as: JWT.Token.Access.self)
                        
                        if !(Date() < currentToken.expiration.value) {
                            await rateLimiter.tokenAccess.recordFailure(token)
                            guard let refreshToken = request.cookies["refresh_token"]?.string else {
                                throw Abort(.unauthorized)
                            }
                            let newTokenResponse = try await client.authenticate.token.refresh(token: refreshToken)
                            request.headers.bearerAuthorization = .init(token: newTokenResponse.accessToken.value)
                            request.cookies.accessToken = .accessToken(response: newTokenResponse, domain: provider.domain)
                            request.cookies.refreshToken = .refreshToken(response: newTokenResponse, domain: provider.domain)
                            await rateLimiter.tokenAccess.recordSuccess(token)
                            return
                        }
                        await rateLimiter.tokenAccess.recordSuccess(token)
                    },
                    refresh: { token in
                        
                        let rateLimit = await rateLimiter.tokenRefresh.checkLimit(token)
                        guard rateLimit.isAllowed else {
                            throw Abort(.tooManyRequests, headers: [
                                "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                            ])
                        }
                        
                        do {
                            guard let response = try await handleRequest(
                                for: makeRequest(.authenticate(.token(.refresh(.init(token: token))))),
                                decodingTo: JWT.Response.self
                            ) else {
                                await rateLimiter.tokenRefresh.recordFailure(token)
                                throw Abort(.unauthorized)
                            }
                            
                            @Dependency(\.request) var request
                            guard let request else { throw Abort.requestUnavailable }
                            
                            request.cookies.accessToken = .accessToken(response: response, domain: provider.domain)
                            
                            await rateLimiter.tokenRefresh.recordSuccess(token)
                            return response
                        } catch {
                            await rateLimiter.tokenRefresh.recordFailure(token)
                            throw Abort(.unauthorized)
                        }
                    }
                ),
                apiKey: { apiKey in
                    let rateLimit = await rateLimiter.apiKey.checkLimit(apiKey)
                    guard rateLimit.isAllowed else {
                        if let nextAttempt = rateLimit.nextAllowedAttempt {
                            throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(nextAttempt.timeIntervalSinceNow))"])
                        }
                        throw Abort(.tooManyRequests)
                    }
                    
                    do {
                        guard let response = try await handleRequest(
                            for: makeRequest(.authenticate(.apiKey(.init(token: apiKey)))),
                            decodingTo: JWT.Response.self
                        ) else {
                            throw Abort(.internalServerError, reason: "Invalid response format")
                        }
                        
                        await rateLimiter.apiKey.recordSuccess(apiKey)
                        return response
                    } catch {
                        await rateLimiter.apiKey.recordFailure(apiKey)
                        throw Abort(.unauthorized)
                    }
                }
            ),
            logout: {
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let rateLimitKey = request.realIP
                
                let rateLimit = await rateLimiter.logout.checkLimit(rateLimitKey)
                guard rateLimit.isAllowed else {
                    throw Abort(.tooManyRequests, headers: [
                        "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                    ])
                }
                
                do {
                    //
                    request.auth.logout(JWT.Token.Access.self)
                    try await handleRequest(for: makeRequest(.logout))
                    await rateLimiter.logout.recordSuccess(rateLimitKey)
                } catch {
                    await rateLimiter.logout.recordFailure(rateLimitKey)
                    throw Abort(.unauthorized)
                }
            },
            reauthorize: { password in
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let rateLimitKey = request.realIP
                
                let rateLimit = await rateLimiter.reauthorize.checkLimit(rateLimitKey)
                guard rateLimit.isAllowed else {
                    throw Abort(.tooManyRequests, headers: [
                        "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                    ])
                }
                
                do {
                    guard let response = try await handleRequest(
                        for: makeRequest(.reauthorize(.init(password: password))),
                        decodingTo: JWT.Response.self
                    ) else {
                        await rateLimiter.reauthorize.recordFailure(rateLimitKey)
                        throw Abort(.internalServerError)
                    }
                    await rateLimiter.reauthorize.recordSuccess(rateLimitKey)
                    return response
                } catch {
                    await rateLimiter.reauthorize.recordFailure(rateLimitKey)
                    throw Abort(.unauthorized)
                }
            },
            create: .init(
                request: { email, password in
                    let rateLimit = await rateLimiter.createRequest.checkLimit(email.rawValue)
                    guard rateLimit.isAllowed else {
                        throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                    }
                    
                    do {
                        try await handleRequest(for: makeRequest(.create(.request(.init(email: email, password: password)))))
                        await rateLimiter.createRequest.recordSuccess(email.rawValue)
                    } catch {
                        await rateLimiter.createRequest.recordFailure(email.rawValue)
                        throw Abort(.internalServerError)
                    }
                },
                verify: { email, token in
                    let rateLimit = await rateLimiter.createVerify.checkLimit(token)
                    guard rateLimit.isAllowed else {
                        throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                    }
                    
                    do {
                        try await handleRequest(for: makeRequest(.create(.verify(.init(email: email, token: token)))))
                        await rateLimiter.createVerify.recordSuccess(token)
                    } catch {
                        await rateLimiter.createVerify.recordFailure(token)
                        throw Abort(.internalServerError)
                    }
                }
            ),
            delete: .init(
               request: { reauthToken in
                   @Dependency(\.request) var request
                   guard let request else { throw Abort.requestUnavailable }
                   
                   let rateLimitKey = request.realIP
                   
                   let rateLimit = await rateLimiter.deleteRequest.checkLimit(rateLimitKey)
                   guard rateLimit.isAllowed else {
                       throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                   }
                   
                   do {
                       try await handleRequest(for: makeRequest(.delete(.request(.init(reauthToken: reauthToken)))))
                       await rateLimiter.deleteRequest.recordSuccess(rateLimitKey)
                   } catch {
                       await rateLimiter.deleteRequest.recordFailure(rateLimitKey)
                       throw Abort(.unauthorized)
                   }
               },
               cancel: {
                   @Dependency(\.request) var request
                   guard let request else { throw Abort.requestUnavailable }
                   
                   let rateLimitKey = request.realIP
                   
                   let rateLimit = await rateLimiter.deleteCancel.checkLimit(rateLimitKey)
                   guard rateLimit.isAllowed else {
                       throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                   }
                   
                   do {
                       try await handleRequest(for: makeRequest(.delete(.cancel)))
                       await rateLimiter.deleteCancel.recordSuccess(rateLimitKey)
                   } catch {
                       await rateLimiter.deleteCancel.recordFailure(rateLimitKey)
                       throw Abort(.unauthorized)
                   }
               },
               confirm: {
                   @Dependency(\.request) var request
                   guard let request else { throw Abort.requestUnavailable }
                   
                   let rateLimitKey = request.realIP
                   
                   let rateLimit = await rateLimiter.deleteConfirm.checkLimit(rateLimitKey)
                   guard rateLimit.isAllowed else {
                       throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                   }
                   
                   do {
                       try await handleRequest(for: makeRequest(.delete(.confirm)))
                       await rateLimiter.deleteConfirm.recordSuccess(rateLimitKey)
                   } catch {
                       await rateLimiter.deleteConfirm.recordFailure(rateLimitKey)
                       throw Abort(.unauthorized)
                   }
               }
            ),
            emailChange: .init(
                request: { newEmail in                    
                    guard let newEmail = newEmail?.rawValue else { return }
                    let rateLimit = await rateLimiter.emailChangeRequest.checkLimit(newEmail)
                    guard rateLimit.isAllowed else {
                        if let nextAttempt = rateLimit.nextAllowedAttempt {
                            throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(nextAttempt.timeIntervalSinceNow))"])
                        }
                        throw Abort(.tooManyRequests)
                    }
                    do {
                        try await handleRequest(
                            for: makeRequest(.emailChange(.request(.init(newEmail: newEmail))))
                        )
                        await rateLimiter.emailChangeRequest.recordSuccess(newEmail)
                    } catch {
                        await rateLimiter.emailChangeRequest.recordFailure(newEmail)
                        throw Abort(.unauthorized)
                    }
                },
                confirm: { token in
                    let rateLimit = await rateLimiter.emailChangeConfirm.checkLimit(token)
                    guard rateLimit.isAllowed else {
                        throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                    }
                    do {
                        try await handleRequest(
                            for: makeRequest(.emailChange(.confirm(.init(token: token))))
                        )
                        await rateLimiter.emailChangeConfirm.recordSuccess(token)
                    } catch {
                        await rateLimiter.emailChangeConfirm.recordFailure(token)
                        throw Abort(.internalServerError)
                    }
                }
            ),
            password: .init(
                reset: .init(
                    request: { email in
                        let rateLimit = await rateLimiter.passwordResetRequest.checkLimit(email.rawValue)
                        guard rateLimit.isAllowed else {
                            throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                        }
                        do {
                            try await handleRequest(
                                for: makeRequest(.password(.reset(.request(.init(email: email)))))
                            )
                            await rateLimiter.passwordResetRequest.recordSuccess(email.rawValue)
                        } catch {
                            await rateLimiter.passwordResetRequest.recordFailure(email.rawValue)
                            throw Abort(.unauthorized)
                        }
                    },
                    confirm: { token, newPassword in
                        let rateLimit = await rateLimiter.passwordResetConfirm.checkLimit(token)
                        guard rateLimit.isAllowed else {
                            throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                        }
                        do {
                            try await handleRequest(
                                for: makeRequest(.password(.reset(.confirm(.init(token: token, newPassword: newPassword)))))
                            )
                            await rateLimiter.passwordResetConfirm.recordSuccess(token)
                        } catch {
                            await rateLimiter.passwordResetConfirm.recordFailure(token)
                            throw Abort(.internalServerError)
                        }
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        @Dependency(\.request) var request
                        guard let request else { throw Abort.requestUnavailable }
                        
                        let rateLimitKey = request.realIP
                        
                        let rateLimit = await rateLimiter.passwordChangeRequest.checkLimit(rateLimitKey)
                        guard rateLimit.isAllowed else {
                            throw Abort(.tooManyRequests, headers: ["Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"])
                        }
                        do {
                            try await handleRequest(
                                for: makeRequest(.password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword)))))
                            )
                            await rateLimiter.passwordChangeRequest.recordSuccess(rateLimitKey)
                        } catch {
                            await rateLimiter.passwordChangeRequest.recordFailure(rateLimitKey)
                            throw Abort(.unauthorized)
                        }
                    }
                )
            )
        )
    }
}

extension Identity.Consumer.Client {
    public enum Live {
        public struct Provider {
            public let baseURL: URL
            public let domain: String
            
            public init(baseURL: URL, domain: String) {
                self.baseURL = baseURL
                self.domain = domain
            }
        }
    }
}

extension Identity.Consumer.Client.Live {
    public static var makeRequest: (AnyParserPrinter<URLRequestData, Identity.Consumer.API>)->(_ route: Identity.Consumer.API) throws -> URLRequest {
        {
            apiRouter in
            { route in
                do {
                    let data = try apiRouter.print(route)
                    guard let request = URLRequest(data: data)
                    else { throw Identity.Consumer.Client.Error.requestError }
                    return request
                } catch {
                    throw Identity.Consumer.Client.Error.printError
                }
            }
        }
    }
}


extension Identity.Consumer.Client {
    public enum Error: Swift.Error {
        case requestError
        case printError
    }
}

extension HTTPCookies {
    public var accessToken: HTTPCookies.Value? {
        get {
            self["access_token"]
        }
        set {
            self["access_token"] = newValue
        }
    }
    
    public var refreshToken: HTTPCookies.Value? {
        get {
            self["refresh_token"]
        }
        set {
            self["refresh_token"] = newValue
        }
    }
}
