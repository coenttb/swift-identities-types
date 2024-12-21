//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import CoenttbWeb
import MemberwiseInit
import MacroCodableKit
import CasePaths

@CasePathable
public enum Route: Codable, Hashable, Sendable {
    case create(CoenttbIdentity.Route.Create)
    case delete
    case login
    case logout
    case password(CoenttbIdentity.Route.Password)
    case emailChange(CoenttbIdentity.Route.EmailChange)
}

extension CoenttbIdentity.Route {
    public enum Password: Codable, Hashable, Sendable {
        case reset(CoenttbIdentity.Route.Password.Reset)
        case change(CoenttbIdentity.Route.Password.Change)
    }
}

extension CoenttbIdentity.Route.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(CoenttbIdentity.Route.Password.Reset.Confirm)
    }
    
    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}

extension CoenttbIdentity.Route.Password.Change {
    public enum Request {}
}

extension CoenttbIdentity.Route.Password.Reset {
    
    public enum Request {}
    @MemberwiseInit(.public)
    @Codable
    public struct Confirm: Hashable, Sendable {
       @CodingKey("token")
        @Init(default: "")
        public let token: String
        
       @CodingKey("newPassword")
        @Init(default: "")
        public let newPassword: String
    }
}

extension CoenttbIdentity.Route {
    public enum EmailChange: Codable, Hashable, Sendable {
        case request
        case confirm(EmailChange.Confirm)
    }
}

extension CoenttbIdentity.Route.EmailChange {
    
    public enum Request {}
    @MemberwiseInit(.public)
    @Codable
    public struct Confirm: Hashable, Sendable {
       @CodingKey("token")
        @Init(default: "")
        public let token: String
    }
}


extension CoenttbIdentity.Route {
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(CoenttbIdentity.Route.Create.Verify)
    }
}

extension CoenttbIdentity.Route.Create {
    @MemberwiseInit(.public)
    @Codable
    public struct Verify: Hashable, Sendable {
       @CodingKey("token")
        @Init(default: "")
        public let token: String
        
       @CodingKey("email")
        @Init(default: "")
        public let email: String
    }
}

extension CoenttbIdentity.Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbIdentity.Route> {
            OneOf {
                
                URLRouting.Route(.case(CoenttbIdentity.Route.create)) {
                    Path { "create" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbIdentity.Route.Create.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(CoenttbIdentity.Route.Create.verify)) {
                            Path { "email-verification" }
                            Parse(.memberwise(CoenttbIdentity.Route.Create.Verify.init)) {
                                Query {
                                    Field(CoenttbIdentity.Route.Create.Verify.CodingKeys.token.rawValue, .string)
                                    Field(CoenttbIdentity.Route.Create.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.Route.login)) {
                    Path { "login" }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.Route.logout)) {
                    Path { "logout" }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.Route.password)) {
                    Path { "password" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbIdentity.Route.Password.reset)) {
                            Path { "reset" }
                            OneOf {
                                URLRouting.Route(.case(CoenttbIdentity.Route.Password.Reset.request)) {
                                    Path { "request" }
                                }
                                
                                URLRouting.Route(.case(CoenttbIdentity.Route.Password.Reset.confirm)) {
                                    Path { "confirm" }
                                    Parse(.memberwise(CoenttbIdentity.Route.Password.Reset.Confirm.init)) {
                                        Query {
                                            Field(CoenttbIdentity.Route.Password.Reset.Confirm.CodingKeys.token.rawValue, .string)
                                            Field(CoenttbIdentity.Route.Password.Reset.Confirm.CodingKeys.newPassword.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }
                        
                        URLRouting.Route(.case(CoenttbIdentity.Route.Password.change)) {
                            Path { "change" }
                            URLRouting.Route(.case(CoenttbIdentity.Route.Password.Change.request)) {
                                Path { "request" }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.Route.emailChange)) {
                    Path { "email-change" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbIdentity.Route.EmailChange.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(CoenttbIdentity.Route.EmailChange.confirm)) {
                            Path { "confirm" }
                            Parse(.memberwise(CoenttbIdentity.Route.EmailChange.Confirm.init)) {
                                Query {
                                    Field(CoenttbIdentity.Route.EmailChange.Confirm.CodingKeys.token.rawValue, .string)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
