//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer.View {
    @CasePathable
    public enum Authenticate: Codable, Hashable, Sendable {
        case credentials
        case multifactor(Identity.Consumer.View.Authenticate.Multifactor)
    }
}

extension Identity.Consumer.View.Authenticate {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.Consumer.View.Authenticate> {
            OneOf {
                
                URLRouting.Route(.case(Identity.Consumer.View.Authenticate.credentials)) {
                    Path.login
                }

                URLRouting.Route(.case(Identity.Consumer.View.Authenticate.multifactor)) {
                    Path.multifactorAuthentication
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Authenticate.Multifactor.setup)) {
                            Path.setup
                        }
    
                        URLRouting.Route(.case(Identity.Consumer.View.Authenticate.Multifactor.verify)) {
                            Path.verify
                        }
    
                        URLRouting.Route(.case(Identity.Consumer.View.Authenticate.Multifactor.manage)) {
                            Path.manage
                        }
                    }
                }
            }
        }
    }
}


