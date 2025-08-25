//
//  Identity.Backend.configure.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import Boiler
import Records
import Dependencies
import Logging
import Vapor

extension Identity.Backend {
    /// Configures a Vapor application as an Identity backend/provider.
    ///
    /// This function sets up middleware and routes for an Identity provider server.
    /// The database should already be configured by the application before calling this.
    ///
    /// - Parameter application: The Vapor application to configure
    /// - Throws: Any errors during configuration
    public static func configure(
        _ application: Vapor.Application,
        manageDatabaseLifeCycle: Bool
    ) async throws {
        @Dependency(\.logger) var logger
        @Dependency(\.defaultDatabase) var database
        
        logger.info("Configuring Identity Backend", metadata: [
            "component": "Identity.Backend",
            "operation": "configure"
        ])
        
        // Run Identity migrations
        logger.debug("Running Identity database migrations", metadata: [
            "component": "Identity.Backend",
            "operation": "database.migrate"
        ])
        
        let migrator = Identity.Backend.migrator()
        try await migrator.migrate(database)
        
        logger.debug("Identity database initialized", metadata: [
            "component": "Identity.Backend",
            "operation": "database.init.success"
        ])
        
        if manageDatabaseLifeCycle {
            application.lifecycle.use(DatabaseLifecycleHandler())
        }
        
        logger.debug("Database lifecycle handler registered", metadata: [
            "component": "Identity.Backend",
            "operation": "lifecycle.registered"
        ])
        
        // Note: Backend doesn't add any middleware here as it's purely API-based
        // The consuming application should add appropriate API authentication middleware
        // based on their specific requirements (JWT, API keys, etc.)
        
        logger.info("Identity Backend configuration complete", metadata: [
            "component": "Identity.Backend",
            "operation": "configure.success"
        ])
    }
}
