//
//  Identity.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import URLRouting

extension Identity {
    /// Namespace for email-related functionality within the Identity system.
    public struct Email: @unchecked Sendable {
        public var change: Identity.Email.Change
        public var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Email.Route>

        public init(
            change: Identity.Email.Change,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Email.Route> = Identity
                .Email.Route.Router().eraseToAnyParserPrinter()
        ) {
            self.change = change
            self.router = router
        }
    }
}
