//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/08/2024.
//

import Coenttb_Web
import Favicon
import Identity_Consumer

extension Identity.Consumer {
    public struct HTMLDocument<
        Body: HTML
    >: Coenttb_Web.HTMLDocument {
        let route: Identity_Consumer.Route
        let title: (Identity_Consumer.Route) -> String
        let description: (Identity_Consumer.Route) -> String
        let primaryColor: HTMLColor
        let accentColor: HTMLColor
        let favicons: Favicons
        let canonicalHref: URL?
        let hreflang: (Identity_Consumer.Route, Languages.Language) -> URL
        let termsOfUse: URL
        let privacyStatement: URL
        let _body: Body
        
        public init(
            route: Identity_Consumer.Route,
            title: @escaping (Identity_Consumer.Route) -> String,
            description: @escaping (Identity_Consumer.Route) -> String,
            primaryColor: HTMLColor,
            accentColor: HTMLColor,
            @HTMLBuilder favicons: () -> Favicons,
            canonicalHref: URL?,
            hreflang: @escaping (Identity_Consumer.Route, Languages.Language) -> URL,
            termsOfUse: URL,
            privacyStatement: URL,
            @HTMLBuilder body: () -> Body
        ) {
            self.route = route
            self.title = title
            self.description = description
            self.primaryColor = primaryColor
            self.accentColor = accentColor
            self.favicons = favicons()
            self.canonicalHref = canonicalHref
            self.hreflang = hreflang
            self.termsOfUse = termsOfUse
            self.privacyStatement = privacyStatement
            self._body = body()
        }
        
        @Dependency(\.languages) var languages
        
        public var head: some HTML {
            CoenttbWebHTMLDocumentHeader(
                title: title(route),
                description: description(route),
                canonicalHref: canonicalHref,
                rssXml: nil,
                themeColor: accentColor,
                language: language,
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
}





