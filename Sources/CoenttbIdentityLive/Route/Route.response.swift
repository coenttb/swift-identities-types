//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import CoenttbIdentity
import CoenttbMarkdown
import CoenttbWebHTML
import Dependencies
import Foundation
import Languages
import CoenttbVapor
import Favicon

extension CoenttbIdentity.Route {
    public static func response<User>(
        route: CoenttbIdentity.Route,
        logo: CoenttbIdentity.Logo,
        canonicalHref: URL?,
        favicons: Favicons,
        hreflang:  @escaping (CoenttbIdentity.Route, Language) -> URL,
        termsOfUse: URL,
        privacyStatement: URL,
        dependency: CoenttbIdentity.Client<User>,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        homeHref: URL,
        loginHref: URL,
        accountCreateHref: URL,
        createFormAction: URL,
        verificationAction: URL,
        verificationSuccessRedirect: URL,
        passwordResetHref: URL,
        loginFormAction: URL,
        logout: () async throws -> Void,
        passwordChangeRequestAction: URL,
        passwordResetAction: URL,
        passwordResetConfirmAction: URL,
        passwordResetSuccessRedirect: URL,
        currentUserName: () -> String?,
        currentUserIsAuthenticated: () -> Bool?,
        emailChangeReauthorizationAction: URL,
        emailChangeReauthorizationSuccessRedirect: URL,
        requestEmailChangeAction: URL,
        confirmEmailChangeSuccessRedirect: URL
    ) async throws -> any AsyncResponseEncodable {
        func accountDefaultContainer<Content: HTML>(
            @HTMLBuilder _ content: @escaping () -> Content
        ) -> CoenttbIdentityHTMLDocument<_HTMLTuple<HTMLInlineStyle<CoenttbIdentity.Logo>, Content>> {
            
            let x = CoenttbIdentityHTMLDocument(
                route: route,
                title: { _ in "" },
                description: { _ in "" },
                primaryColor: primaryColor,
                accentColor: accentColor,
                languages: [.english, .dutch],
                favicons: { favicons },
                canonicalHref: canonicalHref,
                hreflang: hreflang,
                termsOfUse: termsOfUse,
                privacyStatement: privacyStatement,
                body: {
                    logo
                        .margin(top: .medium)
                    
                    content()
                }
            )
            
            return x
        }
        
        switch route {
            
        case let .create(create):
            switch create {
            case .request:
                return accountDefaultContainer {
                    CoenttbIdentity.Create.Request.init(
                        primaryColor: primaryColor,
                        loginHref: loginHref,
                        accountCreateHref: accountCreateHref,
                        createFormAction: createFormAction
                    )
                }
            case .verify:
                return accountDefaultContainer {
                    CoenttbIdentity.Create.Verify(
                        verificationAction: verificationAction,
                        redirectURL: verificationSuccessRedirect
                    )
                }
            }
        case .delete:
            fatalError()
            
        case .login:
            return accountDefaultContainer {
                CoenttbIdentity.Login(
                    primaryColor: primaryColor,
                    passwordResetHref: passwordResetHref,
                    accountCreateHref: accountCreateHref,
                    loginFormAction: loginFormAction
                )
            }
            
        case .logout:
            try await logout()
            
            return accountDefaultContainer {
                PageHeader(title: "Hope to see you soon!") {}
            }
            
        case let .password(password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request:
                    return accountDefaultContainer {
                        CoenttbIdentity.Route.Password.Reset.Request.View(
                            formActionURL: passwordResetAction,
                            homeHref: homeHref,
                            primaryColor: primaryColor
                        )
                    }
                    
                case .confirm(let confirm):
                    return accountDefaultContainer {
                        CoenttbIdentity.Route.Password.Reset.Confirm.View(
                            token: confirm.token,
                            passwordResetAction: passwordResetConfirmAction,
                            homeHref: homeHref,
                            redirect: passwordResetSuccessRedirect,
                            primaryColor: primaryColor
                        )
                    }
                }
                
            case .change(let change):
                switch change {
                case .request:
                    return accountDefaultContainer {
                        CoenttbIdentity.Route.Password.Change.Request.View(
                            formActionURL: passwordChangeRequestAction,
                            redirectOnSuccess: loginHref,
                            primaryColor: primaryColor
                        )
                    }
                }
            }

        case .emailChange(let emailChange):
            switch emailChange {
            case .request:

                guard
                    let currentUserName = currentUserName(),
                    currentUserIsAuthenticated() == true
                else {
                    @Dependencies.Dependency(\.request) var request
                    return request!.redirect(to: loginHref.absoluteString)
                }

                do {
                    try await dependency.emailChange.request(newEmail: nil)
                }
                catch let error as CoenttbIdentity.Client<User>.RequestEmailChangeError {
                    switch error {
                    case .unauthorized:
                        return accountDefaultContainer {
                            ConfirmAccess(
                                currentUserName: currentUserName,
                                primaryColor: primaryColor,
                                passwordResetHref: passwordResetHref,
                                confirmFormAction: emailChangeReauthorizationAction,
                                redirectOnSuccess: emailChangeReauthorizationSuccessRedirect
                            )
                        }
                    case .emailIsNil:
                        return accountDefaultContainer {
                            CoenttbIdentity.Route.EmailChange.Request.View(
                                formActionURL: requestEmailChangeAction,
                                homeHref: homeHref,
                                primaryColor: primaryColor
                            )
                        }
                    }
                }
                
                return accountDefaultContainer {
                    CoenttbIdentity.Route.EmailChange.Request.View(
                        formActionURL: requestEmailChangeAction,
                        homeHref: homeHref,
                        primaryColor: primaryColor
                    )
                }
                
            case .confirm(let confirm):
                
                try await dependency.emailChange.confirm(token: confirm.token)
                
                return accountDefaultContainer {
                    CoenttbIdentity.Route.EmailChange.Confirm.View(
                        redirect: confirmEmailChangeSuccessRedirect,
                        primaryColor: primaryColor
                    )
                }
            }
        }
    }
}
