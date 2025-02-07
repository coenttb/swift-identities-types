//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer {
    @CasePathable
    public enum View: Codable, Hashable, Sendable {
        case create(Identity.Consumer.View.Create)
        case delete
        case login
        case logout
        case reauthorization
        case password(Identity.Consumer.View.Password)
        case emailChange(Identity.Consumer.View.EmailChange)
        case multifactorAuthentication(Identity.Consumer.View.MultifactorAuthentication)
    }
}

extension Identity.Consumer.View {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.Consumer.View> {
            OneOf {
                
                URLRouting.Route(.case(Identity.Consumer.View.create)) {
                    Path.create
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Create.request)) {
                            Path.request
                        }
                        
                        URLRouting.Route(.case(Identity.Consumer.View.Create.verify)) {
                            Path.emailVerification
                            Parse(.memberwise(Identity.Create.Verify.init)) {
                                Query {
                                    Field(Identity.Create.Verify.CodingKeys.token.rawValue, .string)
                                    Field(Identity.Create.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.login)) {
                    Path.login
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.logout)) {
                    Path.logout
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.reauthorization)) {
                    Path.reauthorization
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.password)) {
                    Path.password
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Password.reset)) {
                            Path.reset
                            OneOf {
                                URLRouting.Route(.case(Identity.Consumer.View.Password.Reset.request)) {
                                    Path.request
                                }
                                
                                URLRouting.Route(.case(Identity.Consumer.View.Password.Reset.confirm)) {
                                    Path.confirm
                                    Parse(.memberwise(Identity.Consumer.View.Password.Reset.Confirm.init)) {
                                        Query {
                                            Field(Identity.Consumer.View.Password.Reset.Confirm.CodingKeys.token.rawValue, .string)
                                            Field(Identity.Consumer.View.Password.Reset.Confirm.CodingKeys.newPassword.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }
                        
                        URLRouting.Route(.case(Identity.Consumer.View.Password.change)) {
                            Path.change
                            URLRouting.Route(.case(Identity.Consumer.View.Password.Change.request)) {
                                Path.request
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.emailChange)) {
                    Path.emailChange
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.EmailChange.request)) {
                            Path.request
                        }
                        
                        URLRouting.Route(.case(Identity.Consumer.View.EmailChange.confirm)) {
                            Path.confirm
                            Parse(.memberwise(Identity.Consumer.View.EmailChange.Confirm.init)) {
                                Query {
                                    Field(Identity.Consumer.View.EmailChange.Confirm.CodingKeys.token.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.Consumer.View.multifactorAuthentication)) {
                    Path.multifactorAuthentication
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.MultifactorAuthentication.setup)) {
                            Path.setup
                        }
    
                        URLRouting.Route(.case(Identity.Consumer.View.MultifactorAuthentication.verify)) {
                            Path.verify
                        }
    
                        URLRouting.Route(.case(Identity.Consumer.View.MultifactorAuthentication.manage)) {
                            Path.manage
                        }
                    }
                }
            }
        }
    }
}


