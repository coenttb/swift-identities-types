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

extension Identity.Consumer.Client.Authenticate {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        @Dependency(RateLimiters.self) var rateLimiter
        
        return .init(
            credentials: { credentials in
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                do {
                    print("Starting authentication flow...")
                    let response = try await handleRequest(
                        for: makeRequest(.authenticate(.credentials(credentials))),
                        decodingTo: JWT.Response.self
                    )
                    print("Got JWT response from provider")
                    
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    
                    print("About to verify token:", response.accessToken.value)
                    let accessToken = try await request.jwt.verify(
                        response.accessToken.value,
                        as: JWT.Token.Access.self
                    )
                    print("Token verified successfully, logging in...")
                    
                    request.auth.login(accessToken)
                    print("Login successful")
                    
                    await rateLimiter.credentials.recordSuccess(credentials.email)
                    return response
                } catch {
                    print("Authentication failed with error:", error)
                    if let jwtError = error as? JWTError {
                        print("JWT specific error:", jwtError)
                    }
                    await rateLimiter.credentials.recordFailure(credentials.email)
                    throw Abort(.unauthorized)
                }
            },
            token: .init(
                access: { token in
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    let makeRequest = makeRequest(apiRouter)
                    
                    @Dependency(URLRequest.Handler.self) var handleRequest
                    
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
                        guard let refreshToken = request.cookies.refreshToken?.string else {
                            throw Abort(.unauthorized)
                        }
                        let newTokenResponse = try await client.authenticate.token.refresh(token: refreshToken)
                        
                        // Verify and login new token
                        let newAccessToken = try await request.jwt.verify(
                            newTokenResponse.accessToken.value,
                            as: JWT.Token.Access.self
                        )
                        request.auth.login(newAccessToken)
                        
                        request.headers.bearerAuthorization = .init(token: newTokenResponse.accessToken.value)
                        request.cookies.accessToken = .accessToken(response: newTokenResponse, domain: provider.domain)
                        request.cookies.refreshToken = .refreshToken(response: newTokenResponse, domain: provider.domain)
                        await rateLimiter.tokenAccess.recordSuccess(token)
                        return
                    }
                    
                    // Log in the current token if it's still valid
                    request.auth.login(currentToken)
                    await rateLimiter.tokenAccess.recordSuccess(token)
                },
                refresh: { token in
                    let apiRouter = router
                        .baseURL(provider.baseURL.absoluteString)
                        .eraseToAnyParserPrinter()
                    
                    let makeRequest = makeRequest(apiRouter)
                    
                    @Dependency(URLRequest.Handler.self) var handleRequest
                    
                    let rateLimit = await rateLimiter.tokenRefresh.checkLimit(token)
                    guard rateLimit.isAllowed else {
                        throw Abort(.tooManyRequests, headers: [
                            "Retry-After": "\(Int(rateLimit.nextAllowedAttempt?.timeIntervalSinceNow ?? 60))"
                        ])
                    }
                    
                    do {
                        let response = try await handleRequest(
                            for: makeRequest(.authenticate(.token(.refresh(.init(token: token))))),
                            decodingTo: JWT.Response.self
                        )
                        
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
                let apiRouter = router
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()
                
                let makeRequest = makeRequest(apiRouter)
                
                @Dependency(URLRequest.Handler.self) var handleRequest
                
                let rateLimit = await rateLimiter.apiKey.checkLimit(apiKey)
                guard rateLimit.isAllowed else {
                    if let nextAttempt = rateLimit.nextAllowedAttempt {
                        throw Abort.rateLimit(delay: nextAttempt.timeIntervalSinceNow)
                    }
                    throw Abort(.tooManyRequests)
                }
                
                do {
                    let response = try await handleRequest(
                        for: makeRequest(.authenticate(.apiKey(.init(token: apiKey)))),
                        decodingTo: JWT.Response.self
                    )
                    
                    await rateLimiter.apiKey.recordSuccess(apiKey)
                    
                    return response
                } catch {
                    await rateLimiter.apiKey.recordFailure(apiKey)
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}
