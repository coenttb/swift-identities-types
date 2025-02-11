//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Coenttb_Web
import Identity_Shared
import Dependencies
import EmailAddress
import Identity_Consumer
import Coenttb_Identity_Shared
import Coenttb_Vapor
import RateLimiter
import JWT

extension Identity.Consumer.Client.EmailChange {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        @Dependency(RateLimiters.self) var rateLimiter
        @Dependency(URLRequest.Handler.self) var handleRequest
        
        return .init(
            request: { newEmail in
                @Dependency(\.request) var request
                
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .setAccessToken(request?.cookies.accessToken)
                    .setRefreshToken(request?.cookies.refreshToken)
                    .setBearerAuth(request?.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
                
                guard let newEmail = newEmail?.rawValue else { return }
                
                let rateLimit = await rateLimiter.emailChangeRequest.checkLimit(newEmail)
                
                guard rateLimit.isAllowed
                else {
                    if let nextAttempt = rateLimit.nextAllowedAttempt {
                        throw Abort.rateLimit(delay: nextAttempt.timeIntervalSinceNow)
                    }
                    throw Abort(.tooManyRequests)
                }
                
                do {
                    try await handleRequest( for: makeRequest(apiRouter)(.emailChange(.request(.init(newEmail: newEmail)))) )
                    
                    await rateLimiter.emailChangeRequest.recordSuccess(newEmail)
                } catch {
                    await rateLimiter.emailChangeRequest.recordFailure(newEmail)
                    
                    throw Abort(.unauthorized)
                }
            },
            confirm: { token in
                @Dependency(\.request) var request
                
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .setAccessToken(request?.cookies.accessToken)
                    .setRefreshToken(request?.cookies.refreshToken)
                    .setBearerAuth(request?.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
                
                
                
                let rateLimit = await rateLimiter.emailChangeConfirm.checkLimit(token)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                do {
                    try await handleRequest(for: makeRequest(apiRouter)(.emailChange(.confirm(.init(token: token)))))
                    await rateLimiter.emailChangeConfirm.recordSuccess(token)
                } catch {
                    await rateLimiter.emailChangeConfirm.recordFailure(token)
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
