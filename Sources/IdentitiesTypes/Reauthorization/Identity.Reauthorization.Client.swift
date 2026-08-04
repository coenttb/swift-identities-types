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
        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        public var reauthorize: (_ password: String) async throws(any Swift.Error) -> JWT
        // swiftlint:enable no_any_protocol_existential
    }
}
