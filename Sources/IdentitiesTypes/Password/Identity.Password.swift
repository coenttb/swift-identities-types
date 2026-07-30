//
//  Identity.Password.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import URLRouting

extension Identity {
    /// Namespace for password-related functionality within the Identity system.
    public struct Password: @unchecked Sendable {
        public var change: Identity.Password.Change
        public var reset: Identity.Password.Reset
        public var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Password.Route>

        public init(
            change: Identity.Password.Change,
            reset: Identity.Password.Reset,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Password.Route> = Identity
                .Password.Route
                .Router().eraseToAnyParserPrinter()
        ) {
            self.change = change
            self.reset = reset
            self.router = router
        }
    }
}
