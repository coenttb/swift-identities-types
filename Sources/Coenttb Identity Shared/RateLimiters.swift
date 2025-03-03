//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Server
import Vapor

extension RateLimiter {
    package struct Client {
        package let recordSuccess: () async -> Void
        package let recordFailure: () async -> Void

        init(limiter: RateLimiter<Key>, key: Key) {
            self.recordSuccess = { await limiter.recordSuccess(key) }
            self.recordFailure = { await limiter.recordFailure(key) }
        }
        
        // For handling multiple rate limit keys 
        init(successAction: @escaping () async -> Void, failureAction: @escaping () async -> Void) {
            self.recordSuccess = successAction
            self.recordFailure = failureAction
        }
    }
}

extension Vapor.HTTPHeaders {
    public var retryAfter: [String] {
        self["Retry-After"]
    }
}

extension RateLimiter.Client {
    static var empty: Self {
        return .init(
            successAction: { },
            failureAction: { }
        )
    }
    
    static func + (
        lhs: Self,
        rhs: Self
    ) -> Self {
        return .init(
            successAction: {
                await lhs.recordSuccess()
                await rhs.recordSuccess()
            },
            failureAction: {
                await lhs.recordFailure()
                await rhs.recordFailure()
            }
        )
    }
}

public struct RateLimiters: Sendable {
    public var credentials: RateLimiter<String>

    public var tokenAccess: RateLimiter<String>

    public var tokenRefresh: RateLimiter<String>
    
    public init(
        credentials: RateLimiter<String> = RateLimiter<String>(
            windows: [
                .minutes(1, maxAttempts: 5),
                .hours(1, maxAttempts: 20)
            ],
            metricsCallback: { key, result async in
                @Dependency(\.logger) var logger
                if !result.isAllowed {
                    logger.warning("Rate limit exceeded for \(key)")
                }
            }
        ),
        tokenAccess: RateLimiter<String> = RateLimiter<String>(
            windows: [
                .minutes(1, maxAttempts: 60),
                .hours(1, maxAttempts: 3000)
            ],
            metricsCallback: { key, result async in
                @Dependency(\.logger) var logger
                if !result.isAllowed {
                    logger.warning("Token access rate limit exceeded for \(key)")
                }
            }
        ),
        tokenRefresh: RateLimiter<String> = RateLimiter<String>(
            windows: [
                .minutes(1, maxAttempts: 10),
                .hours(1, maxAttempts: 100)
            ],
            metricsCallback: { key, result async in
                @Dependency(\.logger) var logger
                if !result.isAllowed {
                    logger.warning("Token refresh rate limit exceeded for \(key)")
                }
            }
        )
    ) {
        self.credentials = credentials
        self.tokenAccess = tokenAccess
        self.tokenRefresh = tokenRefresh
    }
}

extension RateLimiters {
    public var apiKey: RateLimiter<String> { tokenAccess }
    public var logout: RateLimiter<String> { tokenAccess }
    public var reauthorize: RateLimiter<String> { credentials }
    public var createRequest: RateLimiter<String> { credentials }
    public var createVerify: RateLimiter<String> { credentials }
    public var deleteRequest: RateLimiter<String> { tokenAccess }
    public var deleteConfirm: RateLimiter<String> { tokenAccess }
    public var deleteCancel: RateLimiter<String> { tokenAccess }
    public var emailChangeRequest: RateLimiter<String> { credentials }
    public var emailChangeConfirm: RateLimiter<String> { credentials }
    public var passwordResetRequest: RateLimiter<String> { tokenAccess }
    public var passwordResetConfirm: RateLimiter<String> { tokenAccess }
    public var passwordChangeRequest: RateLimiter<String> { credentials }
}
