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

extension Identity.Consumer.Client.Password {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        @Dependency(RateLimiters.self) var rateLimiter
        @Dependency(URLRequest.Handler.self) var handleRequest
        
        return .init(
            reset: .init(
                request: { email in
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    let rateLimit = await rateLimiter.passwordResetRequest.checkLimit(email.rawValue)
                    
                    guard rateLimit.isAllowed
                    else { throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt) }
                    
                    do {
                        try await handleRequest(for: makeRequest(apiRouter)(.password(.reset(.request(.init(email: email))))) )
                        await rateLimiter.passwordResetRequest.recordSuccess(email.rawValue)
                    } catch {
                        await rateLimiter.passwordResetRequest.recordFailure(email.rawValue)
                        throw Abort(.unauthorized)
                    }
                },
                confirm: { token, newPassword in
                    
                    let rateLimit = await rateLimiter.passwordResetConfirm.checkLimit(token)
                    
                    guard rateLimit.isAllowed
                    else { throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt) }
                    
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    do {
                        try await handleRequest(for: makeRequest(apiRouter)(.password(.reset(.confirm(.init(token: token, newPassword: newPassword))))))
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
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .setAccessToken(request.cookies.accessToken)
                        .setRefreshToken(request.cookies.refreshToken)
                        .setBearerAuth(request.cookies.accessToken?.string)
                        .eraseToAnyParserPrinter()
                  
                    do {
                        try await handleRequest(for: makeRequest(apiRouter)(.password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword))))))
                        await rateLimiter.passwordChangeRequest.recordSuccess(rateLimitKey)
                    } catch {
                        await rateLimiter.passwordChangeRequest.recordFailure(rateLimitKey)
                        throw Abort(.unauthorized)
                    }
                }
            )
        )
    }
}
