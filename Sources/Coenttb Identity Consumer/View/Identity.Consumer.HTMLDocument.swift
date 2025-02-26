//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/08/2024.
//

import Coenttb_Web
import Favicon
import Identities

extension Identity.Consumer {
    package struct HTMLDocument<
        Body: HTML
    >: Coenttb_Web.HTMLDocument {
        let view: Identity.Consumer.View
        let title: (Identity.Consumer.View) -> String
        let description: (Identity.Consumer.View) -> String
        let _body: Body
        
        @Dependency(\.identity.consumer.branding.primaryColor) var primaryColor
        @Dependency(\.identity.consumer.branding.accentColor) var accentColor
        @Dependency(\.identity.consumer.branding.favicons) var favicons
        @Dependency(\.identity.consumer.canonicalHref) var canonicalHref
        @Dependency(\.identity.consumer.hreflang) var hreflang
        @Dependency(\.identity.consumer.branding.footer_links) var footer_links
        
        package init(
            view: Identity.Consumer.View,
            title: @escaping (Identity.Consumer.View) -> String,
            description: @escaping (Identity.Consumer.View) -> String,
            @HTMLBuilder body: () -> Body
        ) {
            self.view = view
            self.title = title
            self.description = description
            self._body = body()
        }

        @Dependency(\.languages) var languages

        package var head: some HTML {
            CoenttbWebHTMLDocumentHeader(
                title: title(view),
                description: description(view),
                canonicalHref: canonicalHref(view),
                rssXml: nil,
                themeColor: accentColor,
                language: language,
                hreflang: { language in hreflang(view, language) },
                styles: { HTMLEmpty() },
                scripts: { fontAwesomeScript },
                favicons: { favicons }
            )
        }

        @Dependencies.Dependency(\.language) var language

        package var body: some HTML {
            HTMLGroup {
                _body

                Identity.Consumer.View.Footer(links: footer_links)
            }
            .dependency(\.language, language)
            .linkColor(self.primaryColor)
        }
    }
}
