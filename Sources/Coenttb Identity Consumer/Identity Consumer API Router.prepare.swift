//
//  File.swift
//  coenttb-identity
//
//  Created by Assistant on 13/02/2025.
//

import Coenttb_Vapor
import Coenttb_Web
import Identity_Consumer

extension Identity.Consumer.API.Router {
    package static func prepare(
        baseRouter: some URLRouting.Router<Identity.Consumer.API>,
        route: Identity.Consumer.API
    ) throws -> AnyParserPrinter<URLRequestData, Identity.Consumer.API> {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }

        @Dependency(Identity.Consumer.Client.Provider.self) var provider
        var router = baseRouter.baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()

        switch route {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                break

            case .token:
                router = router
                    .setAccessToken(request.cookies.accessToken)
                    .setRefreshToken(request.cookies.refreshToken)
                    .setBearerAuth(request.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()

            case .apiKey:
                break

            case .multifactor:
                router = router
                    .setAccessToken(request.cookies.accessToken)
                    .setRefreshToken(request.cookies.refreshToken)
                    .setBearerAuth(request.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
            }

        case .emailChange:
            router = router
                .setAccessToken(request.cookies.accessToken)
                .setRefreshToken(request.cookies.refreshToken)
                .setReauthorizationToken(request.cookies.reauthorizationToken)
                .setBearerAuth(request.cookies.accessToken?.string)
                .eraseToAnyParserPrinter()

        case .password(let password):
            switch password {
            case .reset:
                break

            case .change:
                router = router
                    .setAccessToken(request.cookies.accessToken)
                    .setRefreshToken(request.cookies.refreshToken)
                    .setBearerAuth(request.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
            }

        case .create, .delete, .logout, .reauthorize:
            router = router
                .setAccessToken(request.cookies.accessToken)
                .setRefreshToken(request.cookies.refreshToken)
                .setBearerAuth(request.cookies.accessToken?.string)
                .eraseToAnyParserPrinter()
        }

        return router.eraseToAnyParserPrinter()
    }
}
