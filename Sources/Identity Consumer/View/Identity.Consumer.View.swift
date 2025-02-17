//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import CasePaths
import Coenttb_Web
import Identity_Shared

extension Identity.Consumer {
    @CasePathable
    public enum View: Codable, Hashable, Sendable {
        case create(Identity.Consumer.View.Create)
        case delete
        case authenticate(Identity.Consumer.View.Authenticate)
        case logout
        case emailChange(Identity.Consumer.View.EmailChange)
        case password(Identity.Consumer.View.Password)

        public static let login: Self = .authenticate(.credentials)
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
                            Path.emailVerification
                            Parse(.memberwise(Identity.Create.Verify.init)) {
                                Query {
                                    Field(Identity.Create.Verify.CodingKeys.token.rawValue, .string)
                                }
                                Query {
                                    Field(Identity.Create.Verify.CodingKeys.email.rawValue, .string)
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

                URLRouting.Route(.case(Identity.Consumer.View.emailChange)) {
                    Path.emailChange
                    OneOf {
                        URLRouting.Route(.case(Identity.Consumer.View.EmailChange.reauthorization)) {
                            Path.reauthorization
                        }

                        URLRouting.Route(.case(Identity.Consumer.View.EmailChange.request)) {
                            Path.request
                        }

                        URLRouting.Route(.case(Identity.Consumer.View.EmailChange.confirm)) {
                            Path.confirm
                            Parse(.memberwise(Identity.EmailChange.Confirm.init)) {
                                Query {
                                    Field(Identity.EmailChange.Confirm.CodingKeys.token.rawValue, .string)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
