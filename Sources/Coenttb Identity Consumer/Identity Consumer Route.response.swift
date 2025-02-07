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
        router: Identity.Consumer.Route.Router,
        logo: Logo,
        canonicalHref: URL?,
        favicons: Favicons,
        hreflang:  @escaping (Identity.Consumer.View, Language) -> URL,
        termsOfUse: URL,
        privacyStatement: URL,
        dependency: Identity.Consumer.Client,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        homeHref: URL,
        loginHref: URL,
        accountCreateHref: URL,
        verificationSuccessRedirect: URL,
        passwordResetSuccessRedirect: URL,
        currentUserName: () -> String?,
        emailChangeReauthorizationSuccessRedirect: URL,
        confirmEmailChangeSuccessRedirect: URL
    ) async throws -> any AsyncResponseEncodable {
        return try await Self.response(
            route: route,
            logo: logo,
            canonicalHref: canonicalHref,
            favicons: favicons,
            hreflang: hreflang,
            termsOfUse: termsOfUse,
            privacyStatement: privacyStatement,
            dependency: dependency,
            primaryColor: primaryColor,
            accentColor: accentColor,
            homeHref: homeHref,
            loginHref: loginHref,
            accountCreateHref: accountCreateHref,
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
            emailChangeConfirmFormAction: router.url(for: .api(.emailChange(.confirm(.init())))),
            emailChangeReauthorizationSuccessRedirect: emailChangeReauthorizationSuccessRedirect,
            emailChangeRequestAction: router.url(for: .api(.emailChange(.request(.init())))),
            confirmEmailChangeSuccessRedirect: confirmEmailChangeSuccessRedirect
        )
    }
    
    public static func response(
        route: Identity.Consumer.Route,
        logo: Logo,
        canonicalHref: URL?,
        favicons: Favicons,
        hreflang:  @escaping (Identity.Consumer.View, Language) -> URL,
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
        passwordChangeRequestAction: URL,
        passwordResetAction: URL,
        passwordResetConfirmAction: URL,
        passwordResetSuccessRedirect: URL,
        currentUserName: () -> String?,
        emailChangeConfirmFormAction: URL,
        emailChangeReauthorizationSuccessRedirect: URL,
        requestEmailChangeAction: URL,
        confirmEmailChangeSuccessRedirect: URL
    ) async throws -> any AsyncResponseEncodable {
        switch route {
        case .api(let api):
            @Dependency(Identity.Consumer.Client.self) var client
            switch api {
            case .authenticate(let authenticate):
                switch authenticate {
                case .token(let token):
                    switch token {
                    case .access(let access):
                        do {
                            try await client.authenticate.token.access(token: access.token)
                            return Response.success(true)
                        } catch {
                            return Response.success(false)
                        }
                        
    
                        
                    case .refresh(let refresh):
                        do {
                            let response = try await client.authenticate.token.refresh(token: refresh.token)
                            @Dependency(\.request) var request
                            guard let request else { throw Abort(.internalServerError) }

                            request.cookies["refresh_token"] = .jwt(
                                token: response.refreshToken.value,
                                expiresIn: response.refreshToken.expiresIn,
                                path: "/auth/refresh",
                                isHTTPOnly: true,
                                sameSite: .strict
                            )
                            
                            return Response.success(true)
                        } catch {
                            return Response.success(false)
                        }
                    }
                    
                case .credentials(let credentials):
                    do {
                        let response = try await client.authenticate.credentials(credentials: credentials)
                        @Dependency(\.request) var request
                        guard let request else { throw Abort(.internalServerError) }
                        
                        request.cookies.accessToken = .accessToken(response: response)
                        
                        request.cookies.refreshToken = .refreshToken(response: response)
                        return Response.success(true)

                    } catch {
                        return Response.success(false)
                    }
                }
                
            case .create(let create):
                switch create {
                case .request(let request):
                    do {
                        try await client.create.request(email: try .init(request.email), password: request.password)
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                    
                case .verify(let verify):
                    do {
                        try await client.create.verify(email: try .init(verify.email), token: verify.token)
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                }
                
            case .delete(let delete):
                switch delete {
                case .request(let request):
                    do {
                        try await client.delete.request(reauthToken: request.reauthToken)
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                    
                case .cancel:
                    do {
                        try await client.delete.cancel()
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                    
                case .confirm:
                    do {
                        try await client.delete.confirm()
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                }
                
            case .emailChange(let emailChange):
                switch emailChange {
                case .request(let request):
                    do {
                        try await client.emailChange.request(newEmail: try .init(request.newEmail))
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                    
                case .confirm(let confirm):
                    do {
                        try await client.emailChange.confirm(token: confirm.token)
                        return Response.success(true)
                    } catch {
                        return Response.success(false)
                    }
                }
                
            case .logout:
                do {
                    try await client.logout()
                    return Response.success(true)
                } catch {
                    return Response.success(false)
                }
                
            case .password(let password):
                switch password {
                case .reset(let reset):
                    switch reset {
                    case .request(let request):
                        do {
                            try await client.password.reset.request(email: try .init(request.email))
                            return Response.success(true)
                        } catch {
                            return Response.success(false)
                        }
                        
                    case .confirm(let confirm):
                        do {
                            try await client.password.reset.confirm(newPassword: confirm.newPassword, token: confirm.token)
                            return Response.success(true)
                        } catch {
                            return Response.success(false)
                        }
                    }
                case .change(let change):
                    switch change {
                    case .request(let request):
                        do {
                            try await client.password.change.request(
                                currentPassword: request.currentPassword,
                                newPassword: request.newPassword
                            )
                            return Response.success(true)
                        } catch {
                            return Response.success(false)
                        }
                    }
                }
                
            case .reauthorize(let reauthorize):
                do {
                    let response = try await client.reauthorize(password: reauthorize.password)
                    return Response.success(true, data: response)
                } catch {
                    return Response.success(false)
                }
            case .multifactorAuthentication(_):
                fatalError()
            }
        case .view(let view):
            
            func accountDefaultContainer<Content: HTML>(
                @HTMLBuilder _ content: @escaping () -> Content
            ) -> Identity.Consumer.HTMLDocument<_HTMLTuple<HTMLInlineStyle<Logo>, Content>> {
                
                let x = Identity.Consumer.HTMLDocument(
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
                
                return x
            }
            switch view {
            case let .create(create):
                @Dependency(\.request) var request
                guard (try? request?.auth.require(JWT.Token.Access.self)) == nil else {
                    return request?.redirect(to: homeHref.absoluteString) ?? Response.internalServerError
                }
                
                switch create {
                case .request:
                    return accountDefaultContainer {
                        Identity.Create.Request.View(
                            primaryColor: primaryColor,
                            loginHref: loginHref,
                            accountCreateHref: accountCreateHref,
                            createFormAction: createFormAction
                        )
                    }
                case .verify:
                    return accountDefaultContainer {
                        Identity.Create.Verify.View(
                            verificationAction: verificationAction,
                            redirectURL: verificationSuccessRedirect
                        )
                    }
                }
            case .delete:
                @Dependency(\.request) var request
                try request?.auth.require(JWT.Token.Access.self)
                fatalError()
                
            case .login:
                @Dependency(\.request) var request
                guard (try? request?.auth.require(JWT.Token.Access.self)) == nil else {
                    return request?.redirect(to: homeHref.absoluteString) ?? Response.internalServerError
                }
                return accountDefaultContainer {
                    Identity.Authentication.Credentials.View(
                        primaryColor: primaryColor,
                        passwordResetHref: passwordResetHref,
                        accountCreateHref: accountCreateHref,
                        loginFormAction: loginFormAction
                    )
                }
                
            case .logout:
                @Dependency(\.request) var request
                try request?.auth.require(JWT.Token.Access.self)
                return accountDefaultContainer {
                    PageHeader(title: "Hope to see you soon!") {}
                }
                
            case let .password(password):
                switch password {
                case .reset(let reset):
                    switch reset {
                    case .request:
                        return accountDefaultContainer {
                            Identity.Consumer.View.Password.Reset.Request.View(
                                formActionURL: passwordResetAction,
                                homeHref: homeHref,
                                primaryColor: primaryColor
                            )
                        }
                        
                    case .confirm(let confirm):
                        return accountDefaultContainer {
                            Identity.Consumer.View.Password.Reset.Confirm.View(
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
                            Identity.Consumer.View.Password.Change.Request.View(
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
                    @Dependency(\.request) var request
                    try request?.auth.require(JWT.Token.Access.self)
                    
                    guard
                        let currentUserName = currentUserName()
                    else {
                        @Dependencies.Dependency(\.request) var request
                        return request?.redirect(to: loginHref.absoluteString) ?? Response.internalServerError
                    }
                    
                    do {
                        try await dependency.emailChange.request(newEmail: nil)
                    }
                    catch let error as Identity.EmailChange.Request.Error {
                        switch error {
                        case .unauthorized:
                            return accountDefaultContainer {
                                Identity.Consumer.View.Reauthorization.View(
                                    currentUserName: currentUserName,
                                    primaryColor: primaryColor,
                                    passwordResetHref: passwordResetHref,
                                    confirmFormAction: emailChangeConfirmFormAction,
                                    redirectOnSuccess: emailChangeReauthorizationSuccessRedirect
                                )
                            }
                        case .emailIsNil:
                            return accountDefaultContainer {
                                Identity.Consumer.View.EmailChange.Request.View(
                                    formActionURL: emailChangeRequestAction,
                                    homeHref: homeHref,
                                    primaryColor: primaryColor
                                )
                            }
                        }
                    }
                    
                    return accountDefaultContainer {
                        Identity.Consumer.View.EmailChange.Request.View(
                            formActionURL: emailChangeRequestAction,
                            homeHref: homeHref,
                            primaryColor: primaryColor
                        )
                    }
                    
                case .confirm(let confirm):
                    
                    try await dependency.emailChange.confirm(token: confirm.token)
                    
                    return accountDefaultContainer {
                        Identity.Consumer.View.EmailChange.Confirm.View(
                            redirect: confirmEmailChangeSuccessRedirect,
                            primaryColor: primaryColor
                        )
                    }
                case .reauthorization:
                    @Dependency(\.request) var request
                    try request?.auth.require(JWT.Token.Access.self)
                    return accountDefaultContainer {
                        Identity.Consumer.View.Reauthorization.View(
                            currentUserName: "",
                            primaryColor: primaryColor,
                            passwordResetHref: passwordResetHref,
                            confirmFormAction: emailChangeConfirmFormAction,
                            redirectOnSuccess: emailChangeReauthorizationSuccessRedirect
                        )
                    }
                }
                
            case .multifactorAuthentication(_):
                fatalError()
            }
        }
    }
}

extension HTTPCookies.Value {
    public static func jwt(
        token: String,
        expiresIn: TimeInterval,
        path: String = "/",
        domain: String? = nil,
        isSecure: Bool = true,
        isHTTPOnly: Bool = true,
        sameSite: HTTPCookies.SameSitePolicy = .lax
    ) -> HTTPCookies.Value {
        HTTPCookies.Value(
            string: token,
            expires: Date().addingTimeInterval(expiresIn),
            maxAge: Int(expiresIn),
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }
    
    static func accessToken(response: JWT.Response)-> Self {
        .jwt(
            token: response.accessToken.value,
            expiresIn: response.accessToken.expiresIn,
            domain: ".rule.law",
            isSecure: true,
            sameSite: .strict
        )
    }
    
    static func refreshToken(response: JWT.Response)-> Self {
        .jwt(
            token: response.refreshToken.value,
            expiresIn: response.refreshToken.expiresIn,
            path: "/auth/refresh",
            domain: ".rule.law",
            isSecure: true
        )
    }
}

