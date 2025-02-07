//
//  Identity.Authenticate.Multifactor.Setup.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authentication.Multifactor {
    public enum Setup {}
}

extension Identity.Authentication.Multifactor.Setup {
    public struct Request: Codable, Hashable, Sendable {
        public let method: Identity.Authentication.Multifactor.Method
        public let identifier: String
        
        public init(
            method: Identity.Authentication.Multifactor.Method,
            identifier: String = ""
        ) {
            self.method = method
            self.identifier = identifier
        }
    }
}

extension Identity.Authentication.Multifactor.Setup {
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
