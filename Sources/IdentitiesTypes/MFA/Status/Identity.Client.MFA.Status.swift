//
//  Identity.Client.MFA.Status.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client.MFA {
    /// General MFA status operations.
    @DependencyClient
    public struct Status: @unchecked Sendable {
        /// Get configured MFA methods.
        @DependencyEndpoint
        public var configured: () async throws -> Identity.MFA.ConfiguredMethods
        
        /// Check if MFA is required by policy.
        @DependencyEndpoint
        public var isRequired: () async throws -> Bool
        
        /// Get MFA challenge after authentication.
        @DependencyEndpoint
        public var challenge: () async throws -> Identity.MFA.Challenge
    }
}