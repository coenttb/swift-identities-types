//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 15/09/2024.
//

import Foundation
import Coenttb_Web

extension Identity.Consumer.View {
    public struct Footer: HTML {
        let links: [(TranslatedString, URL)]

        public init(links: [(TranslatedString, URL)]) {
            self.links = links
        }
        
        public var body: some HTML {
            footer {
                if !links.isEmpty {
                    HStack {
                        HTMLForEach(Array(links.enumerated())) { index, link in
                            if index > 0 {
                                div { "|" }
                                    .width(1.rem)
                                    .textAlign(.center)
                                    .padding(.horizontal(0.5.rem))
                            }
                            
                            Link(link.0.capitalizingFirstLetter().description,
                                 href: link.1.absoluteString)
                                .inlineStyle("flex", "1")
                                .textAlign(links.count == 1 ? .center :
                                         index == 0 ? .right : .left)
                        }
                    }
                    .maxWidth(800.px)
                    .margin(horizontal: .auto)
                    .padding(1.rem)
                }
            }
            .fontSize(.secondary)
            .color(.gray600)
            .fontWeight(.light)
        }
    }
}

extension Identity.Consumer.View.Footer {
    public init(termsOfUse: URL?, privacyStatement: URL?) {
        var links: [(TranslatedString, URL)] = []
        
        if let termsOfUse {
            links.append((String.terms_of_use, termsOfUse))
        }
        
        if let privacyStatement {
            links.append((String.privacyStatement, privacyStatement))
        }
        
        self.init(links: links)
    }
}
