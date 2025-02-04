//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Web
import Coenttb_Vapor
import Favicon
import Identity_Consumer


extension Identity.Consumer {
    public static func response(
        route: Identity_Consumer.Route,
        logo: Logo,
        canonicalHref: URL?,
        favicons: Favicons,
        hreflang:  @escaping (Identity_Consumer.Route, Language) -> URL,
        termsOfUse: URL,
        privacyStatement: URL,
        dependency: Identity.Consumer.Client,
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
        ) -> Identity.Consumer.HTMLDocument<_HTMLTuple<HTMLInlineStyle<Logo>, Content>> {
            
            let x = Identity.Consumer.HTMLDocument(
                route: route,
                title: { _ in "" },
                description: { _ in "" },
                primaryColor: primaryColor,
                accentColor: accentColor,
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
                    Identity_Shared.Create.Request.View(
                        primaryColor: primaryColor,
                        loginHref: loginHref,
                        accountCreateHref: accountCreateHref,
                        createFormAction: createFormAction
                    )
                }
            case .verify:
                return accountDefaultContainer {
                    Identity_Shared.Create.Verify.View(
                        verificationAction: verificationAction,
                        redirectURL: verificationSuccessRedirect
                    )
                }
            }
        case .delete:
            fatalError()
            
        case .login:
            return accountDefaultContainer {
                Identity_Shared.Authenticate.Credentials.View(
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
                        Route.Password.Reset.Request.View(
                            formActionURL: passwordResetAction,
                            homeHref: homeHref,
                            primaryColor: primaryColor
                        )
                    }
                    
                case .confirm(let confirm):
                    return accountDefaultContainer {
                        Route.Password.Reset.Confirm.View(
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
                        Route.Password.Change.Request.View(
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
                catch let error as Identity_Shared.EmailChange.Request.Error {
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
                            Route.EmailChange.Request.View(
                                formActionURL: requestEmailChangeAction,
                                homeHref: homeHref,
                                primaryColor: primaryColor
                            )
                        }
                    }
                }
                
                return accountDefaultContainer {
                    Route.EmailChange.Request.View(
                        formActionURL: requestEmailChangeAction,
                        homeHref: homeHref,
                        primaryColor: primaryColor
                    )
                }
                
            case .confirm(let confirm):
                
                try await dependency.emailChange.confirm(token: confirm.token)
                
                return accountDefaultContainer {
                    Route.EmailChange.Confirm.View(
                        redirect: confirmEmailChangeSuccessRedirect,
                        primaryColor: primaryColor
                    )
                }
            }
//        case .multifactorAuthentication(_):
//            fatalError()
        }
    }
}
