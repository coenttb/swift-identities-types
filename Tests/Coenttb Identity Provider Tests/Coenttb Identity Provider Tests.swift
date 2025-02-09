//  Coenttb_Identity_Provider_Fluent Tests.swift

import Foundation
import Coenttb_Web
import Coenttb_Identity_Provider
import DependenciesTestSupport
import Testing
import Mailgun

@Suite(
    "Coenttb_Identity_Provider_Fluent Creation Tests"
//    .dependency(\.application, ApplicationKey.testValue)
)
struct EmailTests {
    // MARK: - Account Creation Tests
    
    @Test("Creating email with html should render")
    func test1() async throws {
        let email = Email.requestEmailVerification(
            verificationUrl: .homeDirectory,
            businessName: "Test",
            supportEmail: try! .init("test@test.com"),
            from: try! .init("test@test.com"),
            to: ("hello", try! .init("test@test.com")),
            primaryColor: .red
        )
        
        print(email.html)
        
        
    }
}
