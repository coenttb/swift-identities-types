//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Foundation
import Identity_Provider

extension Identity.Provider.API.Authenticate {
    package static func response(
        authenticate: Identity.Provider.API.Authenticate,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Provider.Client.self) var client

        switch authenticate {
        case .credentials(let credentials):
            let data = try await client.authenticate.credentials(credentials)
            return Response.success(true, data: data)

        case .token(let token):
            switch token {
            case .access(let access):
                try await client.authenticate.token.access(access)
                return Response.success(true)

            case .refresh(let refresh):
                let data = try await client.authenticate.token.refresh(refresh)
                return Response.success(true, data: data)
            }
        case .apiKey(let apiKey):
            let data = try await client.authenticate.apiKey(apiKey)
            return Response.success(true, data: data)

        case .multifactor(let multifactor):
            return try await Identity.Provider.API.Authenticate.Multifactor.response(
                multifactor: multifactor,
                logoutRedirectURL: logoutRedirectURL
            )
        }
    }
}
