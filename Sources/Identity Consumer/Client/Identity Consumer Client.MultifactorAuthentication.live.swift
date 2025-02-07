////
////  File.swift
////  swift-identity
////
////  Created by Coen ten Thije Boonkkamp on 31/01/2025.
////
//
//import Foundation
//import DependenciesMacros
//import Coenttb_Web
//
//extension Identity.Consumer.Client.MultifactorAuthentication {
//    public static func live(
//        provider: Identity.Consumer.Client.Live.Provider,
//        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ api: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
//    ) -> Self {
//        let apiRouter = Identity.Consumer.API.Router().baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()
//        let makeRequest = makeRequest(apiRouter)
//        
//        @Dependency(URLRequest.Handler.self) var handleRequest
//        
//        return .init(
//            setup: .init(
//                initialize: { userId, method, identifier in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.setup(userId, .initialize(.init(method: method, identifier: identifier))))),
//                        decodingTo: MultifactorAuthentication.Setup.Response.self
//                    )
//                },
//                confirm: { userId, code in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.setup(userId, .confirm(.init(code: code)))))
//                    )
//                }
//            ),
//            verification: .init(
//                createChallenge: { userId, method in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.challenge(userId, .create(.init(method: method))))),
//                        decodingTo: MultifactorAuthentication.Challenge.self
//                    )
//                },
//                verify: { userId, challengeId, code in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.verify(userId, .verify(.init(challengeId: challengeId, code: code)))))
//                    )
//                }
//            ),
//            recovery: .init(
//                generateNewCodes: { userId in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.recovery(userId, .generate))),
//                        decodingTo: [String].self
//                    )
//                },
//                getRemainingCodeCount: { userId in
//                    try await handleRequest(
//                        for: makeRequest(.multifactorAuthentication(.recovery(userId, .count))),
//                        decodingTo: Int.self
//                    )
//                }
//            ),
//            getConfiguration: { userId in
//                try await handleRequest(
//                    for: makeRequest(.multifactorAuthentication(.configuration(userId))),
//                    decodingTo: MultifactorAuthentication.Configuration.self
//                )
//            },
//            disable: { userId in
//                try await handleRequest(
//                    for: makeRequest(.multifactorAuthentication(.disable(userId)))
//                )
//            }
//        )
//    }
//}
