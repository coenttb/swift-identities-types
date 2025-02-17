//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Identity_Shared
import Dependencies

extension Identity {
    public struct CookiesConfiguration: Sendable, Codable, Hashable {
        public let accessToken: JWT.Token.Config
        public let refreshtoken: JWT.Token.Config
        public let reauthorizationtoken: JWT.Token.Config
        
        public init(
            accessToken: JWT.Token.Config,
            refreshtoken: JWT.Token.Config,
            reauthorizationtoken: JWT.Token.Config
        ) {
            self.accessToken = accessToken
            self.refreshtoken = refreshtoken
            self.reauthorizationtoken = reauthorizationtoken
        }
    }
}

extension Identity.CookiesConfiguration: TestDependencyKey {
    public static let testValue: Self = .init(
        accessToken: .forAccessToken(issuer: "test"),
        refreshtoken: .forRefreshToken(issuer: "test"),
        reauthorizationtoken: .forReauthorizationToken(issuer: "test")
    )
}
