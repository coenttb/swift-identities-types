//
//  File.swift
//  coenttb-web
//
//  PasswordResetd by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import CoenttbWebHTML

extension Route.Password.Reset.Request {
    public struct View: HTML {
        let formActionURL: URL
        let homeHref: URL
        let primaryColor: HTMLColor
        
        public init(
            formActionURL: URL,
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.formActionURL = formActionURL
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }
        
        private static let pagemodule_forgot_password_id: String = "pagemodule_forgot_password_id"
        
        public var body: some HTML {
            PageModule(theme: .login) {
                
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Voer uw e-mailadres in en we sturen u een link om uw wachtwoord opnieuw in te stellen.",
                            english: "Enter your email address and we will send you a link to reset your password."
                        )
                    }
                    .fontSize(.secondary)
                    .textAlign(.center)
                    .color(.secondary)
                    
                    form {
                        VStack {
                            Input.default(CoenttbIdentity.API.Password.Reset.Request.CodingKeys.email)
                                .type(.email)
                                .placeholder("Email")
                                .focusOnPageLoad()
                            
                            Button(
                                tag: button,
                                background: self.primaryColor
                            ) {
                                TranslatedString(
                                    dutch: "Reset link versturen",
                                    english: "Send Reset Link"
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
                                href: homeHref.absoluteString
                            )
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .fontSize(.secondary)
                            .textAlign(.center)
                        }
                    }
                    .id("form-forgot-password")
                    .method(.post)
                    .action(self.formActionURL.absoluteString)
                }
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Wachtwoord vergeten",
                        english: "Reset Password"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_forgot_password_id)
            
            script {"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('form-forgot-password');
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
                            const pageModule = document.getElementById("\(Self.pagemodule_forgot_password_id)");
                            pageModule.outerHTML = `\(html: Route.Password.Reset.Request.View.Confirmation(homeHref: self.homeHref, primaryColor: self.primaryColor))`;
                        } else {
                            throw new Error(data.message || '\(TranslatedString(
                                dutch: "Verzoek om wachtwoord te resetten mislukt",
                                english: "Password reset request failed"
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


extension Route.Password.Reset.Request.View {
    struct Confirmation: HTML {
        let homeHref: URL
        let primaryColor: HTMLColor
        
        init(
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }
        
        public var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "We hebben een e-mail verstuurd met instructies om uw wachtwoord opnieuw in te stellen.",
                            english: "We've sent an email with instructions to reset your password."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 1.rem)
                    
                    Paragraph {
                        TranslatedString(
                            dutch: "Als u de e-mail niet binnen enkele minuten ontvangt, controleer dan uw spam-folder.",
                            english: "If you don't receive the email within a few minutes, please check your spam folder."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 2.rem)
                    
                    Link(
                        TranslatedString(
                            dutch: "Terug naar home",
                            english: "Back to Home"
                        ).description,
                        href: homeHref.absoluteString
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

extension Route.Password.Reset.Confirm {
    public struct View: HTML {
        let token: String
        let passwordResetAction: URL
        let homeHref: URL
        let redirect: URL
        let primaryColor: HTMLColor
        
        public init(
            token: String,
            passwordResetAction: URL,
            homeHref: URL,
            redirect: URL,
            primaryColor: HTMLColor
        ) {
            self.token = token
            self.passwordResetAction = passwordResetAction
            self.homeHref = homeHref
            self.redirect = redirect
            self.primaryColor = primaryColor
        }
        
        private static let passwordResetId:String = "password-reset-id"
        
        public var body: some HTML {
            PageModule(theme: .login) {
                
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Vul je nieuwe wachtwoord in.",
                            english: "Enter your new password."
                        )
                    }
                    .fontSize(.secondary)
                    .textAlign(.center)
                    .color(.secondary)
                    
                    form {
                        VStack {
                            
                            Input.default(CoenttbIdentity.API.Password.Reset.Confirm.CodingKeys.newPassword)
                                .type(.password)
                                .placeholder(String.password.capitalizingFirstLetter().description)
                                .focusOnPageLoad()
                            
                            Button(
                                tag: button,
                                background: self.primaryColor
                            ) {
                                String.continue.capitalizingFirstLetter()
                            }
                            .color(.primary.reverse())
                            .type(.submit)
                            .width(100.percent)
                            .justifyContent(.center)
                            
                            Link(
                                TranslatedString(
                                    dutch: "Terug naar de homepagina",
                                    english: "Back to home"
                                ).description,
                                href: homeHref.absoluteString
                            )
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .fontSize(.secondary)
                            .textAlign(.center)
                        }
                    }
                    .id("form-password-reset")
                    .method(.post)
                    .action(self.passwordResetAction.absoluteString)
                }
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    String.reset_your_password.capitalizingFirstLetter()
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.passwordResetId)
            
            script {"""
               document.addEventListener('DOMContentLoaded', function() {
                   const form = document.getElementById("form-password-reset");
                   const formContainer = form;
            
                   form.addEventListener('submit', async function(event) {
                       event.preventDefault();
            
                       const formData = new FormData(form);
                       const password = formData.get('\(CoenttbIdentity.API.Password.Reset.Confirm.CodingKeys.newPassword.rawValue)');
            
                       try {
            
                           const response = await fetch(form.action, {
                               method: form.method,
                               headers: {
                                   'Content-Type': 'application/x-www-form-urlencoded',
                                   'Accept': 'application/json'
                               },
                               body: new URLSearchParams({
                                    \(CoenttbIdentity.API.Password.Reset.Confirm.CodingKeys.token.rawValue): '\(self.token)',
                                    \(CoenttbIdentity.API.Password.Reset.Confirm.CodingKeys.newPassword.rawValue): password
                               }).toString()
                           });
            
                           if (!response.ok) {
                               throw new Error('Network response was not ok');
                           }
            
                           const data = await response.json();
            
            
                           if (data.success) {
                               const pageModule = document.getElementById("\(Self.passwordResetId)");
                               pageModule.outerHTML = `\(html: Route.Password.Reset.Confirm.View.Confirm(redirect: self.redirect, primaryColor: self.primaryColor))`;
                           } else {
                               throw new Error(data.message || '\(TranslatedString(
                                   dutch: "Verzoek om wachtwoord te resetten mislukt",
                                   english: "Password reset request failed"
                               ))');
                           }
            
                       } catch (error) {
                           console.error('Error:', error);
                           const messageDiv = document.createElement('div');
                           messageDiv.textContent = 'Password reset failed. Please try again.';
                           messageDiv.style.color = 'red';
                           messageDiv.style.textAlign = 'center';
                           messageDiv.style.marginTop = '10px';
                           formContainer.appendChild(messageDiv);
                       }
                   });
               });
            """}
        }
    }
}



extension Route.Password.Reset.Confirm.View {
    struct Confirm: HTML {
        let redirect: URL
        let primaryColor: HTMLColor
        
        init(redirect: URL, primaryColor: HTMLColor) {
            self.redirect = redirect
            self.primaryColor = primaryColor
        }
        
        private static let confirmationId: String = "password-reset-confirmation-id"
        
        var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        TranslatedString(
                            dutch: "Je wachtwoord is succesvol gewijzigd.",
                            english: "Your password has been successfully changed."
                        )
                    }
                    .fontSize(.body)
                    .textAlign(.center)
                    .color(.primary)
                    .margin(bottom: .medium)
                    
                    Paragraph {
                        TranslatedString(
                            dutch: "Je wordt nu doorgestuurd naar de inlogpagina.",
                            english: "You will now be redirected to the login page."
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
                        href: redirect.absoluteString
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
                        dutch: "Wachtwoord Reset Voltooid",
                        english: "Password Reset Complete"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.confirmationId)
            
            script {"""
                document.addEventListener('DOMContentLoaded', function() {
                    setTimeout(function() {
                        window.location.href = '\(redirect.absoluteString)';
                    }, 5000); // Redirect after 5 seconds
                });
            """}
        }
    }
}
