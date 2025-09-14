//
//  Identity.Reauthorization.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import TypesFoundation

extension Identity {
   /// Namespace for reauthorization functionality within the Identity system.
   ///
   /// Reauthorization is required for sensitive operations that need to verify
   /// the user's identity beyond their existing session.
    
    public struct Reauthorization: @unchecked Sendable {
        public var client: Identity.Reauthorization.Client
        public var router: any URLRouting.Router<Identity.Reauthorization.Route>
        
        public init(
            client: Identity.Reauthorization.Client,
            router: any URLRouting.Router<Identity.Reauthorization.Route> = Identity.Reauthorization.Route.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.Reauthorization {
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Sendable, Equatable {
        case api(Identity.Reauthorization.API)
    }
}

extension Identity.Reauthorization.Route {
    /// Routes email management requests to their appropriate handlers.
    ///
    /// Currently routes email change requests to the email change flow handler.
    /// Structure is extensible for future email management features.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Reauthorization.Route> {
            OneOf {
                URLRouting.Route(.case(Identity.Reauthorization.Route.api)) {
                    Identity.Reauthorization.API.Router()
                }
            }
        }
    }
}
