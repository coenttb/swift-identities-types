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
        public var request: (_ newEmail: EmailAddress?) async throws -> Identity.Client.EmailChange.Request.Result
        public var confirm: (_ token: String) async throws -> Void
    }
}

extension Identity.Client.EmailChange {
    public enum Request { }
}

extension Identity.Client.EmailChange.Request {
    public enum Result: Codable, Hashable, Sendable {
        case success
//        case allowed
        case requiresReauthentication
    }
}
