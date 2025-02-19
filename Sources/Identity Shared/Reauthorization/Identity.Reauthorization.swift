//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import SwiftWeb

extension Identity {
    public struct Reauthorization: Codable, Hashable, Sendable {
        public let password: String

        public init(
            password: String = ""
        ) {
            self.password = password
        }

        public enum CodingKeys: String, CodingKey {
            case password
        }
    }
}

extension Identity.Reauthorization {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Reauthorization> {
            Method.post
            Path.reauthorization
            Body(.form(Identity.Password.Change.Reauthorization.self, decoder: .default))
        }
    }
}
