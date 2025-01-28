//
//  MultifactorAuthentication.Setup.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension MultifactorAuthentication {
    public enum Setup {}
}

extension MultifactorAuthentication.Setup {
    public struct Request: Codable, Hashable, Sendable {
        public let method: MultifactorAuthentication.Method
        public let identifier: String
        
        public init(
            method: MultifactorAuthentication.Method,
            identifier: String = ""
        ) {
            self.method = method
            self.identifier = identifier
        }
    }
}

extension MultifactorAuthentication.Setup {
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
