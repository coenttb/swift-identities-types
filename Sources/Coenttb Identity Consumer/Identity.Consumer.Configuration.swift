//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import Identities
import Identities
import Coenttb_Identity_Shared
import URLRouting
import Coenttb_Web
import Favicon
import Vapor

extension Identity.Consumer {
    public struct Configuration: Sendable {
        public var provider: Identity.Consumer.Configuration.Provider
        public var consumer: Identity.Consumer.Configuration.Consumer
        
        public init(provider: Identity.Consumer.Configuration.Provider, consumer: Identity.Consumer.Configuration.Consumer) {
            self.provider = provider
            self.consumer = consumer
        }
    }
}

extension Identity.Consumer.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(
        provider: .testValue,
        consumer: .testValue
    )
}

extension DependencyValues {
    public var identity: Identity.Consumer.Configuration {
        get { self[Identity.Consumer.Configuration.self] }
        set { self[Identity.Consumer.Configuration.self] = newValue }
    }
}

extension Identity.Consumer.Configuration.Consumer: TestDependencyKey {
    public static let testValue: Self = { fatalError() }()
}

extension Identity.Consumer.Configuration {
    public struct Consumer: Sendable {
        public var baseURL: URL
        
        public var domain: String?
        public var cookies: Identity.CookiesConfiguration
        public var router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> {
            didSet {
                self.router = router.baseURL(self.baseURL.absoluteString).eraseToAnyParserPrinter()
            }
        }
        
        public var client: Identity.Consumer.Client
        
        public var currentUserName: @Sendable () -> String?
        public var canonicalHref: @Sendable (Identity.Consumer.View) -> URL?
        public var hreflang: @Sendable (Identity.Consumer.View, Languages.Language) -> URL
        
        public var branding: Branding
        public var navigation: Navigation
        public var redirect: Identity.Consumer.Configuration.Redirect
        public var rateLimiters: RateLimiters
        
        public init(
            baseURL: URL,
            domain: String? = nil,
            cookies: Identity.CookiesConfiguration = .live,
            router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route>,
            client: Identity.Consumer.Client,
            currentUserName: @escaping @Sendable () -> String?,
            canonicalHref: @escaping @Sendable (Identity.Consumer.View) -> URL? = {
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view($0))
            },
            hreflang: @escaping @Sendable (Identity.Consumer.View, Languages.Language) -> URL = { view, _ in
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view(view))
            },
            branding: Branding,
            navigation: Navigation,
            redirect: Identity.Consumer.Configuration.Redirect,
            rateLimiters: RateLimiters = .init()
        ) {
            self.baseURL = baseURL
            self.canonicalHref = canonicalHref
            self.domain = domain
            self.cookies = cookies
            self.router = router
            self.client = client
            self.currentUserName = currentUserName
            self.hreflang = hreflang
            self.branding = branding
            self.navigation = navigation
            self.redirect = redirect
            self.rateLimiters = rateLimiters
        }
    }
}

extension Identity.Consumer.Configuration {
    public struct Redirect: Sendable {
        public var createProtected: @Sendable () -> URL
        public var loginProtected: @Sendable () -> URL
        public var logoutSuccess: @Sendable () -> URL
        public var loginSuccess: @Sendable () -> URL
        public var passwordResetSuccess: @Sendable () -> URL
        public var emailChangeConfirmSuccess: @Sendable () -> URL
        public var createVerificationSuccess: @Sendable () -> URL
        
        public init(
            createProtected: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return URL(string: "/")!
            },
            createVerificationSuccess: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view(.login))
            },
            loginProtected: @escaping @Sendable () -> URL = {
                return URL(string: "/")!
            },
            logoutSuccess: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view(.login))
            },
            loginSuccess: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return URL(string: "/")!
            },
            passwordResetSuccess: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view(.login))
            },
            emailChangeConfirmSuccess: @escaping @Sendable () -> URL = {
                @Dependency(\.identity.consumer.router) var router
                return router.url(for: .view(.login))
            }
        ) {
            self.createProtected = createProtected
            self.loginProtected = loginProtected
            self.logoutSuccess = logoutSuccess
            self.loginSuccess = loginSuccess
            self.passwordResetSuccess = passwordResetSuccess
            self.emailChangeConfirmSuccess = emailChangeConfirmSuccess
            self.createVerificationSuccess = createVerificationSuccess
        }
    }
}

extension Identity.Consumer.Configuration.Redirect {
    public static func toHome() -> Self {
        @Dependency(\.identity.consumer.navigation.home) var home
        
        return .init(
            createProtected: home,
            createVerificationSuccess: home,
            loginProtected: home,
            logoutSuccess: home,
            loginSuccess: home,
            passwordResetSuccess: home,
            emailChangeConfirmSuccess: home
        )
    }
}
 
extension Identity.Consumer.Configuration {
    public struct Navigation: Sendable {
        public var home: @Sendable () -> URL
        
        public init(home: @escaping @Sendable () -> URL) {
            self.home = home
        }
    }
}
 
extension Identity.Consumer.Configuration {
    public struct Branding: Sendable {
        public var logo: Identity.Consumer.View.Logo
        public var primaryColor: HTMLColor
        public var accentColor: HTMLColor
        public var favicons: Favicons
        public var footer_links: [(TranslatedString, URL)]
        public var titleForView: @Sendable (Identity.Consumer.View) -> TranslatedString
        public var descriptionForView: @Sendable (Identity.Consumer.View) -> TranslatedString
        
        public init(
            logo: Identity.Consumer.View.Logo,
            primaryColor: HTMLColor,
            accentColor: HTMLColor,
            favicons: Favicons,
            footer_links: [(TranslatedString, URL)],
            titleForView: @Sendable @escaping (Identity.Consumer.View) -> TranslatedString = Self._title(for:),
            descriptionForView: @Sendable @escaping (Identity.Consumer.View) -> TranslatedString = Self._description(for:)
        ) {
            self.logo = logo
            self.primaryColor = primaryColor
            self.accentColor = accentColor
            self.favicons = favicons
            self.footer_links = footer_links
            self.titleForView = titleForView
            self.descriptionForView = descriptionForView
        }
        
        public init(
            logo: Identity.Consumer.View.Logo,
            primaryColor: HTMLColor,
            accentColor: HTMLColor,
            favicons: Favicons,
            termsOfUse: URL?,
            privacyStatement: URL?,
            titleForView: @Sendable @escaping (Identity.Consumer.View) -> TranslatedString = Self._title(for:),
            descriptionForView: @Sendable @escaping (Identity.Consumer.View) -> TranslatedString = Self._description(for:)
        ) {
            self.logo = logo
            self.primaryColor = primaryColor
            self.accentColor = accentColor
            self.favicons = favicons
            self.footer_links = [termsOfUse.map { (String.terms_of_use, $0) }, privacyStatement.map { (String.privacyStatement, $0) } ].compactMap { $0 }
            self.titleForView = titleForView
            self.descriptionForView = descriptionForView
        }
    }
}

extension Identity.Consumer.Configuration {
    public struct Provider: Sendable {
        public var baseURL: URL
        public var domain: String?
        public var router: AnyParserPrinter<URLRequestData, Identity.API>
        
        public init(
            baseURL: URL,
            domain: String?,
            router: AnyParserPrinter<URLRequestData, Identity.API>
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        }
    }
}

extension Identity.Consumer.Configuration.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        router: Identity.API.Router().eraseToAnyParserPrinter()
    )
}

extension Identity.CookiesConfiguration {
    public static var live: Identity.CookiesConfiguration {
        
        @Dependency(\.identity.consumer.router) var router
        @Dependency(\.identity.consumer.domain) var domain
        
        // We use a dummy 'token' because we only care about the path and not the payload.
        let path = router.url(for: .api(.authenticate(.token(.refresh(.init(value: "token")))))).path
        
        return .init(
            accessToken: .init(
                expires: 60 * 15, // 15 minutes
                maxAge: 60 * 15,
                domain: domain,
                isSecure: true,
                isHTTPOnly: true,
                sameSitePolicy: .strict
            ),
            refreshToken: .init(
                expires: 60 * 60 * 24 * 30, // 30 days
                maxAge: 60 * 60 * 24 * 30,
                domain: domain,
                path: path,
                isSecure: true,
                isHTTPOnly: true,
                sameSitePolicy: .lax
            ),
            reauthorizationToken: .init(
                expires: 60 * 5,
                maxAge: 60 * 5,
                domain: domain,
                isSecure: true,
                isHTTPOnly: true,
                sameSitePolicy: .strict
            )
        )
    }
}

extension Identity.Consumer.Configuration.Branding {
    public static func _title(for view: Identity.Consumer.View) -> TranslatedString {
        switch view {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                return .init(
                    dutch: "Inloggen",
                    english: "Sign In"
                )
            }
        case .create(let create):
            switch create {
            case .request:
                return .init(
                    dutch: "Account Aanmaken",
                    english: "Create Account"
                )
            case .verify:
                return .init(
                    dutch: "Account Verifiëren",
                    english: "Verify Account"
                )
            }
        case .delete:
            return .init(
                dutch: "Account Verwijderen",
                english: "Delete Account"
            )
        case .logout:
            return .init(
                dutch: "Uitloggen",
                english: "Sign Out"
            )
        case .email(let email):
            switch email {
            case .change(let change):
                switch change {
                case .request:
                    return .init(
                        dutch: "E-mailadres Wijzigen",
                        english: "Change Email Address"
                    )
                case .reauthorization:
                    return .init(
                        dutch: "Bevestig Identiteit",
                        english: "Confirm Identity"
                    )
                case .confirm:
                    return .init(
                        dutch: "E-mail Bevestigen",
                        english: "Confirm Email"
                    )
                }
            }
        case .password(let password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request:
                    return .init(
                        dutch: "Wachtwoord Herstellen",
                        english: "Reset Password"
                    )
                case .confirm:
                    return .init(
                        dutch: "Nieuw Wachtwoord Instellen",
                        english: "Set New Password"
                    )
                }
            case .change(let change):
                switch change {
                case .request:
                    return .init(
                        dutch: "Wachtwoord Wijzigen",
                        english: "Change Password"
                    )
                }
            }
        }
    }
}

extension Identity.Consumer.Configuration.Branding {
    public static func _description(for view: Identity.Consumer.View) -> TranslatedString {
        switch view {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                return .init(
                    dutch: "Voer je e-mailadres en wachtwoord in om toegang te krijgen tot je account.",
                    english: "Enter your email address and password to access your account."
                )
            }
        case .create(let create):
            switch create {
            case .request:
                return .init(
                    dutch: "Maak een nieuw account aan om van alle functies gebruik te maken.",
                    english: "Create a new account to access all features."
                )
            case .verify:
                return .init(
                    dutch: "Voer de verificatiecode in die we naar je e-mailadres hebben gestuurd.",
                    english: "Enter the verification code we've sent to your email address."
                )
            }
        case .delete:
            return .init(
                dutch: "Je staat op het punt je account en alle bijbehorende gegevens permanent te verwijderen.",
                english: "You're about to permanently delete your account and all associated data."
            )
        case .logout:
            return .init(
                dutch: "Je wordt uitgelogd van je huidige sessie.",
                english: "You'll be signed out of your current session."
            )
        case .email(let email):
            switch email {
            case .change(let change):
                switch change {
                case .request:
                    return .init(
                        dutch: "Voer het nieuwe e-mailadres in dat je aan je account wilt koppelen.",
                        english: "Enter the new email address you want to associate with your account."
                    )
                case .reauthorization:
                    return .init(
                        dutch: "Voor je veiligheid, bevestig je identiteit om wijzigingen aan te brengen.",
                        english: "For your security, please confirm your identity to make changes."
                    )
                case .confirm:
                    return .init(
                        dutch: "Voer de verificatiecode in die we naar je nieuwe e-mailadres hebben gestuurd.",
                        english: "Enter the verification code we've sent to your new email address."
                    )
                }
            }
        case .password(let password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request:
                    return .init(
                        dutch: "Voer je e-mailadres in om een link te ontvangen waarmee je je wachtwoord kunt herstellen.",
                        english: "Enter your email address to receive a link to reset your password."
                    )
                case .confirm:
                    return .init(
                        dutch: "Stel een nieuw wachtwoord in voor je account.",
                        english: "Set a new password for your account."
                    )
                }
            case .change(let change):
                switch change {
                case .request:
                    return .init(
                        dutch: "Wijzig je huidige wachtwoord om de beveiliging van je account te verbeteren.",
                        english: "Change your current password to improve your account security."
                    )
                }
            }
        }
    }
}
