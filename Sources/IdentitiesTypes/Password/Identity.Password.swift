//
//  Identity.Password.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import TypesFoundation

extension Identity {
    /// Namespace for password-related functionality within the Identity system.
    public struct Password: @unchecked Sendable {
        public var change: Identity.Password.Change
        public var reset: Identity.Password.Reset
        public var router: any URLRouting.Router<Identity.Password.Route>
        
        public init(
            change: Identity.Password.Change,
            reset: Identity.Password.Reset,
            router: any URLRouting.Router<Identity.Password.Route> = Identity.Password.Route.Router()
        ) {
            self.change = change
            self.reset = reset
            self.router = router
        }
    }
}
