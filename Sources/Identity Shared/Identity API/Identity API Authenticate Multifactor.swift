//
//  API.MultifactorAuthentication.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation
import Coenttb_Web

extension Identity.API.Authenticate {
    public enum Multifactor: Equatable, Sendable {
        case setup(Identity.API.Authenticate.Multifactor.Setup)
        case challenge(Identity.API.Authenticate.Multifactor.Challenge)
        case verify(Identity.API.Authenticate.Multifactor.Verify)
        case recovery(Identity.API.Authenticate.Multifactor.Recovery)
        case configuration
        case disable
    }
}

extension Identity.API.Authenticate.Multifactor {
    public enum Setup: Equatable, Sendable {
        case initialize(Identity.Authentication.Multifactor.Setup.Request)
        case confirm(Setup.Confirm)
    }
}

extension Identity.API.Authenticate.Multifactor.Setup {
    public struct Confirm: Codable, Hashable, Sendable {
        public let code: String
        
        public init(code: String = "") {
            self.code = code
        }
    }
}

extension Identity.API.Authenticate.Multifactor {
    public enum Challenge: Equatable, Sendable {
        case create(Challenge.Create)
    }
}

extension Identity.API.Authenticate.Multifactor.Challenge {
    public struct Create: Codable, Hashable, Sendable {
        public let method: Identity.Authentication.Multifactor.Method
        
        public init(method: Identity.Authentication.Multifactor.Method) {
            self.method = method
        }
    }
}

extension Identity.API.Authenticate.Multifactor {
    public enum Verify: Equatable, Sendable {
        case verify(Identity.Authentication.Multifactor.Verification)
    }
}

extension Identity.API.Authenticate.Multifactor {
    public enum Recovery: Equatable, Sendable {
        case generate
        case count
    }
}

extension Identity.API.Authenticate.Multifactor {
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.Authenticate.Multifactor> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.setup)) {
                    Path.setup
                    OneOf {
                        URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Setup.initialize)) {
                            Path.initialize
                            Method.post
                            Body(.form(Identity.Authentication.Multifactor.Setup.Request.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Setup.confirm)) {
                            Path.confirm
                            Method.post
                            Body(.form(Identity.API.Authenticate.Multifactor.Setup.Confirm.self, decoder: .default))
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.challenge)) {
                    Path.challenge
                    URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Challenge.create)) {
                        Method.post
                        Body(.form(Identity.API.Authenticate.Multifactor.Challenge.Create.self, decoder: .default))
                    }
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.verify)) {
                    Path.verify
                    URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Verify.verify)) {
                        Method.post
                        Body(.form(Identity.Authentication.Multifactor.Verification.self, decoder: .default))
                    }
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.recovery)) {
                    Path.recovery
                    OneOf {
                        URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Recovery.generate)) {
                            Path.generate
                            Method.post
                        }
                        
                        URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.Recovery.count)) {
                            Path.count
                            Method.get
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.configuration)) {
                    Path.configuration
                    Method.get
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.Multifactor.disable)) {
                    Path.disable
                    Method.post
                }
            }
        }
    }
}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
