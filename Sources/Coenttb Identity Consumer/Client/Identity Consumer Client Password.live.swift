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
        
        return .init(
            reset: .init(
                request: { email in
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    let makeRequest = makeRequest(apiRouter)
                    
                    @Dependency(URLRequest.Handler.self) var handleRequest
                    
                    let rateLimit = await rateLimiter.passwordResetRequest.checkLimit(email.rawValue)
                    guard rateLimit.isAllowed else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
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
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    let makeRequest = makeRequest(apiRouter)
                    
                    @Dependency(URLRequest.Handler.self) var handleRequest
                    
                    let rateLimit = await rateLimiter.passwordResetConfirm.checkLimit(token)
                    guard rateLimit.isAllowed else {
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
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
                        throw Abort.rateLimit(nextAllowedAttempt: rateLimit.nextAllowedAttempt)
                    }
                    
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .cookie("access_token", request.cookies.accessToken)
                        .cookie("refresh_token", request.cookies.refreshToken)
                        .transform{ urlRequestData in
                            if let accessToken = request.cookies.accessToken?.string {
                                var data = urlRequestData
                                data.headers["Authorization"] = ["Bearer \(accessToken)"][...].map { Substring($0) }[...]
                                return data
                            }
                            return urlRequestData
                        }
                        .eraseToAnyParserPrinter()
                    
                    let makeRequest = makeRequest(apiRouter)
                    
                    @Dependency(URLRequest.Handler.self) var handleRequest
                    
//                    var urlRequest: URLRequest =
//                    urlRequest.setBearerToken(request.cookies.accessToken?.string)
//                    urlRequest.setRefreshTokenCookie(request.cookies.refreshToken?.string)
                    
                   
                    do {
                        try await handleRequest(for: makeRequest(.password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword))))))
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
