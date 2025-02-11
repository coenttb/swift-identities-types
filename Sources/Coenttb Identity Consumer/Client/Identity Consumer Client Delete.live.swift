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

extension Identity.Consumer.Client.Delete {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        @Dependency(RateLimiters.self) var rateLimiter
        
        return .init(
            request: { reauthToken in
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let rateLimitKey = request.realIP
                
                let rateLimit = await rateLimiter.deleteRequest.checkLimit(rateLimitKey)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
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
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let rateLimitKey = request.realIP
                
                let rateLimit = await rateLimiter.deleteCancel.checkLimit(rateLimitKey)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
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
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let rateLimitKey = request.realIP
                
                let rateLimit = await rateLimiter.deleteConfirm.checkLimit(rateLimitKey)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                do {
                    try await handleRequest(for: makeRequest(.delete(.confirm)))
                    await rateLimiter.deleteConfirm.recordSuccess(rateLimitKey)
                } catch {
                    await rateLimiter.deleteConfirm.recordFailure(rateLimitKey)
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}
