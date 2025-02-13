//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identity_Consumer

extension Identity.Consumer.View {
    public static func response(
        view: Identity.Consumer.View,
        currentUserName: () -> String?,
        logo: Identity.Consumer.View.Logo,
        hreflang: @escaping (Identity.Consumer.View, Language) -> URL,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        favicons: Favicons,
        canonicalHref: URL?,
        homeHref: URL = URL(string: "/")!,
        createVerificationSuccessRedirect: URL,
        createProtectedRedirect: URL,
        loginSuccessRedirect: URL,
        loginProtectedRedirect: URL,
        logoutSuccessRedirect: URL,
        passwordResetSuccessRedirect: URL,
        emailChangeReauthorizationSuccessRedirect: URL,
        emailChangeConfirmSuccessRedirect: URL,
        termsOfUse: URL,
        privacyStatement: URL,
        loginHref: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .view(.login))
        }(),
        accountCreateHref: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .view(.create(.request)))
        }(),
        createFormAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.create(.request(.init()))))
        }(),
        verificationAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.create(.verify(.init()))))
        }(),
        passwordResetHref: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .view(.password(.reset(.request))))
        }(),
        loginFormAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.authenticate(.credentials(.init()))))
        }(),
        passwordChangeRequestAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.password(.change(.request(change: .init())))))
        }(),
        passwordResetAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.password(.reset(.request(.init())))))
        }(),
        passwordResetConfirmAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.password(.reset(.confirm(.init())))))
        }(),
        emailChangeRequestAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.emailChange(.request(.init()))))
        }(),
        emailChangeConfirmFormAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.emailChange(.confirm(.init()))))
        }(),
        reauthorizationFormAction: URL = {
            @Dependency(Identity.Consumer.Route.Router.self) var router
            return router.url(for: .api(.reauthorize(.init())))
        }()
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Consumer.Client.self) var client
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }

        do {
            if let response = try Identity.Consumer.View.protect(
                view: view,
                with: JWT.Token.Access.self,
                createProtectedRedirect: createProtectedRedirect,
                loginProtectedRedirect: loginProtectedRedirect
            ) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }

        func accountDefaultContainer<Content: HTML>(
            @HTMLBuilder _ content: @escaping () -> Content
        ) -> Identity.Consumer.HTMLDocument<_HTMLTuple<HTMLInlineStyle<Identity.Consumer.View.Logo>, Content>> {
            Identity.Consumer.HTMLDocument(
                view: view,
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
        }

        switch view {
        case let .create(create):
            switch create {
            case .request:
                return accountDefaultContainer {
                    Identity.Consumer.View.Create.Request(
                        primaryColor: primaryColor,
                        loginHref: loginHref,
                        accountCreateHref: accountCreateHref,
                        createFormAction: createFormAction
                    )
                }
            case .verify:
                return accountDefaultContainer {
                    Identity.Consumer.View.Create.Verify(
                        verificationAction: verificationAction,
                        redirectURL: createVerificationSuccessRedirect
                    )
                }
            }
        case .delete:
            fatalError()

        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                return accountDefaultContainer {
                    Identity.Consumer.View.Authenticate.Login(
                        primaryColor: primaryColor,
                        passwordResetHref: passwordResetHref,
                        accountCreateHref: accountCreateHref,
                        loginFormAction: loginFormAction,
                        loginSuccessRedirect: loginSuccessRedirect
                    )
                }
            case .multifactor:
                fatalError()
            }

        case .logout:
            try? await client.logout()

            let response = Response.success(true)
            var accessToken = request.cookies.accessToken
            accessToken?.expires = .distantPast

            var refreshToken = request.cookies.refreshToken
            refreshToken?.expires = .distantPast

            var reauthorizationToken = request.cookies.reauthorizationToken
            reauthorizationToken?.expires = .distantPast

            response.cookies.accessToken = accessToken
            response.cookies.refreshToken = refreshToken
            response.cookies.reauthorizationToken = reauthorizationToken

            let html = accountDefaultContainer {
                PageHeader(title: "Hope to see you soon!") {}
            }

            response.headers.contentType = .html

            let bytes: ContiguousArray<UInt8> = html.render()

            response.body = .init(data: Data(bytes))

            return response

        case let .password(password):
            switch password {
            case .reset(let reset):
                switch reset {
                case .request:
                    return accountDefaultContainer {
                        Identity.Consumer.View.Password.Reset.Request(
                            formActionURL: passwordResetAction,
                            homeHref: homeHref,
                            primaryColor: primaryColor
                        )
                    }

                case .confirm(let confirm):
                    return accountDefaultContainer {
                        Identity.Consumer.View.Password.Reset.Confirm(
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
                        Identity.Consumer.View.Password.Change.Request(
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
                do {

                    guard let requestToken = request.cookies.reauthorizationToken?.string
                    else { throw Abort(.internalServerError) }

                    try await request.jwt.verify(
                        requestToken,
                        as: JWT.Token.Reauthorization.self
                    )

                    return accountDefaultContainer {
                        Identity.Consumer.View.EmailChange.Request(
                            formActionURL: emailChangeRequestAction,
                            homeHref: homeHref,
                            primaryColor: primaryColor
                        )
                    }

                } catch {
                    return accountDefaultContainer {
                        Identity.Consumer.View.Reauthorize(
                            currentUserName: "currentUserName",
                            primaryColor: primaryColor,
                            passwordResetHref: passwordResetHref,
                            confirmFormAction: reauthorizationFormAction,
                            redirectOnSuccess: emailChangeReauthorizationSuccessRedirect
                        )
                    }
                }

            case .confirm(let confirm):

                try await client.emailChange.confirm(token: confirm.token)

                return accountDefaultContainer {
                    Identity.Consumer.View.EmailChange.Confirm(
                        redirect: emailChangeConfirmSuccessRedirect,
                        primaryColor: primaryColor
                    )
                }
            case .reauthorization:
                return accountDefaultContainer {
                    Identity.Consumer.View.Reauthorize(
                        currentUserName: "currentUsername2",
                        primaryColor: primaryColor,
                        passwordResetHref: passwordResetHref,
                        confirmFormAction: reauthorizationFormAction,
                        redirectOnSuccess: homeHref
                    )
                }
            }
        }
    }
}
