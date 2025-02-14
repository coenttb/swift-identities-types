//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Web
import DependenciesMacros
import Foundation
import Identity_Consumer

extension Identity.Consumer.Client.Authenticate.Multifactor {
    package static func live(
        provider: Identity.Consumer.Client.Provider,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ api: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.makeRequest
    ) -> Self {
        let apiRouter = Identity.Consumer.API.Router().baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()

        @Dependency(URLRequest.Handler.self) var handleRequest

        return .init(
            setup: .init(
                initialize: { method, identifier in
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.setup(.initialize(.init(method: method, identifier: identifier)))))),
                        decodingTo: Identity.Authentication.Multifactor.Setup.Response.self
                    )
                },
                confirm: { code in
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.setup(.confirm(.init(code: code))))))
                    )
                },
                resetSecret: { _ in
                    fatalError()
                }
            ),
            verification: .init(
                createChallenge: { method in
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.challenge(.create(.init(method: method)))))),
                        decodingTo: Identity.Authentication.Multifactor.Challenge.self
                    )
                },
                verify: { challengeId, code in
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.verify(.verify(.init(challengeId: challengeId, code: code))))))
                    )
                },
                bypass: { _ in
                    fatalError()
                }
            ),
            recovery: .init(
                generateNewCodes: {
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.recovery(.generate)))),
                        decodingTo: [String].self
                    )
                },
                getRemainingCodeCount: {
                    try await handleRequest(
                        for: makeRequest(apiRouter)(.authenticate(.multifactor(.recovery(.count)))),
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
                    for: makeRequest(apiRouter)(.authenticate(.multifactor(.configuration))),
                    decodingTo: Identity.Authentication.Multifactor.Configuration.self
                )
            },
            disable: {
                try await handleRequest(
                    for: makeRequest(apiRouter)(.authenticate(.multifactor(.disable)))
                )
            }
        )
    }
}
