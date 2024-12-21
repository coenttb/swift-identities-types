//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/08/2024.
//

import CoenttbWebHTML
import Dependencies
import Favicon
import Foundation
import Languages

public struct CoenttbIdentityHTMLDocument<
    Body: HTML
>: HTMLDocument {
    let route: Route
    let title: (Route) -> String
    let description: (Route) -> String
    let primaryColor: HTMLColor
    let accentColor: HTMLColor
    let languages: [Languages.Language]
    let favicons: Favicons
    let canonicalHref: URL?
    let hreflang: (Route, Languages.Language) -> URL
    let termsOfUse: URL
    let privacyStatement: URL
    let _body: Body
    
    public init(
        route: Route,
        title: @escaping (Route) -> String,
        description: @escaping (Route) -> String,
        primaryColor: HTMLColor,
        accentColor: HTMLColor,
        languages: [Languages.Language],
        @HTMLBuilder favicons: () -> Favicons,
        canonicalHref: URL?,
        hreflang: @escaping (Route, Languages.Language) -> URL,
        termsOfUse: URL,
        privacyStatement: URL,
        @HTMLBuilder body: () -> Body
    ) {
        self.route = route
        self.title = title
        self.description = description
        self.primaryColor = primaryColor
        self.accentColor = accentColor
        self.languages = languages
        self.favicons = favicons()
        self.canonicalHref = canonicalHref
        self.hreflang = hreflang
        self.termsOfUse = termsOfUse
        self.privacyStatement = privacyStatement
        self._body = body()
    }
    
    public var head: some HTML {
        CoenttbWebHTMLDocumentHeader(
            title: title(route),
            description: description(route),
            canonicalHref: canonicalHref,
            rssXml: nil,
            themeColor: accentColor,
            language: language,
            languages: languages,
            hreflang: { language in hreflang(route, language) },
            styles: { HTMLEmpty() },
            scripts: { fontAwesomeScript },
            favicons: { favicons }
        )
    }
    
    @Dependencies.Dependency(\.language) var language
    
    public var body: some HTML {
        HTMLGroup {
            _body
            
            IdentityFooter(
                termsOfUse: self.termsOfUse,
                privacyStatement: self.privacyStatement
            )
            
        }
        .dependency(\.language, language)
        .linkColor(self.primaryColor)
    }
}



