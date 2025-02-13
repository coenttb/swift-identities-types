//
//  File.swift
//  coenttb-identity
//
//  Created by Assistant on 13/02/2025.
//

import Coenttb_Web
import Coenttb_Vapor
import Identity_Consumer

extension Identity.Consumer.API.Router {
    package static func prepare(
        baseRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        baseURL: URL,
        route: Identity.Consumer.API
    ) throws -> AnyParserPrinter<URLRequestData, Identity.Consumer.API> {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        var router = baseRouter.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        
        switch route {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                // No additional preparation needed for credentials
                break
                
            case .token:
                router = router
                    .setAccessToken(request.cookies.accessToken)
                    .setRefreshToken(request.cookies.refreshToken)
                    .setBearerAuth(request.cookies.accessToken?.string)
                    .eraseToAnyParserPrinter()
                
                
            case .apiKey:
                // No additional preparation needed for API key
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
                // No additional preparation needed for reset
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
