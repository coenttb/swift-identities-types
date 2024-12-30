//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import CasePaths

@CasePathable
public enum Route: Codable, Hashable, Sendable {
    case create(Coenttb_Identity.Route.Create)
    case delete
    case login
    case logout
    case password(Coenttb_Identity.Route.Password)
    case emailChange(Coenttb_Identity.Route.EmailChange)
}

extension Coenttb_Identity.Route {
    public enum Password: Codable, Hashable, Sendable {
        case reset(Coenttb_Identity.Route.Password.Reset)
        case change(Coenttb_Identity.Route.Password.Change)
    }
}

extension Coenttb_Identity.Route.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(Coenttb_Identity.Route.Password.Reset.Confirm)
    }
    
    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}

extension Coenttb_Identity.Route.Password.Change {
    public enum Request {}
}

extension Coenttb_Identity.Route.Password.Reset {
    
    public enum Request {}
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        public let newPassword: String
        
        public init(
            token: String = "",
            newPassword: String = ""
        ) {
            self.token = token
            self.newPassword = newPassword
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case newPassword
        }
    }
}

extension Coenttb_Identity.Route {
    public enum EmailChange: Codable, Hashable, Sendable {
        case request
        case confirm(EmailChange.Confirm)
    }
}

extension Coenttb_Identity.Route.EmailChange {
    
    public enum Request {}
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        
        public init(
            token: String = ""
        ) {
            self.token = token
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
        }
    }
}


extension Coenttb_Identity.Route {
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(Coenttb_Identity.Route.Create.Verify)
    }
}

extension Coenttb_Identity.Route.Create {
    public struct Verify: Codable, Hashable, Sendable {
        public let token: String
        public let email: String
        
        public init(
            token: String = "",
            email: String = ""
        ) {
            self.token = token
            self.email = email
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case email
        }
    }
}

extension Coenttb_Identity.Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.Route> {
            OneOf {
                
                URLRouting.Route(.case(Coenttb_Identity.Route.create)) {
                    Path { "create" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Identity.Route.Create.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(Coenttb_Identity.Route.Create.verify)) {
                            Path { "email-verification" }
                            Parse(.memberwise(Coenttb_Identity.Route.Create.Verify.init)) {
                                Query {
                                    Field(Coenttb_Identity.Route.Create.Verify.CodingKeys.token.rawValue, .string)
                                    Field(Coenttb_Identity.Route.Create.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.Route.login)) {
                    Path { "login" }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.Route.logout)) {
                    Path { "logout" }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.Route.password)) {
                    Path { "password" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Identity.Route.Password.reset)) {
                            Path { "reset" }
                            OneOf {
                                URLRouting.Route(.case(Coenttb_Identity.Route.Password.Reset.request)) {
                                    Path { "request" }
                                }
                                
                                URLRouting.Route(.case(Coenttb_Identity.Route.Password.Reset.confirm)) {
                                    Path { "confirm" }
                                    Parse(.memberwise(Coenttb_Identity.Route.Password.Reset.Confirm.init)) {
                                        Query {
                                            Field(Coenttb_Identity.Route.Password.Reset.Confirm.CodingKeys.token.rawValue, .string)
                                            Field(Coenttb_Identity.Route.Password.Reset.Confirm.CodingKeys.newPassword.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }
                        
                        URLRouting.Route(.case(Coenttb_Identity.Route.Password.change)) {
                            Path { "change" }
                            URLRouting.Route(.case(Coenttb_Identity.Route.Password.Change.request)) {
                                Path { "request" }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.Route.emailChange)) {
                    Path { "email-change" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Identity.Route.EmailChange.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(Coenttb_Identity.Route.EmailChange.confirm)) {
                            Path { "confirm" }
                            Parse(.memberwise(Coenttb_Identity.Route.EmailChange.Confirm.init)) {
                                Query {
                                    Field(Coenttb_Identity.Route.EmailChange.Confirm.CodingKeys.token.rawValue, .string)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
