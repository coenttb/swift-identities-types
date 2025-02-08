// Coenttb_Identity_Provider_Fluent Tests extensions.swift

import Foundation
import Coenttb_Web
import Coenttb_Vapor
import Identity_Provider_Fluent
import FluentSQLiteDriver

enum ApplicationKey: TestDependencyKey {
    static var testValue: Application {
        let app = Application(.testing)
        
        app.databases.use(.sqlite(.memory), as: .sqlite, isDefault: true)
            
        app.migrations.add(Identity.Migration.Create())
        app.migrations.add(Identity.Token.Migration())
        app.migrations.add(EmailChangeRequest.Migration())
        app.migrations.add(TestDatabaseUser.Migration())
            
        try! app.autoMigrate().wait()
            
        return app
    }
}

extension DependencyValues {
    var application: Application {
        get { self[ApplicationKey.self] }
        set { self[ApplicationKey.self] = newValue }
    }
}

private enum RequestKey: DependencyKey {
    static var testValue: Request {
        @Dependency(\.application) var app
        let req = Request(application: app, on: app.eventLoopGroup.next())
        // Set up session
//        req.session = Session(storage: app.sessions.driver)
        return req
    }
    
    static let liveValue = testValue
}

extension DependencyValues {
    var request: Request {
        get { self[RequestKey.self] }
        set { self[RequestKey.self] = newValue }
    }
}

extension Coenttb_Identity.Client<TestUser> {
    static func makeTest(
        currentUserId: UUID? = nil,
        currentUserEmail: EmailAddress? = nil
    ) -> Self {
        @Dependency(\.application) var app
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        return .live(
            database: app.db,
            logger: app.logger,
            getDatabaseUser: (
                byUserId: { userId in try await TestDatabaseUser.find(userId, on: app.db) },
                byIdentityId: { identityId in
                    try await TestDatabaseUser.query(on: app.db)
                        .filter(\.$identity.$id == identityId)
                        .first()
                }
            ),
            userInit: { identity, dbUser in
                guard let id = dbUser.id else {
                    fatalError("Database user missing ID")
                }
                return TestUser(id: id, email: identity.email)
            },
            userUpdate: { _, _, _ in },
            createDatabaseUser: { identityId in
                let user = TestDatabaseUser()
                user.$identity.id = identityId
                return user
            },
            currentUserId: { currentUserId },
            currentUserEmail: { currentUserEmail },
            request: { request },
            sendVerificationEmail: { _, _ in },
            authenticate: { identity in request.auth.login(identity) },
            isAuthenticated: { request.auth.has(Identity.self) },
            logout: { request.auth.logout(Identity.self) },
            isValidEmail: { _ in true },
            isValidPassword: { _ in true },
            sendPasswordResetEmail: { _, _ in },
            sendPasswordChangeNotification: { _ in },
            sendEmailChangeConfirmation: { _, _, _ in },
            sendEmailChangeRequestNotification: { _, _ in },
            onEmailChangeSuccess: { _, _ in }
        )
    }
    
    static var liveTest: Self {
        makeTest()
    }
}
