////
////  File.swift
////  swift-identity
////
////  Created by Coen ten Thije Boonkkamp on 31/01/2025.
////
//
//import Foundation
//import DependenciesMacros
//import Coenttb_Web
//import Identity_Shared
//
//
//// MARK: - Consumer Client
//extension Identity.Consumer.Client {
//    @DependencyClient
//    public struct MultifactorAuthentication: @unchecked Sendable {
//        public var setup: Identity.Consumer.Client.MultifactorAuthentication.Setup
//        public var verification: Identity.Consumer.Client.MultifactorAuthentication.Verification
//        public var recovery: Identity.Consumer.Client.MultifactorAuthentication.Recovery
//        
//        @DependencyEndpoint
//        public var getConfiguration: (_ userId: User.ID) async throws -> Identity_Shared.MultifactorAuthentication.Configuration
//        
//        @DependencyEndpoint
//        public var disable: (_ userId: User.ID) async throws -> Void
//    }
//}
//
//extension Identity.Consumer.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Setup: @unchecked Sendable {
//        @DependencyEndpoint
//        public var initialize: (_ userId: User.ID, _ method: MultifactorAuthentication.Method, _ identifier: String) async throws -> Identity_Shared.MultifactorAuthentication.Setup.Response
//        
//        @DependencyEndpoint
//        public var confirm: (_ userId: User.ID, _ code: String) async throws -> Void
//    }
//}
//
//extension Identity.Consumer.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Verification: @unchecked Sendable {
//        @DependencyEndpoint
//        public var createChallenge: (_ userId: User.ID, _ method: MultifactorAuthentication.Method) async throws -> Identity_Shared.MultifactorAuthentication.Challenge
//        
//        @DependencyEndpoint
//        public var verify: (_ userId: User.ID, _ challengeId: String, _ code: String) async throws -> Void
//    }
//}
//
//extension Identity.Consumer.Client.MultifactorAuthentication {
//    @DependencyClient
//    public struct Recovery: @unchecked Sendable {
//        @DependencyEndpoint
//        public var generateNewCodes: (_ userId: User.ID) async throws -> [String]
//        
//        @DependencyEndpoint
//        public var getRemainingCodeCount: (_ userId: User.ID) async throws -> Int
//    }
//}
