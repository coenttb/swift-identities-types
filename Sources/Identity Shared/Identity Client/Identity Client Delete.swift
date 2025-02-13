//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Foundation
import EmailAddress
import Dependencies
import DependenciesMacros

extension Identity.Client {
    @DependencyClient
    public struct Delete: @unchecked Sendable {
        public var request: (
//            _ userId: UUID,
            _ reauthToken: String
        ) async throws -> Void
        
        public var cancel: (/*_ userId: User.ID*/) async throws -> Void
        
        public var confirm: (/*_ userId: User.ID*/) async throws -> Void
    }
}

extension Identity.Client.Delete {
    public func request(_ request: Identity.Delete.Request) async throws {
        try await self.request(reauthToken: request.reauthToken)
    }
}
