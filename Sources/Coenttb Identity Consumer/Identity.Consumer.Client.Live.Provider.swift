//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies

extension Identity.Consumer.Client {
    public struct Provider: Codable, Hashable, Sendable {
        public let baseURL: URL
        public let domain: String?

        public init(baseURL: URL, domain: String?) {
            self.baseURL = baseURL
            self.domain = domain
        }
    }
}

extension Identity.Consumer.Client.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil
    )
}
