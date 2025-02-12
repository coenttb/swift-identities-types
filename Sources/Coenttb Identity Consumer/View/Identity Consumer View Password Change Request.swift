//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Foundation
import Coenttb_Web
import Identity_Consumer

extension Identity.Consumer.View.Password.Change {
    package struct Request: HTML {
        let formActionURL: URL
        let redirectOnSuccess: URL
        let primaryColor: HTMLColor
        
        package  init(
            formActionURL: URL,
            redirectOnSuccess: URL,
            primaryColor: HTMLColor
        ) {
            self.formActionURL = formActionURL
            self.redirectOnSuccess = redirectOnSuccess
            self.primaryColor = primaryColor
        }
        
        private static var pagemodule_change_password_id: String { "pagemodule_change_password_id" }
        
        package  var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Voer uw huidige wachtwoord en uw nieuwe wachtwoord in.",
                            english: "Enter your current password and your new password."
                        )
                    }
                    .fontSize(.secondary)
                    .textAlign(.center)
                    .color(.secondary)
                    
                    form {
                        VStack {
                            Input.default(Identity.Password.Change.Request.CodingKeys.currentPassword)
                                .type(.password)
                                .placeholder(TranslatedString(dutch: "Huidig wachtwoord", english: "Current password").description)
                            
                            Input.default(Identity.Password.Change.Request.CodingKeys.newPassword)
                                .type(.password)
                                .placeholder(TranslatedString(dutch: "Nieuw wachtwoord", english: "New password").description)
                            
                            Button(
                                tag: button,
                                background: self.primaryColor
                            ) {
                                TranslatedString(
                                    dutch: "Wachtwoord wijzigen",
                                    english: "Change Password"
                                )
                            }
                            .color(.primary.reverse())
                            .type(.submit)
                            .width(100.percent)
                            .justifyContent(.center)
                            
                            Link(
                                TranslatedString(
                                    dutch: "Terug naar home",
                                    english: "Back to Home"
                                ).description,
                                href: redirectOnSuccess.relativePath
                            )
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .fontSize(.secondary)
                            .textAlign(.center)
                        }
                    }
                    .id("form-change-password")
                    .method(.post)
                    .action(self.formActionURL.relativePath)
                }
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Wachtwoord wijzigen",
                        english: "Change Password"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_change_password_id)
            
            script {"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('form-change-password');
                form.addEventListener('submit', async function(event) {
                    event.preventDefault();
                    const formData = new FormData(form);
                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams(formData).toString()
                        });
                        const data = await response.json();
                        if (data.success) {
                            const pageModule = document.getElementById("\(Self.pagemodule_change_password_id)");
                            pageModule.outerHTML = `\(html: Identity.Consumer.View.Password.Change.Request.Confirmation(redirectOnSuccess: self.redirectOnSuccess, primaryColor: self.primaryColor))`;
                        } else {
                            throw new Error(data.message || '\(TranslatedString(
                                dutch: "Wachtwoord wijzigen mislukt",
                                english: "Password change failed"
                            ))');
                        }
                    } catch (error) {
                        console.error("Error occurred:", error);
                        alert('\(TranslatedString(
                            dutch: "Er is een fout opgetreden. Probeer het later opnieuw.",
                            english: "An error occurred. Please try again later."
                        ))');
                    }
                });
            });
            """}
        }
    }
}

extension Identity.Consumer.View.Password.Change.Request {
    package struct Confirmation: HTML {
        package let redirectOnSuccess: URL
        package let primaryColor: HTMLColor
        
        package init(
            redirectOnSuccess: URL,
            primaryColor: HTMLColor
        ) {
            self.redirectOnSuccess = redirectOnSuccess
            self.primaryColor = primaryColor
        }
        
        package  var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Uw wachtwoord is succesvol gewijzigd.",
                            english: "Your password has been successfully changed."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 1.rem)
                    
                    Paragraph {
                        TranslatedString(
                            dutch: "U kunt nu inloggen met uw nieuwe wachtwoord.",
                            english: "You can now log in with your new password."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 2.rem)
                    
                    Link(
                        TranslatedString(
                            dutch: "Terug naar home",
                            english: "Back to Home"
                        ).description,
                        href: redirectOnSuccess.relativePath
                    )
                    .linkColor(self.primaryColor)
                }
                .textAlign(.center)
                .alignItems(.center)
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Wachtwoord gewijzigd",
                        english: "Password Changed"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
        }
    }
}
