//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import JWT
import URLRouting

extension Identity.Reauthorization {
    @Witness
    public struct Client: @unchecked Sendable {
        public var reauthorize: (_ password: String) async throws(any Swift.Error) -> JWT
    }
}
