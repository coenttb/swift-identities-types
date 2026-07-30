//
//  Identity.Reauthorization.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Dual
import URLRouting

extension Identity {
    /// Namespace for reauthorization functionality within the Identity system.
    ///
    /// Reauthorization is required for sensitive operations that need to verify
    /// the user's identity beyond their existing session.

    public struct Reauthorization: @unchecked Sendable {
        public var client: Identity.Reauthorization.Client
        public var router:
            AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Reauthorization.Route>

        public init(
            client: Identity.Reauthorization.Client,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Reauthorization.Route> =
                Identity.Reauthorization
                .Route
                .Router().eraseToAnyParserPrinter()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.Reauthorization {
    @Cases
    public enum Route: Sendable, Equatable {
        case api(Identity.Reauthorization.API)
    }
}

extension Identity.Reauthorization.Route {
    /// Routes reauthorization requests to their appropriate handlers.
    ///
    /// Handles reauthorization endpoint for sensitive operations.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Reauthorization.Route> {
            OneOf {
                URLRouting.Route(.case(Identity.Reauthorization.Route.cases.api)) {
                    Path.api
                    Path.reauthorize
                    Identity.Reauthorization.API.Router()
                }
            }
        }
    }
}
