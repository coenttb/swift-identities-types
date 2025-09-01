//
//  Identity.Client.Logout.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client {
    /// Interface for logout operations.
    ///
    /// This struct provides methods for different logout strategies:
    /// - `current`: Logs out only the current session
    /// - `all`: Logs out all sessions across all devices by incrementing sessionVersion
    @DependencyClient
    public struct Logout: @unchecked Sendable {
        /// Logs out the current session only
        @DependencyEndpoint
        public var current: () async throws -> Void
        
        /// Logs out all sessions for the user across all devices
        @DependencyEndpoint
        public var all: () async throws -> Void
    }
}
