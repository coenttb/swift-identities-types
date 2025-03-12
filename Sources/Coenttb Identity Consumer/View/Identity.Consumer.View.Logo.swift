//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Coenttb_Web
import Foundation
import Identities

extension Identity.Consumer.View {
    public struct Logo: HTML, Sendable {
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
                .linkColor(.text.primary)
                .display(.inlineBlock)
                .margin(horizontal: .auto)
            }
        }
    }
}
