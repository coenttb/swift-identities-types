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
    /// View routing and navigation states for the identity consumer interface.
    ///
    /// This namespace defines the possible view states and navigation flows for client-side
    /// identity management, including:
    /// - Authentication (login/logout)
    /// - Account creation and verification
    /// - Profile management (email, password)
    /// - Account deletion
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
    /// Convenience accessor for the login view state.
    public static let login: Self = .authenticate(.credentials)
}

extension Identity.Consumer.View {
    /// Authentication-related view states.
    ///
    /// Defines the possible UI states during user authentication flows.
    @CasePathable
    public enum Authenticate: Codable, Hashable, Sendable {
        /// Username/password credentials entry view
        case credentials
    }
}

extension Identity.Consumer.View {
    /// Account creation view states.
    ///
    /// Manages the UI flow for new account creation, including:
    /// - Initial registration form
    /// - Email verification
    @CasePathable
    public enum Create: Codable, Hashable, Sendable {
        /// New account registration form view
        case request
        /// Email verification view with token
        case verify(Identity.Creation.Verification)
    }
}

extension Identity.Consumer.View {
    /// Email management view states.
    ///
    /// Handles UI flows for email-related operations like address changes.
    @CasePathable
    public enum Email: Codable, Hashable, Sendable {
        /// Email change flow views
        case change(Identity.Consumer.View.Email.Change)
    }
}

extension Identity.Consumer.View.Email {
    /// Email change flow view states.
    ///
    /// Manages the UI states for changing an account's email address:
    /// - Initial change request
    /// - Verification confirmation
    /// - Security reauthorization if needed
    public enum Change: Codable, Hashable, Sendable {
        /// Email change request form
        case request
        /// Email change confirmation view
        case confirm(Identity.Email.Change.Confirmation)
        /// Security reauthorization view if required
        case reauthorization
    }
}

extension Identity.Consumer.View {
    /// Password management view states.
    ///
    /// Handles UI flows for password-related operations:
    /// - Password reset (forgotten password)
    /// - Password change (while authenticated)
    public enum Password: Codable, Hashable, Sendable {
        /// Password reset flow views
        case reset(Identity.Consumer.View.Password.Reset)
        /// Password change flow views
        case change(Identity.Consumer.View.Password.Change)
    }
}

extension Identity.Consumer.View.Password {
    /// Password reset flow view states.
    ///
    /// Manages the UI states for resetting a forgotten password:
    /// - Initial reset request
    /// - New password confirmation
    public enum Reset: Codable, Hashable, Sendable {
        /// Password reset request form
        case request
        /// New password confirmation view
        case confirm(Identity.Password.Reset.Confirm)
    }
    
    /// Password change flow view states.
    ///
    /// Manages the UI for changing password while authenticated.
    public enum Change: Codable, Hashable, Sendable {
        /// Password change request form
        case request
    }
}

extension Identity.Consumer.View {
    /// URL router for mapping between URLs and view states.
    ///
    /// This router handles bidirectional conversion between URLs and view states,
    /// defining the client-side routing structure for all identity management flows.
    public struct Router: ParserPrinter {
        
        public init() {}
        
        /// The routing configuration for all view states.
        ///
        /// Defines URL patterns for each view state:
        /// - /create/* - Account creation flows
        /// - /login, /credentials - Authentication
        /// - /password/* - Password management
        /// - /email/* - Email management
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



