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

extension Identity.Consumer.Route {
    public static func response(
       route: Identity.Consumer.Route,
       logo: Identity.Consumer.View.Logo,
       canonicalHref: URL?,
       tokenDomain: String?,
       favicons: Favicons,
       hreflang: @escaping (Identity.Consumer.View, Language) -> URL,
       termsOfUse: URL,
       privacyStatement: URL,
       primaryColor: HTMLColor,
       accentColor: HTMLColor,
       homeHref: URL,
       createProtectedRedirect: URL,
       loginProtectedRedirect: URL,
       logoutSuccessRedirect: URL,
       loginHref: URL = {
           @Dependency(Identity.Consumer.Route.Router.self) var router
           return router.url(for: .view(.login))
       }(),
       loginSuccessRedirect: URL,
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
       createVerificationSuccessRedirect: URL,
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
       passwordResetSuccessRedirect: URL,
       currentUserName: () -> String?,
       emailChangeRequestAction: URL = {
           @Dependency(Identity.Consumer.Route.Router.self) var router
           return router.url(for: .api(.emailChange(.request(.init()))))
       }(),
       emailChangeConfirmFormAction: URL = {
           @Dependency(Identity.Consumer.Route.Router.self) var router
           return router.url(for: .api(.emailChange(.confirm(.init()))))
       }(),
       emailChangeReauthorizationSuccessRedirect: URL,
       emailChangeConfirmSuccessRedirect: URL
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Consumer.Client.self) var client

        do {
            if let response = try Identity.Consumer.Route.protect(
                route: route,
                with: JWT.Token.Access.self,
                createProtectedRedirect: createProtectedRedirect,
                loginProtectedRedirect: loginProtectedRedirect
            ) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }

        switch route {
        case .api(let api):
            return try await Identity.Consumer.API.response(
                api: api,
                tokenDomain: tokenDomain
            )

        case .view(let view):
            return try await Identity.Consumer.View.response(
                view: view,
                currentUserName: currentUserName,
                logo: logo,
                hreflang: hreflang,
                primaryColor: primaryColor,
                accentColor: accentColor,
                favicons: favicons,
                canonicalHref: canonicalHref,
                createVerificationSuccessRedirect: createVerificationSuccessRedirect,
                createProtectedRedirect: createProtectedRedirect,
                loginSuccessRedirect: loginSuccessRedirect,
                loginProtectedRedirect: loginProtectedRedirect,
                logoutSuccessRedirect: logoutSuccessRedirect,
                passwordResetSuccessRedirect: passwordResetSuccessRedirect,
                emailChangeReauthorizationSuccessRedirect: emailChangeReauthorizationSuccessRedirect,
                emailChangeConfirmSuccessRedirect: emailChangeConfirmSuccessRedirect,
                termsOfUse: termsOfUse,
                privacyStatement: privacyStatement
            )
        }
    }
}
