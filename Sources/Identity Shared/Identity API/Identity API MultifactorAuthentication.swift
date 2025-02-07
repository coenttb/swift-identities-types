////
////  API.MultifactorAuthentication.swift
////  swift-identity
////
////  Created by Coen ten Thije Boonkkamp on 31/01/2025.
////
//
//import Foundation
//import Coenttb_Web
//
//extension Identity.API {
//    public enum MultifactorAuthentication: Equatable, Sendable {
//        case setup(_ userId: User.ID, Identity.API.MultifactorAuthentication.Setup)
//        case challenge(_ userId: User.ID, Identity.API.MultifactorAuthentication.Challenge)
//        case verify(_ userId: User.ID, Identity.API.MultifactorAuthentication.Verify)
//        case recovery(_ userId: User.ID, Identity.API.MultifactorAuthentication.Recovery)
//        case configuration(_ userId: User.ID)
//        case disable(_ userId: User.ID)
//    }
//}
//
//extension Identity.API.MultifactorAuthentication {
//    public enum Setup: Equatable, Sendable {
//        case initialize(MultifactorAuthentication.Setup.Request)
//        case confirm(Setup.Confirm)
//    }
//}
//
//extension Identity.API.MultifactorAuthentication.Setup {
//    public struct Confirm: Codable, Hashable, Sendable {
//        public let code: String
//        
//        public init(code: String = "") {
//            self.code = code
//        }
//    }
//}
//
//extension Identity.API.MultifactorAuthentication {
//    public enum Challenge: Equatable, Sendable {
//        case create(Challenge.Create)
//    }
//}
//
//extension Identity.API.MultifactorAuthentication.Challenge {
//    public struct Create: Codable, Hashable, Sendable {
//        public let method: MultifactorAuthentication.Method
//        
//        public init(method: MultifactorAuthentication.Method) {
//            self.method = method
//        }
//    }
//}
//
//extension Identity.API.MultifactorAuthentication {
//    public enum Verify: Equatable, Sendable {
//        case verify(MultifactorAuthentication.Verification)
//    }
//}
//
//extension Identity.API.MultifactorAuthentication {
//    public enum Recovery: Equatable, Sendable {
//        case generate
//        case count
//    }
//}
//
//extension Identity.API.MultifactorAuthentication {
//    public struct Router: ParserPrinter, Sendable {
//        public init() {}
//        
//        public var body: some URLRouting.Router<Identity.API.MultifactorAuthentication> {
//            OneOf {
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.setup)) {
//                    Path.setup
//                    UserIDParser()
//                    OneOf {
//                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Setup.initialize)) {
//                            Path.initialize
//                            Method.post
//                            Body(.form(MultifactorAuthentication.Setup.Request.self, decoder: .default))
//                        }
//                        
//                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Setup.confirm)) {
//                            Path.confirm
//                            Method.post
//                            Body(.form(Identity.API.MultifactorAuthentication.Setup.Confirm.self, decoder: .default))
//                        }
//                    }
//                }
//                
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.challenge)) {
//                    Path.challenge
//                    UserIDParser()
//                    URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Challenge.create)) {
//                        Method.post
//                        Body(.form(Identity.API.MultifactorAuthentication.Challenge.Create.self, decoder: .default))
//                    }
//                }
//                
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.verify)) {
//                    Path.verify
//                    UserIDParser()
//                    URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Verify.verify)) {
//                        Method.post
//                        Body(.form(MultifactorAuthentication.Verification.self, decoder: .default))
//                    }
//                }
//                
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.recovery)) {
//                    Path.recovery
//                    UserIDParser()
//                    OneOf {
//                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Recovery.generate)) {
//                            Path.generate
//                            Method.post
//                        }
//                        
//                        URLRouting.Route(.case(Identity.API.MultifactorAuthentication.Recovery.count)) {
//                            Path.count
//                            Method.get
//                        }
//                    }
//                }
//                
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.configuration)) {
//                    Path.configuration
//                    Method.get
//                    UserIDParser()
//                }
//                
//                URLRouting.Route(.case(Identity.API.MultifactorAuthentication.disable)) {
//                    Path.disable
//                    Method.post
//                    UserIDParser()
//                }
//            }
//        }
//    }
//}
//
//extension UrlFormDecoder {
//    fileprivate static var `default`: UrlFormDecoder {
//        let decoder = UrlFormDecoder()
//        decoder.parsingStrategy = .bracketsWithIndices
//        return decoder
//    }
//}
