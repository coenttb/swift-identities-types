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
    public struct EmailChange: @unchecked Sendable {
        public var request: (_ newEmail: EmailAddress?) async throws -> Void
        public var confirm: (_ token: String) async throws -> Void
    }
}
