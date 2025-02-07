//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Foundation
import Coenttb_Web
import Identity_Consumer

extension Identity.Consumer.View.EmailChange.Confirm {
    public struct View: HTML {
        let redirect: URL
        let primaryColor: HTMLColor
        
        public init(
            redirect: URL,
            primaryColor: HTMLColor
        ) {
            self.redirect = redirect
            self.primaryColor = primaryColor
        }
        
        private static var confirmationId: String { "email-change-confirmation-id" }
        
        public var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Je e-mailadres is succesvol gewijzigd.",
                            english: "Your email address has been successfully changed."
                        )
                    }
                    .fontSize(.body)
                    .textAlign(.center)
                    .color(.primary)
                    .margin(bottom: .medium)
                    
                    Paragraph {
                        TranslatedString(
                            dutch: "Je wordt nu doorgestuurd naar je account pagina.",
                            english: "You will now be redirected to your account page."
                        )
                    }
                    .fontSize(.secondary)
                    .textAlign(.center)
                    .color(.secondary)
                    .margin(bottom: .large)
                    
                    Link(
                        TranslatedString(
                            dutch: "Klik hier als je niet automatisch wordt doorgestuurd",
                            english: "Click here if you are not automatically redirected"
                        ).description,
                        href: redirect.relativePath
                    )
                    .linkColor(self.primaryColor)
                    .fontWeight(.medium)
                    .fontSize(.secondary)
                    .textAlign(.center)
                }
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "E-mailadres Wijziging Voltooid",
                        english: "Email Change Complete"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.confirmationId)
            
            script {"""
                document.addEventListener('DOMContentLoaded', function() {
                    setTimeout(function() {
                        window.location.href = '\(redirect.relativePath)';
                    }, 5000); // Redirect after 5 seconds
                });
            """}
        }
    }
}
