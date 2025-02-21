//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 21/02/2025.
//

import Coenttb_Vapor
import Coenttb_Web
import Identity_Consumer

extension Identity.Consumer.API {
    public static func response(
        route: Identity.Consumer.Route
    ) async throws -> any AsyncResponseEncodable {
        switch route {
        case .api(let api):
            return try await Identity.Consumer.API.response(api: api)
        case .view(let view):
            return try await Identity.Consumer.View.response(view: view)
        }
    }
}
