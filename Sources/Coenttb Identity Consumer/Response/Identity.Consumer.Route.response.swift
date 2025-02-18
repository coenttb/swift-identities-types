//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identity_Consumer

extension Identity.Consumer.Route {
    public static func response(
       route: Identity.Consumer.Route
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(\.identity.consumer.client) var client

        switch route {
        case .api(let api):
            return try await Identity.Consumer.API.response(api: api)

        case .view(let view):
            return try await Identity.Consumer.View.response(view: view)
        }
    }
}
