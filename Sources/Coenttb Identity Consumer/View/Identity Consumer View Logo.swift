//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Coenttb_Web
import Foundation
import Identity_Consumer

extension Identity.Consumer.View {
    public struct Logo: HTML {
        let logo: SVG
        let href: URL

        public init(logo: SVG, href: URL) {
            self.logo = logo
            self.href = href
        }

        public var body: some HTML {
            VStack {
                Link(href: href.relativePath) {
                    logo
                }
                .linkColor(.primary)
                .display(.inlineBlock)
                .margin(horizontal: .auto)
            }
        }
    }
}
