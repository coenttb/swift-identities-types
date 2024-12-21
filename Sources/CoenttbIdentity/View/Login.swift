//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import Languages
import CoenttbWebHTML


public struct Login: HTML {
    let primaryColor: HTMLColor
    let passwordResetHref: URL
    let accountCreateHref: URL
    let loginFormAction: URL
    
    public init(
        primaryColor: HTMLColor,
        passwordResetHref: URL,
        accountCreateHref: URL,
        loginFormAction: URL
    ) {
        self.primaryColor = primaryColor
        self.passwordResetHref = passwordResetHref
        self.accountCreateHref = accountCreateHref
        self.loginFormAction = loginFormAction
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
    
    public var body: some HTML {
        
        PageModule(theme: .login) {
            form {
                VStack {
                    Input.default(CoenttbIdentity.API.Login.CodingKeys.email)
                        .type(.email)
                        .placeholder(String.email.capitalizingFirstLetter().description)
                        .focusOnPageLoad()
                    
                    Input.default(CoenttbIdentity.API.Login.CodingKeys.password)
                        .type(.password)
                        .placeholder(String.password.capitalizingFirstLetter().description)
                    
                    Link(href: passwordResetHref.absoluteString) {
                        String.forgot_password.capitalizingFirstLetter().questionmark
                    }
                    .linkColor(primaryColor)
                    .fontSize(.secondary)
                    .display(.inlineBlock)
                    
                    VStack {
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
                            HTMLText("\(String.dont_have_an_account.capitalizingFirstLetter().questionmark) ")
                            Link(href: accountCreateHref.absoluteString) {
                                String.signup.capitalizingFirstLetter()
                            }
                            .linkColor(primaryColor)
                        }
                        .fontSize(.secondary)
                    }
                    .flexContainer(
                        justification: .center,
                        itemAlignment: .center,
                        media: .desktop
                    )
                }
            }
            .id(Self.form_id)
            .method(.post)
            .action(loginFormAction.absoluteString)
            .width(100.percent)
            .maxWidth(20.rem)
            .maxWidth(24.rem, media: .mobile)
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
                const email = formData.get('\#(CoenttbIdentity.API.Login.CodingKeys.email.rawValue)');      
                const password = formData.get('\#(CoenttbIdentity.API.Login.CodingKeys.password.rawValue)'); 
            
                try {
                    const response = await fetch(form.action, {
                        method: form.method, 
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',  
                            'Accept': 'application/json'  
                        },
                        body: new URLSearchParams({
                             \#(CoenttbIdentity.API.Login.CodingKeys.email.rawValue): email,      
                             \#(CoenttbIdentity.API.Login.CodingKeys.password.rawValue): password
                        }).toString()  
                    });
            
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
            
                    const data = await response.json();
            
                    
                    if (data.success) {
                        window.location.href = "/";  
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


extension PageModule.Theme {
    static var login: Self {
        Self(
            topMargin: 10.rem,
            bottomMargin: 4.rem,
            leftRightMargin: 2.rem,
            leftRightMarginDesktop: 3.rem,
            itemAlignment: .center
        )
    }
}
