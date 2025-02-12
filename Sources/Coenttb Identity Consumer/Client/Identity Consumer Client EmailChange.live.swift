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
                                
                guard let newEmail = newEmail?.rawValue
                else {
                    throw Abort(.conflict, reason: "Email address cannot be nil")
                }
                
                let rateLimit = await rateLimiter.emailChangeRequest.checkLimit(newEmail)
                
                guard rateLimit.isAllowed
                else {
                    guard let nextAttempt = rateLimit.nextAllowedAttempt
                    else { throw Abort(.tooManyRequests) }
                    
                    throw Abort.rateLimit(delay: nextAttempt.timeIntervalSinceNow)
                }
                
                @Dependency(\.request) var request
                
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .setAccessToken(request?.cookies.accessToken)
                    .setRefreshToken(request?.cookies.refreshToken)
                    .setReauthorizationToken(request?.cookies.reauthorizationToken)
                    .setBearerAuth(request?.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
                
                do {
                    let response = try await handleRequest(
                        for: makeRequest(apiRouter)(.emailChange(.request(.init(newEmail: newEmail)))),
                        decodingTo: Identity.Consumer.Client.EmailChange.Request.Result.self
                    )
                    await rateLimiter.emailChangeRequest.recordSuccess(newEmail)
                    return response
                }
                catch {
                    await rateLimiter.emailChangeRequest.recordFailure(newEmail)
                    
                    throw Abort(.unauthorized)
                }
                
            },
            confirm: { token in
                let rateLimit = await rateLimiter.emailChangeConfirm.checkLimit(token)
                guard rateLimit.isAllowed else {
                    throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                }
                
                @Dependency(\.request) var request
                
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .setAccessToken(request?.cookies.accessToken)
                    .setRefreshToken(request?.cookies.refreshToken)
                    .setBearerAuth(request?.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
                
                do {
                    try await handleRequest(for: makeRequest(apiRouter)(.emailChange(.confirm(.init(token: token)))))
                    
                    await rateLimiter.emailChangeConfirm.recordSuccess(token)
                }
                catch {
                    await rateLimiter.emailChangeConfirm.recordFailure(token)
                    
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
