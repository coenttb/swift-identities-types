//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor
import Favicon
import Identity_Consumer

extension Identity.Consumer.Route {
    package static func protect<Authenticatable: Vapor.Authenticatable>(
        route: Identity.Consumer.Route,
        with type: Authenticatable.Type,
        createProtectedRedirect: URL,
        loginProtectedRedirect: URL
    ) throws -> (any AsyncResponseEncodable)? {
        switch route {
        case .api(let api):
            do {
                return try Identity.API.protect(api: api, with: JWT.Token.Access.self)
            } catch {
                throw Abort(.unauthorized)
            }
        case .view(let view):
            do {
                return try Identity.Consumer.View.protect(
                    view: view,
                    with: JWT.Token.Access.self,
                    createProtectedRedirect: createProtectedRedirect,
                    loginProtectedRedirect: loginProtectedRedirect
                )
            } catch {
                throw Abort(.unauthorized)
            }
        }
    }
}
