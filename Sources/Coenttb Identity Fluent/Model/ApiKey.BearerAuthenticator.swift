//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 22/01/2025.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import RateLimiter

extension ApiKey {
    public struct BearerAuthenticator: AsyncBearerAuthenticator {
        public typealias User = Identity
        
        private let rateLimiter: RateLimiter<UUID>
        
        public init() {
            self.rateLimiter = RateLimiter(
                windows: [
                    .minutes(1, maxAttempts: 100),
                    .hours(1, maxAttempts: 1000)
                ],
                backoffMultiplier: 2.0,
                metricsCallback: { keyId, result in
                    if !result.isAllowed {
                        print("Rate limit exceeded for key \(keyId). Next attempt allowed at: \(String(describing: result.nextAllowedAttempt))")
                    }
                }
            )
        }
        
        public func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
            guard let apiKey = try await ApiKey.query(on: request.db)
                .filter(\.$key == bearer.token)
                .filter(\.$isActive == true)
                .with(\.$identity)
                .first()
            else { return }
            
            // Check expiration
            guard Date() < apiKey.validUntil else {
                apiKey.isActive = false
                try await apiKey.save(on: request.db)
                return
            }
            
            // Check rate limits
            guard let keyId = apiKey.id else { return }
            let rateLimit = await rateLimiter.checkLimit(keyId)
            
            guard rateLimit.isAllowed else {
                if let nextAllowed = rateLimit.nextAllowedAttempt {
                    request.headers.replaceOrAdd(
                        name: "X-RateLimit-Reset",
                        value: "\(Int(nextAllowed.timeIntervalSince1970))"
                    )
                }
                request.headers.replaceOrAdd(
                    name: "X-RateLimit-Remaining",
                    value: "\(rateLimit.remainingAttempts)"
                )
                request.headers.replaceOrAdd(
                    name: "Retry-After",
                    value: "\(Int((rateLimit.nextAllowedAttempt?.timeIntervalSince(Date()) ?? 60)))"
                )
                throw Abort(.tooManyRequests)
            }
            
            // Update last used timestamp
            apiKey.lastUsedAt = Date()
            try await apiKey.save(on: request.db)
            
            // Set rate limit headers
            request.headers.replaceOrAdd(
                name: "X-RateLimit-Limit",
                value: "\(apiKey.rateLimit)"
            )
            request.headers.replaceOrAdd(
                name: "X-RateLimit-Remaining",
                value: "\(rateLimit.remainingAttempts)"
            )
            
            // Authenticate the user
            request.auth.login(apiKey.identity)
            
            // Record successful request
            await rateLimiter.recordSuccess(keyId)
        }
    }
}
