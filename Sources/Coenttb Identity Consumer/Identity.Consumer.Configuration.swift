//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import Identity_Shared
import Identity_Consumer
import Coenttb_Identity_Shared
import URLRouting
import Coenttb_Web
import Favicon
import Vapor

extension Identity.Consumer {
    public struct Configuration:  Sendable {
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
        
        public init(
            baseURL: URL,
            domain: String? = nil,
            cookies: Identity.CookiesConfiguration,
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
            redirect: Identity.Consumer.Configuration.Redirect
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
        public var emailChangeReauthorizationSuccess: @Sendable () -> URL
        public var emailChangeConfirmSuccess: @Sendable () -> URL
        public var createVerificationSuccess: @Sendable () -> URL
        
        public init(
            createProtected: @escaping @Sendable () -> URL,
            createVerificationSuccess: @escaping @Sendable () -> URL,
            loginProtected: @escaping @Sendable () -> URL,
            logoutSuccess: @escaping @Sendable () -> URL,
            loginSuccess: @escaping @Sendable () -> URL,
            passwordResetSuccess: @escaping @Sendable () -> URL,
            emailChangeReauthorizationSuccess: @escaping @Sendable () -> URL,
            emailChangeConfirmSuccess: @escaping @Sendable () -> URL
            
        ) {
            self.createProtected = createProtected
            self.loginProtected = loginProtected
            self.logoutSuccess = logoutSuccess
            self.loginSuccess = loginSuccess
            self.passwordResetSuccess = passwordResetSuccess
            self.emailChangeReauthorizationSuccess = emailChangeReauthorizationSuccess
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
            emailChangeReauthorizationSuccess: home,
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
        
        public init(
            logo: Identity.Consumer.View.Logo,
            primaryColor: HTMLColor,
            accentColor: HTMLColor,
            favicons: Favicons,
            footer_links: [(TranslatedString, URL)]
        ) {
            self.logo = logo
            self.primaryColor = primaryColor
            self.accentColor = accentColor
            self.favicons = favicons
            self.footer_links = footer_links
        }
        
        public init(
            logo: Identity.Consumer.View.Logo,
            primaryColor: HTMLColor,
            accentColor: HTMLColor,
            favicons: Favicons,
            termsOfUse: URL?,
            privacyStatement: URL?
        ) {
            self.logo = logo
            self.primaryColor = primaryColor
            self.accentColor = accentColor
            self.favicons = favicons
            self.footer_links = [termsOfUse.map { (String.terms_of_use, $0) }, privacyStatement.map { (String.privacyStatement, $0) } ].compactMap { $0 }
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
    public static let live: Identity.CookiesConfiguration = .init(
        accessToken: .init(
            expires: 60 * 15, // 15 minutes
            maxAge: 60 * 15,
            domain: nil,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .strict
        ),
        refreshToken: .init(
            expires: 60 * 60 * 24 * 30, // 30 days
            maxAge: 60 * 60 * 24 * 30,
            domain: nil,
//                path: router.url(for: .api(.authenticate(.token(.refresh(.init(token: "--------------------")))))).absoluteString,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        ),
        reauthorizationToken: .init(
            expires: 60 * 5,
            maxAge: 60 * 5,
            domain: nil,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .strict
        )
    )
}

