////
////  File.swift
////  swift-identity
////
////  Created by Coen ten Thije Boonkkamp on 31/01/2025.
////
//
//import Foundation
//import DependenciesMacros
//import Identity_Shared
//
//// MARK: - Provider Client
//extension Identity.Provider.Client {
//    @DependencyClient
//    public struct MultifactorAuthentication: @unchecked Sendable {
//        public var setup: Identity.Provider.Client.MultifactorAuthentication.Setup
//        public var verification: Identity.Provider.Client.MultifactorAuthentication.Verification
//        public var recovery: Identity.Provider.Client.MultifactorAuthentication.Recovery
//        public var administration: Identity.Provider.Client.MultifactorAuthentication.Administration
//        
//        @DependencyEndpoint
//        public var configuration: (_ userId: User.ID) async throws -> Identity_Shared.MultifactorAuthentication.Configuration
//        
//        @DependencyEndpoint
//        public var disable: (_ userId: User.ID) async throws -> Void
//    }
//}
//
//extension Identity.Provider.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Setup: @unchecked Sendable {
//        @DependencyEndpoint
//        public var initialize: (_ userId: User.ID, _ method: MultifactorAuthentication.Method, _ identifier: String) async throws -> MultifactorAuthentication.Setup.Response
//        
//        @DependencyEndpoint
//        public var confirm: (_ userId: User.ID, _ code: String) async throws -> Void
//        
//        @DependencyEndpoint
//        public var resetSecret: (_ userId: User.ID, _ method: MultifactorAuthentication.Method) async throws -> String
//    }
//}
//
//extension Identity.Provider.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Verification: @unchecked Sendable {
//        @DependencyEndpoint
//        public var createChallenge: (_ userId: User.ID, _ method: MultifactorAuthentication.Method) async throws -> MultifactorAuthentication.Challenge
//        
//        @DependencyEndpoint
//        public var verify: (_ userId: User.ID, _ challengeId: String, _ code: String) async throws -> Void
//        
//        @DependencyEndpoint
//        public var bypass: (_ userId: User.ID, _ challengeId: String) async throws -> Void
//    }
//}
//
//extension Identity.Provider.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Recovery: @unchecked Sendable {
//        @DependencyEndpoint
//        public var generateNewCodes: (_ userId: User.ID) async throws -> [String]
//        
//        @DependencyEndpoint
//        public var getRemainingCodeCount: (_ userId: User.ID) async throws -> Int
//        
//        @DependencyEndpoint
//        public var getUsedCodes: (_ userId: User.ID) async throws -> Set<String>
//    }
//}
//
//extension Identity.Provider.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Administration: @unchecked Sendable {
//        @DependencyEndpoint
//        public var forceDisable: (_ userId: User.ID) async throws -> Void
//        
//        @DependencyEndpoint
//        public var getAuditLog: (_ userId: User.ID, _ startDate: Date, _ endDate: Date) async throws -> [MultifactorAuthentication.Audit.Event]
//        
//        @DependencyEndpoint
//        public var bulkDisable: (_ userIds: [User.ID]) async throws -> [User.ID: Error?]
//        
//        @DependencyEndpoint
//        public var getStatus: (_ userIds: [User.ID]) async throws -> [User.ID: MultifactorAuthentication.Status]
//    }
//}
