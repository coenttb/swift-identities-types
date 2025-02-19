//
//  File.swift
//  swift-web
//
//  Deleted by Coen ten Thije Boonkkamp on 17/10/2024.
//

import SwiftWeb

extension Identity.API {
    /// Identity deletion endpoints with a multi-step confirmation process for safety.
    ///
    /// The deletion flow consists of three possible actions:
    /// 1. Initiating deletion (requires re-authentication)
    /// 2. Confirming the deletion
    /// 3. Canceling a pending deletion
    ///
    /// This multi-step process helps prevent accidental identity deletions. Example flow:
    /// ```swift
    /// // 1. Start deletion (requires recent authentication)
    /// let delete = Identity.API.Delete.request(
    ///   .init(reauthToken: "recent-auth-token")
    /// )
    ///
    /// // 2. Identity can either confirm:
    /// let confirm = Identity.API.Delete.confirm
    ///
    /// // Or cancel:
    /// let cancel = Identity.API.Delete.cancel
    /// ```
    ///
    /// > Important: Identity deletion is permanent and cannot be undone after confirmation.
    /// > Identities have a grace period between request and confirmation during which they can cancel.
    public enum Delete: Codable, Hashable, Sendable {
        /// Initiates identity deletion, requiring recent authentication
        case request(Identity.Deletion.Request)
        
        /// Cancels a pending identity deletion request
        case cancel
        
        /// Confirms and executes the identity deletion
        case confirm
    }
}

extension Identity.API.Delete {
    /// Routes identity deletion requests to their appropriate handlers.
    ///
    /// Defines the URL structure for the deletion flow:
    /// - Initial request: `POST /delete/request`
    /// - Cancellation: `POST /delete/cancel`
    /// - Confirmation: `POST /delete/confirm`
    ///
    /// The request endpoint expects re-authentication data, while cancel and confirm
    /// endpoints operate on the authenticated user's pending deletion request.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        /// The routing logic for identity deletion endpoints.
        ///
        /// Composes routes for all three deletion actions:
        /// - Requesting deletion (with re-authentication)
        /// - Canceling a pending deletion
        /// - Confirming and executing deletion
        ///
        /// Each route enforces appropriate authentication and validation rules
        /// to ensure secure identity deletion.
        public var body: some URLRouting.Router<Identity.API.Delete> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Delete.request)) {
                    Path.request
                    Identity.Deletion.Request.Router()
                }
                
                URLRouting.Route(.case(Identity.API.Delete.cancel)) {
                    Path.cancel
                }
                
                URLRouting.Route(.case(Identity.API.Delete.confirm)) {
                    Path.confirm
                }
            }
        }
    }
}
