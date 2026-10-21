//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Case_Macro
import Coder
import Dependencies
import HTTP
import HTTP_Router
import JWT

extension Identity.Reauthorization {
    @Witness
    public struct Client: @unchecked Sendable {
        public var reauthorize: (_ password: String) async throws(Identity.Reauthorization.Client.Error) -> JWT
    }
}
