//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation
import DependenciesMacros
import Coenttb_Web

extension Identity.Consumer.Client.Authenticate.Multifactor {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ api: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        let apiRouter = Identity.Consumer.API.Router().baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()
        let makeRequest = makeRequest(apiRouter)
        
        @Dependency(URLRequest.Handler.self) var handleRequest
        
        return .init(
            setup: .init(
                initialize: { method, identifier in
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.setup(.initialize(.init(method: method, identifier: identifier))))),
                        decodingTo: Identity.Authentication.Multifactor.Setup.Response.self
                    )
                },
                confirm: { code in
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.setup(.confirm(.init(code: code)))))
                    )
                },
                resetSecret: { method in
                    fatalError()
                }
            ),
            verification: .init(
                createChallenge: { method in
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.challenge(.create(.init(method: method))))),
                        decodingTo: Identity.Authentication.Multifactor.Challenge.self
                    )
                },
                verify: { challengeId, code in
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.verify(.verify(.init(challengeId: challengeId, code: code)))))
                    )
                },
                bypass: { string in
                    fatalError()
                }
            ),
            recovery: .init(
                generateNewCodes: {
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.recovery(.generate))),
                        decodingTo: [String].self
                    )
                },
                getRemainingCodeCount: {
                    try await handleRequest(
                        for: makeRequest(.multifactorAuthentication(.recovery(.count))),
                        decodingTo: Int.self
                    )
                },
                getUsedCodes: {
                    fatalError()
                }
            ),
            administration: .init(
                forceDisable: {
                    fatalError()
                }
            ),
            configuration: {
                try await handleRequest(
                    for: makeRequest(.multifactorAuthentication(.configuration)),
                    decodingTo: Identity.Authentication.Multifactor.Configuration.self
                )
            },
            disable: {
                try await handleRequest(
                    for: makeRequest(.multifactorAuthentication(.disable))
                )
            }
        )
    }
}
