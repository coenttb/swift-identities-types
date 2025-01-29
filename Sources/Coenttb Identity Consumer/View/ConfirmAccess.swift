//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import Coenttb_Web
import Identity_Consumer

public struct ConfirmAccess<CodingKey: RawRepresentable>: HTML where CodingKey.RawValue == String {
    let codingKey: CodingKey
    let currentUserName: String
    let primaryColor: HTMLColor
    let passwordResetHref: URL
    let confirmFormAction: URL
    let redirectOnSuccess: URL

    public init(
        codingKey: CodingKey = Identity_Shared.EmailChange.Reauthorization.CodingKeys.password,
        currentUserName: String,
        primaryColor: HTMLColor,
        passwordResetHref: URL,
        confirmFormAction: URL,
        redirectOnSuccess: URL
    ) {
        self.codingKey = codingKey
        self.currentUserName = currentUserName
        self.primaryColor = primaryColor
        self.passwordResetHref = passwordResetHref
        self.confirmFormAction = confirmFormAction
        self.redirectOnSuccess = redirectOnSuccess
    }
    
    public var body: some HTML {
            
            PageModule(theme: .confirmAccess) {
                VStack {
                    HTMLGroup {
                        HTMLMarkdown { """
                          \(
                              TranslatedString(
                                  dutch: "Ingelogd als",
                                  english: "Signed in as"
                              )
                          )
                        **\(currentUserName)**.
                        """ }
                    
                        form {
                            VStack {
                                Input.default(self.codingKey)
                                    .type(.password)
                                    .placeholder(String.password.capitalizingFirstLetter().description)
                                
                                Link(href: passwordResetHref.absoluteString)    {
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
                                    
//                                    div {
//                                        HTMLMarkdown {"""
//                                        **Tip:** You are entering sudo mode. After you've performed a sudo-protected action, you'll only be asked to re-authenticate again after a few hours of inactivity.
//                                        """}
//                                        .linkColor(primaryColor)
//                                    }
//                                    .fontSize(.secondary)
//                                    .textAlign(.center)
                                }
                                .flexContainer(
                                    justification: .center,
                                    itemAlignment: .center,
                                    media: .desktop
                                )
                            }
                        }
                        .id("form-confirm-access")
                        .method(.post)
                        .action(confirmFormAction.absoluteString)
                        .width(100.percent)
                        .maxWidth(20.rem)
                        .maxWidth(24.rem, media: .mobile)
                        .margin(horizontal: .auto)
                    }
                    .width(100.percent)
                    .maxWidth(20.rem)
                    .maxWidth(24.rem, media: .mobile)
                    .margin(horizontal: .auto)
                    
                    
                }
                .width(100.percent)
                
                
            } title: {
                Header(3) {
                    String.confirm_access.capitalizingFirstLetter()
                }
            }
            
            script {"""
               document.addEventListener('DOMContentLoaded', function() {
                   const form = document.getElementById("form-confirm-access"); 
                   const formContainer = form;  
            
                   form.addEventListener('submit', async function(event) {
                       event.preventDefault();  
                       const formData = new FormData(form);
                       const password = formData.get('\(Identity_Shared.Login.CodingKeys.password.rawValue)'); 
            
                       try {
                           
                           const response = await fetch(form.action, {
                               method: form.method, 
                               headers: {
                                   'Content-Type': 'application/x-www-form-urlencoded',  
                                   'Accept': 'application/json'  
                               },
                               body: new URLSearchParams({
                                    \(Identity_Shared.Login.CodingKeys.password.rawValue): password
                               }).toString()  
                           });
            
                           if (!response.ok) {
                               throw new Error('Network response was not ok');
                           }
            
                           const data = await response.json();
            
                           if (data.success) {
                               window.location.href = "\(redirectOnSuccess.absoluteString)";  
                           } else {
                               throw new Error(data.message || 'Confirmation failed');
                           }
            
                       } catch (error) {
                           console.error('Error:', error);
                           const messageDiv = document.createElement('div');
                           messageDiv.textContent = 'Login failed. Please try again.';
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


extension PageModule.Theme {
    static var confirmAccess: Self {
        login
    }
}

#if canImport(SwiftUI)
import SwiftUI

@MainActor let confirmAccess: some HTML = ConfirmAccess(
    codingKey: Identity_Shared.Create.Request.CodingKeys.password,
    currentUserName: "Coen ten Thije Boonkkamp",
    primaryColor: .red,
    passwordResetHref: .desktopDirectory,
    confirmFormAction: .desktopDirectory,
    redirectOnSuccess: .desktopDirectory
)

#Preview {
    HTMLPreview.modern {
        confirmAccess
    }
}

#endif
