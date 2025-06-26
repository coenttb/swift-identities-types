//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 10/10/2024.
//

import Coenttb_Web
import Foundation
import Identities

extension Identity.Consumer.View.Email.Change {
    package struct Request: HTML {
        let formActionURL: URL
        let homeHref: URL
        let primaryColor: HTMLColor
        
        package init(
            formActionURL: URL,
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.formActionURL = formActionURL
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }
        
        private static var pagemodule_request_email_change_id: String { "pagemodule_request_email_change_id" }
        private static var form_id: String { "form-request-email-change" }
        
        package var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Voer uw nieuwe e-mailadres in. We sturen een email naar beide e-mailadressen.",
                            english: "Enter your new email address. We'll send an email to both email addresses."
                        )
                    }
                    .font(.body(.small))
                    .textAlign(.center)
                    .color(.text.secondary)
                    
                    form(
                        action: .init(self.formActionURL.relativePath),
                        method: .post
                    ) {
                        VStack {
                            Input(
                                codingKey: Identity.Email.Change.Request.CodingKeys.newEmail,
                                type: .email(
                                    .init(
                                        placeholder: .init(value: "New Email")
                                    )
                                )
                            )
                            .focusOnPageLoad()
                            
                            Button(
                                //                                tag: button,
                                button: .init(type: .submit),
                                background: self.primaryColor
                            ) {
                                TranslatedString(
                                    dutch: "Verzoek indienen",
                                    english: "Submit Request"
                                )
                            }
                            .color(.text.primary.reverse())
                            .width(.percent(100))
                            .justifyContent(.center)
                            
                            Link(
                                TranslatedString(
                                    dutch: "Terug naar home",
                                    english: "Back to Home"
                                ).description,
                                href: .init(homeHref.relativePath)
                            )
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .font(.body(.small))
                            .textAlign(.center)
                        }
                    }
                    .id(Self.form_id)
                }
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "E-mailadres wijzigen",
                        english: "Change Email Address"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_request_email_change_id)
            
            script {#"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('\#(Self.form_id)');
                const errorContainer = document.createElement('div');
                errorContainer.id = 'error-container';
                errorContainer.style.color = 'red';
                errorContainer.style.marginTop = '10px';
                errorContainer.style.display = 'none';
                form.appendChild(errorContainer);
            
                form.addEventListener('submit', async function(event) {
                    event.preventDefault();
                    errorContainer.style.display = 'none';
                    errorContainer.textContent = '';
            
                    const formData = new FormData(form);
                    const newEmail = formData.get('\#(Identity.Email.Change.Request.CodingKeys.newEmail.rawValue)');
            
                    const emailRegex = new RegExp("\#(String.emailRegularExpression)", "i");
            
                    if (!emailRegex.test(newEmail)) {
                        displayError('\#(TranslatedString(
                            dutch: "Voer een geldig e-mailadres in.",
                            english: "Please enter a valid email address."
                        ))');
                        return;
                    }
            
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
                            const pageModule = document.getElementById("\#(Self.pagemodule_request_email_change_id)");
                            pageModule.outerHTML = `\#(html: Identity.Consumer.View.Email.Change.Request.ReceiptConfirmation(homeHref: self.homeHref, primaryColor: self.primaryColor))`;
                        } else {
                            throw new Error(data.reason || '\#(TranslatedString(
                                dutch: "Verzoek om e-mailadres te wijzigen mislukt",
                                english: "Email change request failed"
                            ))');
                        }
                    } catch (error) {
                        console.error("Error occurred:", error);
                        displayError(error.message);
                    }
                });
            
                function displayError(message) {
                    errorContainer.textContent = message;
                    errorContainer.style.display = 'block';
                }
            });
            """#}
        }
    }
}

//
//                        if (!response.ok) {
//                            throw new Error(data.reason || '\#(TranslatedString(
//                                dutch: "Verzoek om e-mailadres te wijzigen mislukt",
//                                english: "Email change request failed"
//                            ))');
//                        }

extension Identity.Consumer.View.Email.Change.Request {
    package struct ReceiptConfirmation: HTML {
        let homeHref: URL
        let primaryColor: HTMLColor
        
        package init(
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }
        
        package var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "We hebben een bevestigingsmail gestuurd naar beide e-mailadressen.",
                            english: "We've sent a confirmation email to both email addresses."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: .rem(1))
                    
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Volg de instructies in de e-mails om de wijziging te voltooien.",
                            english: "Follow the instructions in the emails to complete the change."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: .rem(2))
                    
                    Link(
                        TranslatedString(
                            dutch: "Terug naar home",
                            english: "Back to Home"
                        ).description,
                        href: .init(homeHref.relativePath)
                    )
                    .linkColor(self.primaryColor)
                }
                .textAlign(.center)
                .alignItems(.center)
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Verzoek ontvangen",
                        english: "Request Received"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
        }
    }
}
