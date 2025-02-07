//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import Coenttb_Web
import Identity_Consumer

extension Identity.Consumer.View.Create {
    package enum View: HTML {
        case request(Identity.Create.Request.View)
        case requestReceivedConfirmationPage(Identity.Create.RequestReceivedConfirmationPage)
        case verify(Identity.Create.Verify.View)
        
        package var body: some HTML {
            switch self {
            case .request(let request):
                request
            case .requestReceivedConfirmationPage(let requestReceivedConfirmationPage):
                requestReceivedConfirmationPage
            case .verify(let verify):
                verify
            }
        }
    }
}

extension Identity.Create.Request {
    package struct View: HTML {
        
        let primaryColor: HTMLColor
        let loginHref: URL
        let accountCreateHref: URL
        let createFormAction: URL
        
        package init(
            primaryColor: HTMLColor,
            loginHref: URL,
            accountCreateHref: URL,
            createFormAction: URL
        ) {
            self.primaryColor = primaryColor
            self.loginHref = loginHref
            self.accountCreateHref = accountCreateHref
            self.createFormAction = createFormAction
        }
        
        private static let pagemodule_create_identity: String = "pagemodule-create-identity"
        
        package var body: some HTML {
            PageModule(theme: .login) {
                form {
                    VStack {
                        Input.default(Identity.Create.Request.CodingKeys.email)
                            .type(.email)
                            .placeholder(String.email.description)
                            .focusOnPageLoad()
                        
                        Input.default(Identity.Create.Request.CodingKeys.password)
                            .type(.password)
                            .placeholder(String.password.description)
                        
                        Button(
                            tag: button,
                            background: primaryColor
                        ) {
                            String.continue.capitalizingFirstLetter()
                        }
                        .color(.primary.reverse())
                        .type(.submit)
                        .width(100.percent)
                        .justifyContent(.center)
                        
                        div {
                            HTMLText("\(String.already_have_an_account.capitalizingFirstLetter().questionmark) ")
                            Link(href: loginHref.relativePath) {
                                String.login.capitalizingFirstLetter()
                            }
                            .linkColor(primaryColor)
                        }
                        .fontSize(.secondary)
                        .textAlign(.center)
                    }
                }
                .id("form-create-identity")
                .method(.post)
                .action(createFormAction.relativePath)
                .width(100.percent)
                .maxWidth(20.rem, media: .desktop)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    String.create_your_account.capitalizingFirstLetter()
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_create_identity)
            
            script {"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById("form-create-identity");
                
                form.addEventListener('submit', async function(event) {
                    event.preventDefault();
                    
                    const formData = new FormData(form);
                    const email = formData.get('\(Identity.Create.Request.CodingKeys.email.rawValue)');
                    const password = formData.get('\(Identity.Create.Request.CodingKeys.password.rawValue)');
                    
                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams({
                                 \(Identity.Create.Request.CodingKeys.email.rawValue): email,
                                 \(Identity.Create.Request.CodingKeys.password.rawValue): password
                            }).toString()
                        });
                        
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        
                        const data = await response.json();
                        
                        if (data.success) {
                            const pageModule = document.getElementById("\(Self.pagemodule_create_identity)");
                            pageModule.outerHTML = "\(html: Identity.Create.RequestReceivedConfirmationPage(primaryColor: primaryColor, loginHref: loginHref))";
                        } else {
                            throw new Error(data.message || 'Account creation failed');
                        }
                    } catch (error) {
                        console.error('Error:', error);
                        const messageDiv = document.createElement('div');
                        messageDiv.textContent = 'Account creation failed. Please try again.';
                        messageDiv.style.color = 'red';
                        messageDiv.style.textAlign = 'center';
                        messageDiv.style.marginTop = '10px';
                        form.appendChild(messageDiv);
                    }
                });
            });
            """}
        }
    }
}

extension Identity.Create {
    package struct RequestReceivedConfirmationPage: HTML {
        
        let primaryColor: HTMLColor
        let loginHref: URL
        
        package init(
            primaryColor: HTMLColor,
            loginHref: URL
        ) {
            self.primaryColor = primaryColor
            self.loginHref = loginHref
        }
        
        package var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    Paragraph {
                        [
                            String.your_account_creation_request_has_been_received,
                            String.please_check_your_email_to_complete_the_process
                        ]
                            .map(\.period)
                            .map { $0.capitalizingFirstLetter() }
                            .joined(separator: " ")
                        
                    }
                    .textAlign(.center)
                    .margin(bottom: 2.rem)
                    
                    //                div {
                    //                    HTMLText("\(String.already_have_an_account.capitalizingFirstLetter().questionmark) ")
                    //                    Link(href: loginHref.relativePath) {
                    //                        String.login.capitalizingFirstLetter()
                    //                    }
                    //                    .linkColor(primaryColor)
                    //                }
                    //                .fontSize(.secondary)
                    //                .textAlign(.center)
                }
                .width(100.percent)
                .maxWidth(20.rem, media: .desktop)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    "Account Request Confirmation"
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
        }
    }
}

extension Identity.Create.Verify {
    package struct View: HTML {
        let verificationAction: URL
        let redirectURL: URL
        
        package init(
            verificationAction: URL,
            redirectURL: URL
        ) {
            self.verificationAction = verificationAction
            self.redirectURL = redirectURL
        }
        
        private static let pagemodule_verify_id: String = "pagemodule_verify_id"
        
        package var body: some HTML {
            PageModule(theme: .login) {
                VStack(alignment: .center) {
                    div()
                        .id("spinner")
                    h2 { "message" }
                        .id("message")
                }
                .textAlign(.center)
                .alignItems(.center)
                .textAlign(.start, media: .mobile)
                .alignItems(.leading, media: .mobile)
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
                
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Verificatie in uitvoering...",
                        english: "Verification in Progress..."
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_verify_id)
            
            script {"""
                document.addEventListener('DOMContentLoaded', function() {
                    const urlParams = new URLSearchParams(window.location.search);
                    const token = urlParams.get('token');
                    const email = urlParams.get('email');
                    
                    if (token && email) {
                        verifyEmail(token, email); // Pass both token and email to the function
                    } else {
                        showMessage('Error: No verification token or email found.', false);
                    }
                });
            
                async function verifyEmail(token, email) {
                    try {
                        // Create a URL object from the verificationAction
                        const url = new URL('\(verificationAction.relativePath)');
                        
                        // Update or add the token and email parameters
                        url.searchParams.set('token', token);
                        url.searchParams.set('email', email);
            
                        const response = await fetch(url.toString(), {
                            method: 'POST'
                        });
                        const data = await response.json();
                        
                       
                        if (data.success) {
                            const pageModule = document.getElementById("\(Self.pagemodule_verify_id)");
                            pageModule.outerHTML = "\(html: Identity.Create.VerifyConfirmationPage(redirectURL: redirectURL))";
                            setTimeout(() => { window.location.href = '\(redirectURL.relativePath)'; }, 5000);

                        } else {
                            throw new Error(data.message || 'Account creation failed');
                        }
                    } catch (error) {
                        console.error("Error occurred:", error);
                        showMessage('An error occurred during verification. Please try again later.', false);
                    }
                }
            
                function showMessage(message, isSuccess) {
                    const messageElement = document.getElementById('message');
                    const spinnerElement = document.getElementById('spinner');
                    messageElement.textContent = message;
                    messageElement.className = isSuccess ? 'success' : 'error';
                    spinnerElement.style.display = 'none';
                }
            """}
        }
    }
}

extension Identity.Create {
    package struct VerifyConfirmationPage: HTML {
        let redirectURL: URL
        
        package init(redirectURL: URL) {
            self.redirectURL = redirectURL
        }
        
        package var body: some HTML {
            PageModule(theme: .login) {
                VStack(alignment: .center) {
                    Paragraph {
                        TranslatedString(
                            dutch: "Uw account is succesvol geverifieerd!",
                            english: "Your account has been successfully verified!"
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 1.rem)
                    
                    Paragraph {
                        TranslatedString(
                            dutch: "U wordt over 5 seconden doorgestuurd naar de inlogpagina.",
                            english: "You will be redirected to the login page in 5 seconds."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: 2.rem)
                    
                    Link(href: redirectURL.relativePath) {
                        TranslatedString(
                            dutch: "Klik hier als u niet automatisch wordt doorgestuurd",
                            english: "Click here if you are not redirected automatically"
                        )
                    }
                    .linkColor(.primary)
                }
                .textAlign(.center)
                .alignItems(.center)
                .width(100.percent)
                .maxWidth(20.rem)
                .maxWidth(24.rem, media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    "Account Verified"
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
        }
    }
    
}


