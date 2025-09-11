//
//  Identity.Deletion.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import TypesFoundation

extension Identity {
    /// Namespace for identity deletion functionality within the Identity system.
    ///
    /// The deletion flow is designed with security in mind, requiring:
    /// 1. Explicit reauthorization to prevent unauthorized identity deletion
    /// 2. A confirmation step to prevent accidental deletion
    /// 3. The ability to cancel a pending deletion
    public struct Deletion: @unchecked Sendable {
        public var client: Identity.Deletion.Client
        public var router: any URLRouting.Router<Identity.Deletion.Route>
        
        public init(
            client: Identity.Deletion.Client,
            router: any URLRouting.Router<Identity.Deletion.Route> = Identity.Deletion.Route.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.Deletion {
    /// A request to initiate identity deletion.
    ///
    /// This type represents the initial step in the identity deletion flow.
    /// For security reasons, it requires recent authentication via a reauthorization token,
    /// helping prevent unauthorized identity deletions from compromised sessions.
    ///
    /// Example usage:
    /// ```swift
    /// let request = Identity.Deletion.Request(reauthToken: token)
    /// try await client.delete.request(request)
    /// ```
    ///
    /// > Important: Identity deletion is irreversible once confirmed. The flow includes
    /// > a confirmation step and cancellation option to prevent accidental deletions.
    public struct Request: Codable, Hashable, Sendable {
        /// Token from recent reauthorization, required for security.
        ///
        /// This token proves the user has recently authenticated, providing
        /// an additional security layer for the destructive deletion operation.
        public let reauthToken: String
        
        /// Creates a new identity deletion request.
        ///
        /// - Parameter reauthToken: A valid reauthorization token from recent authentication.
        public init(
            reauthToken: String = ""
        ) {
            self.reauthToken = reauthToken
        }
        
        /// Keys for coding and decoding Request instances.
        public enum CodingKeys: String, CodingKey {
            case reauthToken
        }
    }
}

extension Identity.Deletion.Request {
    /// Router for handling identity deletion request endpoints.
    ///
    /// Routes POST requests with form-encoded body containing the reauthorization token.
    /// The router does not specify a path component as it's configured at a higher level
    /// in the routing hierarchy.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Deletion.Request> {
            Method.post
            Body(.form(Identity.Deletion.Request.self, decoder: .identities))
        }
    }
}
