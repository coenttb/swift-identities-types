//
//  Identity.Authenticate.Multifactor.Client.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import DependenciesMacros
import Foundation

// Client interface
extension Identity.Authentication.Multifactor {
    @DependencyClient
    public struct Client: @unchecked Sendable {
        public var setup: Client.Setup
        public var verification: Client.Verification
        public var recovery: Client.Recovery

        @DependencyEndpoint
        public var getConfiguration: () async throws -> Configuration

        @DependencyEndpoint
        public var disable: () async throws -> Void
    }
}

extension Identity.Authentication.Multifactor.Client {
    @DependencyClient
    public struct Setup: @unchecked Sendable {
        @DependencyEndpoint
        public var initialize: (_ method: Identity.Authentication.Multifactor.Method, _ identifier: String) async throws -> Identity.Authentication.Multifactor.Setup.Response

        @DependencyEndpoint
        public var confirm: (_ code: String) async throws -> Void
    }
}

extension Identity.Authentication.Multifactor.Client {
    @DependencyClient
    public struct Verification: @unchecked Sendable {
        @DependencyEndpoint
        public var createChallenge: (_ method: Identity.Authentication.Multifactor.Method) async throws -> Identity.Authentication.Multifactor.Challenge

        @DependencyEndpoint
        public var verify: (_ challengeId: String, _ code: String) async throws -> Void
    }
}

extension Identity.Authentication.Multifactor.Client {
    @DependencyClient
    public struct Recovery: @unchecked Sendable {
        @DependencyEndpoint
        public var generateNewCodes: () async throws -> [String]

        @DependencyEndpoint
        public var getRemainingCodeCount: () async throws -> Int
    }
}
