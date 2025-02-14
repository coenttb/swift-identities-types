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
        
    ) -> Self {

        @Dependency(Identity.Consumer.Client.self) var client
                
        return .init(
            setup: .init(
                initialize: { method, identifier in
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.setup(.initialize(.init(method: method, identifier: identifier))))),
                        decodingTo: Identity.Authentication.Multifactor.Setup.Response.self
                    )
                },
                confirm: { code in
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.setup(.confirm(.init(code: code)))))
                    )
                },
                resetSecret: { _ in
                    fatalError()
                }
            ),
            verification: .init(
                createChallenge: { method in
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.challenge(.create(.init(method: method))))),
                        decodingTo: Identity.Authentication.Multifactor.Challenge.self
                    )
                },
                verify: { challengeId, code in
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.verify(.verify(.init(challengeId: challengeId, code: code)))))
                    )
                },
                bypass: { _ in
                    fatalError()
                }
            ),
            recovery: .init(
                generateNewCodes: {
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.recovery(.generate))),
                        decodingTo: [String].self
                    )
                },
                getRemainingCodeCount: {
                    try await client.handleRequest(
                        for: .authenticate(.multifactor(.recovery(.count))),
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
                try await client.handleRequest(
                    for: .authenticate(.multifactor(.configuration)),
                    decodingTo: Identity.Authentication.Multifactor.Configuration.self
                )
            },
            disable: {
                try await client.handleRequest(
                    for: .authenticate(.multifactor(.disable))
                )
            }
        )
    }
}
