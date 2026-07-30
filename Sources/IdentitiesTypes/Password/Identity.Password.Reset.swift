//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import URLRouting

extension Identity.Password {
    /// Namespace containing password reset functionality.
    ///
    /// The reset flow consists of two steps:
    /// 1. Requesting a password reset via email
    /// 2. Confirming the reset with a token and new password
    public struct Reset: @unchecked Sendable {
        public var client: Identity.Password.Reset.Client
        public var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Password.Reset.API>

        public init(
            client: Identity.Password.Reset.Client,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Password.Reset.API> =
                Identity.Password.Reset.API
                .Router().eraseToAnyParserPrinter()
        ) {
            self.client = client
            self.router = router
        }
    }
}
