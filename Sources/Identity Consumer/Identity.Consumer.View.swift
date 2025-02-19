//
//  File.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import CasePaths
import Identity_Shared
import SwiftWeb

extension Identity.Consumer {
    @CasePathable
    public enum View: Codable, Hashable, Sendable {
        case authenticate(Identity.Consumer.View.Authenticate)
        case create(Identity.Consumer.View.Create)
        case delete
        case logout
        case email(Identity.Consumer.View.Email)
        case password(Identity.Consumer.View.Password)
    }
}

extension Identity.Consumer.View {
    public static let login: Self = .authenticate(.credentials)
}

extension Identity.Consumer.View {
    @CasePathable
    public enum Authenticate: Codable, Hashable, Sendable {
        case credentials
    }
}

extension Identity.Consumer.View {
    @CasePathable
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(Identity.Creation.Verification)
    }
}

extension Identity.Consumer.View {
    @CasePathable
    public enum Email: Codable, Hashable, Sendable {
        case change(Identity.Consumer.View.Email.Change)
    }
}

extension Identity.Consumer.View.Email {
    public enum Change: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.Email.Change.Confirmation)
        case reauthorization
    }
}

extension Identity.Consumer.View {
    public enum Password: Codable, Hashable, Sendable {
        case reset(Identity.Consumer.View.Password.Reset)
        case change(Identity.Consumer.View.Password.Change)
    }
}

extension Identity.Consumer.View.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.Password.Reset.Confirm)
    }

    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}

extension Identity.Consumer.View {
    public struct Router: ParserPrinter {

        public init() {}

        public var body: some URLRouting.Router<Identity.Consumer.View> {
            OneOf {

                URLRouting.Route(.case(Identity.Consumer.View.create)) {
                    Path.create

                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Create.request)) {
                            Path.request
                        }

                        URLRouting.Route(.case(Identity.Consumer.View.Create.verify)) {
                            Path.verification

                            Parse(.memberwise(Identity.Creation.Verification.init)) {
                                Query {
                                    Field(Identity.Creation.Verification.CodingKeys.token.rawValue, .string)
                                }
                                Query {
                                    Field(Identity.Creation.Verification.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }

                URLRouting.Route(.case(Identity.Consumer.View.authenticate)) {
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Authenticate.credentials)) {
                            OneOf {
                                Path.credentials
                                Path.login
                            }
                        }
                    }
                }

                URLRouting.Route(.case(Identity.Consumer.View.logout)) {
                    Path.logout
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

                                    Parse(.memberwise(Identity.Password.Reset.Confirm.init)) {
                                        Query {
                                            Field(Identity.Password.Reset.Confirm.CodingKeys.token.rawValue, .string)
                                        }
                                        Query {
                                            Field(Identity.Password.Reset.Confirm.CodingKeys.newPassword.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }

                        URLRouting.Route(.case(Identity.Consumer.View.Password.change)) {
                            Path.change

                            OneOf {
                                URLRouting.Route(.case(Identity.Consumer.View.Password.Change.request)) {
                                    Path.request
                                }
                            }
                        }
                    }
                }

                URLRouting.Route(.case(Identity.Consumer.View.email)) {
                    Path.email
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.Email.change)) {
                            Path.change

                            OneOf {
                                URLRouting.Route(.case(Identity.Consumer.View.Email.Change.reauthorization)) {
                                    Path.reauthorization
                                }

                                URLRouting.Route(.case(Identity.Consumer.View.Email.Change.request)) {
                                    Path.request
                                }

                                URLRouting.Route(.case(Identity.Consumer.View.Email.Change.confirm)) {
                                    Path.confirm

                                    Parse(.memberwise(Identity.Email.Change.Confirmation.init)) {
                                        Query {
                                            Field(Identity.Email.Change.Confirmation.CodingKeys.token.rawValue, .string)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



