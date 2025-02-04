//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

@CasePathable
public enum Route: Codable, Hashable, Sendable {
    case create(Route.Create)
    case delete
    case login
    case logout
    case password(Route.Password)
    case emailChange(Route.EmailChange)
//    case multifactorAuthentication(Route.MultifactorAuthentication)
}

extension Identity_Consumer.Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Route> {
            OneOf {
                
                URLRouting.Route(.case(Route.create)) {
                    Path.create
                    OneOf {
                        URLRouting.Route(.case(Route.Create.request)) {
                            Path.request
                        }
                        
                        URLRouting.Route(.case(Route.Create.verify)) {
                            Path.emailVerification
                            Parse(.memberwise(Identity_Shared.Create.Verify.init)) {
                                Query {
                                    Field(Identity_Shared.Create.Verify.CodingKeys.token.rawValue, .string)
                                    Field(Identity_Shared.Create.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Route.login)) {
                    Path.login
                }
                
                URLRouting.Route(.case(Route.logout)) {
                    Path.logout
                }
                
                URLRouting.Route(.case(Route.password)) {
                    Path.password
                    OneOf {
                        URLRouting.Route(.case(Route.Password.reset)) {
                            Path.reset
                            OneOf {
                                URLRouting.Route(.case(Route.Password.Reset.request)) {
                                    Path.request
                                }
                                
                                URLRouting.Route(.case(Route.Password.Reset.confirm)) {
                                    Path.confirm
                                    Parse(.memberwise(Route.Password.Reset.Confirm.init)) {
                                        Query {
                                            Field(Route.Password.Reset.Confirm.CodingKeys.token.rawValue, .string)
                                            Field(Route.Password.Reset.Confirm.CodingKeys.newPassword.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }
                        
                        URLRouting.Route(.case(Route.Password.change)) {
                            Path.change
                            URLRouting.Route(.case(Route.Password.Change.request)) {
                                Path.request
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Route.emailChange)) {
                    Path.emailChange
                    OneOf {
                        URLRouting.Route(.case(Route.EmailChange.request)) {
                            Path.request
                        }
                        
                        URLRouting.Route(.case(Route.EmailChange.confirm)) {
                            Path.confirm
                            Parse(.memberwise(Route.EmailChange.Confirm.init)) {
                                Query {
                                    Field(Route.EmailChange.Confirm.CodingKeys.token.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
    //            URLRouting.Route(.case(Route.multifactorAuthentication)) {
    //                Path.multifactorAuthentication
    //                OneOf {
    //                    URLRouting.Route(.case(Route.MultifactorAuthentication.setup)) {
    //                        Path.setup
    //                    }
    //
    //                    URLRouting.Route(.case(Route.MultifactorAuthentication.verify)) {
    //                        Path.verify
    //                    }
    //
    //                    URLRouting.Route(.case(Route.MultifactorAuthentication.manage)) {
    //                        Path.manage
    //                    }
    //                }
    //            }
            }
        }
    }
}


