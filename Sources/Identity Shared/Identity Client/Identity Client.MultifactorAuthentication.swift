//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation
import DependenciesMacros

// MARK: - Provider Client
extension Identity.Client.Authenticate {
    @DependencyClient
    public struct Multifactor: @unchecked Sendable {
        public var setup: Identity.Client.Authenticate.Multifactor.Setup
        public var verification: Identity.Client.Authenticate.Multifactor.Verification
        public var recovery: Identity.Client.Authenticate.Multifactor.Recovery
        public var administration: Identity.Client.Authenticate.Multifactor.Administration
        
        @DependencyEndpoint
        public var configuration: () async throws -> Identity.Authenticate.Multifactor.Configuration
        
        @DependencyEndpoint
        public var disable: () async throws -> Void
    }
}

extension Identity.Client.Authenticate.Multifactor {
    @DependencyClient
    public struct Setup: @unchecked Sendable {
        @DependencyEndpoint
        public var initialize: (_ method: Identity.Authenticate.Multifactor.Method, _ identifier: String) async throws -> Identity.Authenticate.Multifactor.Setup.Response
        
        @DependencyEndpoint
        public var confirm: (_ code: String) async throws -> Void
        
        @DependencyEndpoint
        public var resetSecret: (_ method: Identity.Authenticate.Multifactor.Method) async throws -> String
    }
}

extension Identity.Client.Authenticate.Multifactor {
    @DependencyClient
    public struct Verification: @unchecked Sendable {
        @DependencyEndpoint
        public var createChallenge: (_ method: Identity.Authenticate.Multifactor.Method) async throws -> Identity.Authenticate.Multifactor.Challenge
        
        @DependencyEndpoint
        public var verify: (_ challengeId: String, _ code: String) async throws -> Void
        
        @DependencyEndpoint
        public var bypass: (_ challengeId: String) async throws -> Void
    }
}

extension Identity.Client.Authenticate.Multifactor {
    @DependencyClient
    public struct Recovery: @unchecked Sendable {
        @DependencyEndpoint
        public var generateNewCodes: () async throws -> [String]
        
        @DependencyEndpoint
        public var getRemainingCodeCount: () async throws -> Int
        
        @DependencyEndpoint
        public var getUsedCodes: () async throws -> Set<String>
    }
}

extension Identity.Client.Authenticate.Multifactor {
    @DependencyClient
    public struct Administration: @unchecked Sendable {
        @DependencyEndpoint
        public var forceDisable: () async throws -> Void
        
//        @DependencyEndpoint
//        public var getAuditLog: (_ startDate: Date, _ endDate: Date) async throws -> [Multifactor.Audit.Event]
        
//        @DependencyEndpoint
//        public var bulkDisable: (_ userIds: [User.ID]) async throws -> [User.ID: Error?]
        
//        @DependencyEndpoint
//        public var getStatus: (_ userIds: [User.ID]) async throws -> [User.ID: Multifactor.Status]
    }
}
