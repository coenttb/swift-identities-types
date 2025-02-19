//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import SwiftWeb

extension Identity {
    public enum Deletion {}
}

extension Identity.Deletion {
    public struct Request: Codable, Hashable, Sendable {
        public let reauthToken: String

        public init(
            reauthToken: String = ""
        ) {
            self.reauthToken = reauthToken
        }

        public enum CodingKeys: String, CodingKey {
            case reauthToken
        }
    }
}

extension Identity.Deletion.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Deletion.Request> {
            Method.post
            Body(.form(Identity.Deletion.Request.self, decoder: .default))
        }
    }
}
