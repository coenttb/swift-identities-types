//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Foundation
import Vapor

extension Abort {
    /// Creates a rate limit error response with appropriate Retry-After header
    /// - Parameters:
    ///   - nextAllowedAttempt: Optional Date when the next attempt will be allowed
    ///   - defaultDelay: Default delay in seconds if no next attempt time is provided
    /// - Returns: An Abort error with 429 status and Retry-After header
    public static func rateLimit(
        nextAllowedAttempt: Date? = nil,
        defaultDelay: TimeInterval = 60
    ) -> Abort {
        let delay = nextAllowedAttempt.map {
            max(1, Int($0.timeIntervalSinceNow))
        } ?? Int(defaultDelay)

        return Abort(
            .tooManyRequests,
            headers: ["Retry-After": "\(delay)"]
        )
    }

    /// Creates a rate limit error response with Retry-After header using a time interval
    /// - Parameter delay: The time interval until the next allowed attempt
    /// - Returns: An Abort error with 429 status and Retry-After header
    public static func rateLimit(delay: TimeInterval) -> Abort {
        return Abort(
            .tooManyRequests,
            headers: ["Retry-After": "\(max(1, Int(delay)))"]
        )
    }
}
