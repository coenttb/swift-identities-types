//
//  Identity.Authenticate.Multifactor.Setup.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authenticate.Multifactor {
    public enum Setup {}
}

extension Identity.Authenticate.Multifactor.Setup {
    public struct Request: Codable, Hashable, Sendable {
        public let method: Identity.Authenticate.Multifactor.Method
        public let identifier: String
        
        public init(
            method: Identity.Authenticate.Multifactor.Method,
            identifier: String = ""
        ) {
            self.method = method
            self.identifier = identifier
        }
    }
}

extension Identity.Authenticate.Multifactor.Setup {
    public struct Response: Codable, Hashable, Sendable {
        public let secret: String
        public let recoveryCodes: [String]
        
        public init(
            secret: String = "",
            recoveryCodes: [String] = []
        ) {
            self.secret = secret
            self.recoveryCodes = recoveryCodes
        }
    }
}
