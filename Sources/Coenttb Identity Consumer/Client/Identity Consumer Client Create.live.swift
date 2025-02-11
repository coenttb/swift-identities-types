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

extension Identity.Consumer.Client.Create {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        @Dependency(RateLimiters.self) var rateLimiter
        
        return .init(
            request: { email, password in
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                let rateLimit = await rateLimiter.createRequest.checkLimit(email.rawValue)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
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
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                let rateLimit = await rateLimiter.createVerify.checkLimit(token)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                do {
                    try await handleRequest(for: makeRequest(.create(.verify(.init(email: email, token: token)))))
                    await rateLimiter.createVerify.recordSuccess(token)
                } catch {
                    await rateLimiter.createVerify.recordFailure(token)
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
