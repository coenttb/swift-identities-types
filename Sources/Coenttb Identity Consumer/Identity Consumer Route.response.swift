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

extension Identity.Consumer.Route {
    public static func response(
        route: Identity.Consumer.Route,
        currentUserName: () -> String?,
        logo: Identity.Consumer.View.Logo,
        hreflang:  @escaping (Identity.Consumer.View, Language) -> URL,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        favicons: Favicons,
        canonicalHref: URL?,
        tokenDomain: String?,
        createProtectedRedirect: URL,
        loginProtectedRedirect: URL,
        homeHref: URL,
        successfulLoginRedirect: URL,
        verificationSuccessRedirect: URL,
        passwordResetSuccessRedirect: URL,
        emailChangeReauthorizationSuccessRedirect: URL,
        confirmEmailChangeSuccessRedirect: URL,
        termsOfUse: URL,
        privacyStatement: URL
    ) async throws -> any AsyncResponseEncodable {
        @Dependency(Identity.Consumer.Route.Router.self) var router
        
        return try await Self.response(
            route: route,
            logo: logo,
            canonicalHref: canonicalHref,
            tokenDomain: tokenDomain,
            favicons: favicons,
            hreflang: hreflang,
            termsOfUse: termsOfUse,
            privacyStatement: privacyStatement,
            primaryColor: primaryColor,
            accentColor: accentColor,
            homeHref: homeHref,
            createProtectedRedirect: createProtectedRedirect,
            loginProtectedRedirect: loginProtectedRedirect,
            loginHref: router.url(for: .view(.login)),
            successfulLoginRedirect: successfulLoginRedirect,
            accountCreateHref: router.url(for: .view(.create(.request))),
            createFormAction: router.url(for: .api(.create(.request(.init())))),
            verificationAction: router.url(for: .api(.create(.verify(.init())))),
            verificationSuccessRedirect: verificationSuccessRedirect,
            passwordResetHref: router.url(for: .view(.password(.reset(.request)))),
            loginFormAction: router.url(for: .api(.authenticate(.credentials(.init())))),
            passwordChangeRequestAction: router.url(for: .api(.password(.change(.request(change: .init()))))),
            passwordResetAction: router.url(for: .api(.password(.reset(.request(.init()))))),
            passwordResetConfirmAction: router.url(for: .api(.password(.reset(.confirm(.init()))))),
            passwordResetSuccessRedirect: passwordResetSuccessRedirect,
            currentUserName: currentUserName,
            emailChangeRequestAction: router.url(for: .api(.emailChange(.request(.init())))),
            emailChangeConfirmFormAction: router.url(for: .api(.emailChange(.confirm(.init())))),
            emailChangeReauthorizationSuccessRedirect: emailChangeReauthorizationSuccessRedirect,
            confirmEmailChangeSuccessRedirect: confirmEmailChangeSuccessRedirect
        )
    }
    
    private static func response(
        route: Identity.Consumer.Route,
        logo: Identity.Consumer.View.Logo,
        canonicalHref: URL?,
        tokenDomain: String?,
        favicons: Favicons,
        hreflang:  @escaping (Identity.Consumer.View, Language) -> URL,
        termsOfUse: URL,
        privacyStatement: URL,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        homeHref: URL,
        createProtectedRedirect: URL,
        loginProtectedRedirect: URL,
        loginHref: URL,
        successfulLoginRedirect: URL,
        accountCreateHref: URL,
        createFormAction: URL,
        verificationAction: URL,
        verificationSuccessRedirect: URL,
        passwordResetHref: URL,
        loginFormAction: URL,
        passwordChangeRequestAction: URL,
        passwordResetAction: URL,
        passwordResetConfirmAction: URL,
        passwordResetSuccessRedirect: URL,
        currentUserName: () -> String?,
        emailChangeRequestAction: URL,
        emailChangeConfirmFormAction: URL,
        emailChangeReauthorizationSuccessRedirect: URL,
        confirmEmailChangeSuccessRedirect: URL
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
                createProtectedRedirect: createProtectedRedirect,
                loginProtectedRedirect: loginProtectedRedirect,
                successfulLoginRedirect: successfulLoginRedirect,
                homeHref: homeHref,
                verificationSuccessRedirect: verificationSuccessRedirect,
                passwordResetSuccessRedirect: passwordResetSuccessRedirect,
                emailChangeReauthorizationSuccessRedirect: emailChangeReauthorizationSuccessRedirect,
                confirmEmailChangeSuccessRedirect: confirmEmailChangeSuccessRedirect,
                termsOfUse: termsOfUse,
                privacyStatement: privacyStatement
            )
        }
    }
}

