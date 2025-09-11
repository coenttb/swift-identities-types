//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Email {
    /// Namespace containing email change functionality.
    ///
    /// The email change flow consists of multiple steps:
    /// 1. Requesting an email change with the new email address
    /// 2. Potentially requiring reauthorization for security
    /// 3. Confirming the change with a verification token
    public struct Change: @unchecked Sendable {
        public var client: Identity.Email.Change.Client
        public var router: any URLRouting.Router<Identity.Email.Change.API>
        
        public init(
            client: Identity.Email.Change.Client,
            router: any URLRouting.Router<Identity.Email.Change.API> = Identity.Email.Change.API.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.Email.Change {
    public typealias Reauthorization = Identity.Reauthorization.Request
}
