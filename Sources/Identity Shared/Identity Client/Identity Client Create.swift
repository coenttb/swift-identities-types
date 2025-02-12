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
    public struct Create: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (_ email: EmailAddress, _ password: String) async throws -> Void
        
        @DependencyEndpoint
        public var verify: (_ email: EmailAddress, _ token: String) async throws -> Void
    }
}
