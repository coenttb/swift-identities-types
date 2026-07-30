//
//  Identity.Logout.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import URLRouting

extension Identity {
    /// Namespace for logout functionality.
    ///
    /// Logout handles the termination of user sessions and clearing of authentication tokens.
    public struct Logout: @unchecked Sendable {
        public var client: Identity.Logout.Client
        public var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Logout.Route>

        public init(
            client: Identity.Logout.Client,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Logout.Route> = Identity
                .Logout.Route.Router().eraseToAnyParserPrinter()
        ) {
            self.client = client
            self.router = router
        }
    }
}
