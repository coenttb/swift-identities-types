//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Coenttb_Web
import Foundation
import Identities

extension Identity.Consumer.View.Authenticate {
    package typealias Login = Credentials
    package struct Credentials: HTML {
        let primaryColor: HTMLColor
        let passwordResetHref: URL
        let accountCreateHref: URL
        let loginFormAction: URL
        let loginSuccessRedirect: URL

        package init(
            primaryColor: HTMLColor,
            passwordResetHref: URL,
            accountCreateHref: URL,
            loginFormAction: URL,
            loginSuccessRedirect: URL
        ) {
            self.primaryColor = primaryColor
            self.passwordResetHref = passwordResetHref
            self.accountCreateHref = accountCreateHref
            self.loginFormAction = loginFormAction
            self.loginSuccessRedirect = loginSuccessRedirect
        }

        private static let form_id: String = "login-form-id"

        static func handleError(container: String, message: String) -> String {
            #"""
            console.error('Error:', error);
            const messageDiv = document.createElement('div');
            messageDiv.textContent = '\#(message)';
            messageDiv.style.color = 'red';
            messageDiv.style.textAlign = 'center';
            messageDiv.style.marginTop = '10px';
            \#(container).appendChild(messageDiv);
            """#
        }

        package var body: some HTML {

            PageModule(theme: .login) {
                form(
                    action: .init(loginFormAction.relativePath),
                    method: .post
                ) {
                    VStack {
                        Input(
                            codingKey: Identity.Authentication.Credentials.CodingKeys.username,
                            type: .email(
                                .init(
//                                    value: <#T##Value<String>?#>,
//                                    maxlength: <#T##Maxlength?#>,
//                                    minlength: <#T##Minlength?#>,
//                                    required: <#T##Required?#>,
//                                    multiple: <#T##Multiple?#>,
//                                    pattern: <#T##Pattern?#>,
                                    placeholder: .init(String.email.capitalizingFirstLetter().description),
//                                    readonly: <#T##Readonly?#>,
//                                    size: <#T##Size?#>
                                )
                            )
                        )
                        .focusOnPageLoad()
                        
                        Input(
                            codingKey: Identity.Authentication.Credentials.CodingKeys.password,
                            type: .password(
                                .init(
//                                    value: <#T##Value<String>?#>,
//                                    maxlength: <#T##Maxlength?#>,
//                                    minlength: <#T##Minlength?#>,
//                                    pattern: <#T##Pattern?#>,
                                    placeholder: .init(String.password.capitalizingFirstLetter().description),
//                                    readonly: <#T##Readonly?#>,
//                                    size: <#T##Size?#>,
//                                    autocomplete: <#T##Autocomplete?#>,
//                                    required: <#T##Required?#>
                                )
                            )
                        )
                        
//                        Input.default(Identity.Authentication.Credentials.CodingKeys.username)
//                            .type(.email)
//                            .placeholder(String.email.capitalizingFirstLetter().description)
//                            .focusOnPageLoad()

//                        Input.default(Identity.Authentication.Credentials.CodingKeys.password)
//                            .type(.password)
//                            .placeholder(String.password.capitalizingFirstLetter().description)

                        Link(href: .init(passwordResetHref.relativePath)) {
                            String.forgot_password.capitalizingFirstLetter().questionmark
                        }
                        .linkColor(primaryColor)
                        .font(.body(.small))
                        .display(.inlineBlock)

                        VStack {
                            Button(
//                                tag: button,
                                button: .init(
                                    type: .submit
                                ),
                                background: primaryColor
                            ) {
                                String.continue.capitalizingFirstLetter()
                            }
                            .color(.text.primary.reverse())
                            .width(.percent(100))
                            .justifyContent(.center)

                            div {
                                HTMLText("\(String.dont_have_an_account.capitalizingFirstLetter().questionmark) ")
                                Link(href: .init(accountCreateHref.relativePath)) {
                                    String.signup.capitalizingFirstLetter()
                                }
                                .linkColor(primaryColor)
                            }
                            .font(.body(.small))
                        }
                        .flexContainer(
                            justification: .center,
                            itemAlignment: .center,
                            media: .desktop
                        )
                    }
                }
                .id(Self.form_id)
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    String.welcome_back.capitalizingFirstLetter()
                }
            }

            script {#"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById("\#(Self.form_id)");

                form.addEventListener('submit', async function(event) {
                    event.preventDefault();

                    const formData = new FormData(form);
                    const email = formData.get('\#(Identity.Authentication.Credentials.CodingKeys.username.rawValue)');
                    const password = formData.get('\#(Identity.Authentication.Credentials.CodingKeys.password.rawValue)');

                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams({
                                 \#(Identity.Authentication.Credentials.CodingKeys.username.rawValue): email,
                                 \#(Identity.Authentication.Credentials.CodingKeys.password.rawValue): password
                            }).toString()
                        });

                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }

                        const data = await response.json();


                        if (data.success) {
                            window.location.href = "\#(loginSuccessRedirect.absoluteString)";
                        } else {
                            throw new Error(data.message || 'Login failed');
                        }

                    } catch (error) {
                        console.error('Error:', error);
                        const messageDiv = document.createElement('div');
                        messageDiv.textContent = 'Login failed. Please try again.';
                        messageDiv.style.color = 'red';
                        messageDiv.style.textAlign = 'center';
                        messageDiv.style.marginTop = '10px';
                        form.appendChild(messageDiv);
                    }
                });
            });
            """#}

        }
    }
}

extension PageModule.Theme {
    static var login: Self {
        Self(
            topMargin: .rem(10),
            bottomMargin: .rem(4),
            leftRightMargin: .rem(2),
            leftRightMarginDesktop: .rem(3),
            itemAlignment: .center
        )
    }
}
