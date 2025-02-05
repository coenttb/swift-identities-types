//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Web

extension Identity {
    public enum API: Equatable, Sendable {
        case create(Identity.API.Create)
        case authenticate(Identity.Authenticate)
//        case currentUser
        case logout
//        case update(User?)
        case delete(Identity.API.Delete)
        case password(Identity.API.Password)
        case emailChange(Identity.API.EmailChange)
//        case multifactorAuthentication(Identity.API.MultifactorAuthentication)
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
                
//                URLRouting.Route(.case(Identity.API.update)) {
//                    Path.update
//                    Method.post
//                    Body(.form(User?.self, decoder: .default))
//                }
                
                URLRouting.Route(.case(Identity.API.delete)) {
                    Path.delete
                    Identity.API.Delete.Router()
                }
                
                URLRouting.Route(.case(Identity.API.authenticate)) {
                    Path.authenticate
                    Identity.Authenticate.Router()
                }
//                
//                URLRouting.Route(.case(Identity.API.currentUser)) {
//                    Path.currentUser
//                    Method.get
//                }
                
                URLRouting.Route(.case(Identity.API.logout)) {
                    Path.logout
                    Method.post
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
