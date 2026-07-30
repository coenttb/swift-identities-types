//
//  Identity.MFA.BackupCodes.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import URLRouting

extension Identity.MFA {
    /// BackupCodes-specific types and operations.
    public struct BackupCodes: @unchecked Sendable {
        public var client: Identity.MFA.BackupCodes.Client
        public var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.MFA.BackupCodes.API>

        public init(
            client: Identity.MFA.BackupCodes.Client,
            router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.MFA.BackupCodes.API> =
                Identity.MFA.BackupCodes
                .API
                .Router().eraseToAnyParserPrinter()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.MFA.BackupCodes {
    /// Request to verify a backup code.
    public struct Verify: Codable, Equatable, Sendable {
        public let code: String
        public let sessionToken: String

        public init(code: String, sessionToken: String) {
            self.code = code
            self.sessionToken = sessionToken
        }
    }

    /// Response with generated backup codes.
    public struct RegenerateResponse: Codable, Equatable, Sendable {
        public let codes: [String]

        public init(codes: [String]) {
            self.codes = codes
        }
    }
}
