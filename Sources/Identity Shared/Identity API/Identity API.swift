//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Web

extension Identity {
    public enum API: Equatable, Sendable {
        case authenticate(Identity.API.Authenticate)
        case create(Identity.API.Create)
        case delete(Identity.API.Delete)
        case emailChange(Identity.API.EmailChange)
        case logout
        case reauthorize(Identity.API.Reauthorize)
        case password(Identity.API.Password)
        case multifactorAuthentication(Identity.API.Authenticate.Multifactor)
    }
}

extension Identity.API {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.API> {
            OneOf {
                
                URLRouting.Route(.case(Identity.API.create)) {
                    Path.create
                    Identity.API.Create.Router()
                }
                
                URLRouting.Route(.case(Identity.API.delete)) {
                    Path.delete
                    Identity.API.Delete.Router()
                }
                
                URLRouting.Route(.case(Identity.API.authenticate)) {
                    Path.authenticate
                    Identity.API.Authenticate.Router()
                }

                URLRouting.Route(.case(Identity.API.logout)) {
                    Path.logout
                    Method.post
                }
                
                URLRouting.Route(.case(Identity.API.reauthorize)) {
                    Path.authenticate
                    Body(.form(Identity.API.Reauthorize.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Identity.API.password)) {
                    Path.password
                    Identity.API.Password.Router()
                }
                
                URLRouting.Route(.case(Identity.API.emailChange)) {
                    Path.emailChange
                    Identity.API.EmailChange.Router()
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

extension Identity.API.Router: TestDependencyKey {
    public static let testValue: Identity.API.Router = liveValue
    public static let liveValue: Identity.API.Router = .init()
}
