import Foundation
import Dependencies
import EmailAddress

extension Identity.Client: TestDependencyKey {
    public static var testValue: Identity.Client {
        .init(
            authenticate: .testValue,
            logout: { },
            reauthorize: { _ in
                return JWT.Response(
                    accessToken: .init(value: "apikey-access-token", expiresIn: 3600),
                    refreshToken: .init(value: "apikey-refresh-token", expiresIn: 86400)
                )
            },
            create: .testValue,
            delete: .testValue,
            emailChange: .testValue,
            password: .testValue
        )
    }
    
    enum ValidationError: Error {
        case invalidCredentials
    }
}

extension Identity.Client.Create: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { email, password in
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
                guard password.count >= 8 else {
                    throw ValidationError.weakPassword
                }
            },
            verify: { email, token in
                guard !token.isEmpty else {
                    throw ValidationError.invalidToken
                }
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
            }
        )
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case weakPassword
        case invalidToken
    }
}

extension Identity.Client.Password: TestDependencyKey {
    public static var testValue: Self {
        .init(
            reset: .init(
                request: { email in
                    guard email.rawValue.contains("@") else {
                        throw ValidationError.invalidEmail
                    }
                },
                confirm: { token, newPassword in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                    guard newPassword.count >= 8 else {
                        throw ValidationError.weakPassword
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in
                    guard newPassword.count >= 8 else {
                        throw ValidationError.weakPassword
                    }
                    guard currentPassword != newPassword else {
                        throw ValidationError.samePassword
                    }
                }
            )
        )
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case weakPassword
        case samePassword
        case invalidToken
    }
}

extension Identity.Client.EmailChange: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { newEmail in
//                guard let email = newEmail else {
//                    throw ValidationError.emailRequired
//                }
                
                
            },
            confirm: { token in
                guard !token.isEmpty else {
                    throw ValidationError.invalidToken
                }
            }
        )
    }
    
    enum ValidationError: Error {
        case emailRequired
        case invalidEmail
        case invalidToken
    }
}

extension Identity.Client.Delete: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { reauthToken in
                guard !reauthToken.isEmpty else {
                    throw ValidationError.missingToken
                }
            },
            cancel: {
            },
            confirm: {
            }
        )
    }
    
    enum ValidationError: Error {
        case missingToken
        case invalidUserId
    }
}

extension Identity.Client.Authenticate: TestDependencyKey {
    public static var testValue: Self {
        .init(
            credentials: { credentials in
                JWT.Response(
                    accessToken: .init(value: "test-access-token", expiresIn: 3600),
                    refreshToken: .init(value: "test-refresh-token", expiresIn: 86400)
                )
            },
            token: .init(
                access: { token in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                },
                refresh: { token in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                    return JWT.Response(
                        accessToken: .init(value: "refreshed-access-token", expiresIn: 3600),
                        refreshToken: .init(value: "refreshed-refresh-token", expiresIn: 86400)
                    )
                }
            ),
            apiKey: { apiKey in
                guard !apiKey.isEmpty else {
                    throw ValidationError.invalidApiKey
                }
                return JWT.Response(
                    accessToken: .init(value: "apikey-access-token", expiresIn: 3600),
                    refreshToken: .init(value: "apikey-refresh-token", expiresIn: 86400)
                )
            }
        )
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case invalidPassword
        case invalidToken
        case invalidApiKey
    }
}


extension Identity.Client.Authenticate.Multifactor: TestDependencyKey {
   public static var testValue: Self {
       .init(
           setup: .init(
               initialize: { method, identifier in
                   guard !identifier.isEmpty else {
                       throw ValidationError.invalidIdentifier
                   }
                   return .init(
                       secret: "TESTSECRET123",
                       recoveryCodes: ["RECOVERY1", "RECOVERY2", "RECOVERY3"]
                   )
               },
               confirm: { code in
                   guard code.count == 6 else {
                       throw ValidationError.invalidCode
                   }
               },
               resetSecret: { method in
                   "NEWSECRET123"
               }
           ),
           verification: .init(
               createChallenge: { method in
                   .init(
                       id: "challenge-123",
                       method: method,
                       createdAt: .now,
                       expiresAt: .now.addingTimeInterval(300)
                   )
               },
               verify: { challengeId, code in
                   guard !challengeId.isEmpty else {
                       throw ValidationError.invalidChallenge
                   }
                   guard code.count == 6 else {
                       throw ValidationError.invalidCode
                   }
               },
               bypass: { challengeId in
                   guard !challengeId.isEmpty else {
                       throw ValidationError.invalidChallenge
                   }
               }
           ),
           recovery: .init(
               generateNewCodes: {
                   ["NEWCODE1", "NEWCODE2", "NEWCODE3"]
               },
               getRemainingCodeCount: {
                   3
               },
               getUsedCodes: {
                   ["USEDCODE1"]
               }
           ),
           administration: .init(
               forceDisable: {
                   // No validation needed for force disable
               }
           ),
           configuration: {
               .init(
                   methods: [.totp, .sms],
                   status: .enabled,
                   lastVerifiedAt: .now
               )
           },
           disable: {
               // No validation needed for disable
           }
       )
   }
   
   enum ValidationError: Error {
       case invalidIdentifier
       case invalidCode
       case invalidChallenge
   }
}
