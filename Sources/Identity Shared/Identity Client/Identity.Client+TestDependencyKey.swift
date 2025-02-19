import Dependencies
import EmailAddress
import Foundation

extension Identity.Client: TestDependencyKey {
    public static var testValue: Identity.Client {
        .init(
            authenticate: .testValue,
            logout: { },
            reauthorize: { _ in return .init(value: "test", expiresIn: 1000) },
            create: .testValue,
            delete: .testValue,
            email: .testValue,
            password: .testValue
        )
    }
}

extension Identity.Client.Create: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { email, password in
                
            },
            verify: { email, token in
                _ = try EmailAddress(email)
            }
        )
    }
}

extension Identity.Client.Password: TestDependencyKey {
    public static var testValue: Self {
        .init(
            reset: .init(
                request: { email in
                    _ = try EmailAddress(email)
                },
                confirm: { token, newPassword in

                }
            ),
            change: .init(
                request: { currentPassword, newPassword in

                }
            )
        )
    }
}



extension Identity.Client.Email.Change: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { _ in
                return .success
            },
            confirm: { token in
                return .testValue
            }
        )
    }
}

extension Identity.Client.Delete: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { reauthToken in
                
            },
            cancel: {
                
            },
            confirm: {
            }
        )
    }
}

extension Identity.Client.Authenticate: TestDependencyKey {
    public static var testValue: Self {
        .init(
            credentials: { _, _ in
                    .testValue
            },
            token: .init(
                access: { token in
                    
                },
                refresh: { token in
                    .testValue
                }
            ),
            apiKey: { apiKey in
                    .testValue
            }
        )
    }
}

