//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import Identity_Shared
import Identity_Provider

extension Identity.Provider {
    public struct Configuration: Codable, Hashable, Sendable {
        public let baseURL: URL
        public let domain: String?

        public init(baseURL: URL, domain: String?) {
            self.baseURL = baseURL
            self.domain = domain
        }
    }
}

extension Identity.Provider.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil
    )
}
