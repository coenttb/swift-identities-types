//
//  API.MultifactorAuthentication.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation
import Coenttb_Web

extension Identity.API {
    public enum MultifactorAuthentication: Equatable, Sendable {
        case setup(Identity.API.MultifactorAuthentication.Setup)
        case challenge(Identity.API.MultifactorAuthentication.Challenge)
        case verify(Identity.API.MultifactorAuthentication.Verify)
        case recovery(Identity.API.MultifactorAuthentication.Recovery)
        case configuration
        case disable
    }
}

extension Identity.API.MultifactorAuthentication {
    public enum Setup: Equatable, Sendable {
        case initialize(Identity.Authentication.Multifactor.Setup.Request)
        case confirm(Setup.Confirm)
    }
}

extension Identity.API.MultifactorAuthentication.Setup {
    public struct Confirm: Codable, Hashable, Sendable {
        public let code: String
        
        public init(code: String = "") {
            self.code = code
        }
    }
}

extension Identity.API.MultifactorAuthentication {
    public enum Challenge: Equatable, Sendable {
        case create(Challenge.Create)
    }
}

extension Identity.API.MultifactorAuthentication.Challenge {
    public struct Create: Codable, Hashable, Sendable {
        public let method: Identity.Authentication.Multifactor.Method
        
        public init(method: Identity.Authentication.Multifactor.Method) {
            self.method = method
        }
    }
}

extension Identity.API.MultifactorAuthentication {
    public enum Verify: Equatable, Sendable {
        case verify(Identity.Authentication.Multifactor.Verification)
    }
}

extension Identity.API.MultifactorAuthentication {
    public enum Recovery: Equatable, Sendable {
        case generate
        case count
    }
}

extension Identity.API.MultifactorAuthentication {
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MultifactorAuthentication> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.setup)) {
                    Path.setup
                    OneOf {
                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Setup.initialize)) {
                            Path.initialize
                            Method.post
                            Body(.form(Identity.Authentication.Multifactor.Setup.Request.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Setup.confirm)) {
                            Path.confirm
                            Method.post
                            Body(.form(Identity.API.MultifactorAuthentication.Setup.Confirm.self, decoder: .default))
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.challenge)) {
                    Path.challenge
                    URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Challenge.create)) {
                        Method.post
                        Body(.form(Identity.API.MultifactorAuthentication.Challenge.Create.self, decoder: .default))
                    }
                }
                
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.verify)) {
                    Path.verify
                    URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Verify.verify)) {
                        Method.post
                        Body(.form(Identity.Authentication.Multifactor.Verification.self, decoder: .default))
                    }
                }
                
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.recovery)) {
                    Path.recovery
                    OneOf {
                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Recovery.generate)) {
                            Path.generate
                            Method.post
                        }
                        
                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Recovery.count)) {
                            Path.count
                            Method.get
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.configuration)) {
                    Path.configuration
                    Method.get
                }
                
                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.disable)) {
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
