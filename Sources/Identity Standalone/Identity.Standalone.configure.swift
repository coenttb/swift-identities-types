//
//  Identity.Standalone.configure.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import Boiler
import Records
import Identity_Backend
import Dependencies
import Logging
import Vapor

extension Identity.Standalone {
    /// Configures a Vapor application for standalone Identity deployment.
    ///
    /// This function sets up authentication middleware for Identity.
    /// The database should already be configured by the application before calling this.
    /// Migrations can be run separately using Identity.Database.migrate().
    ///
    /// - Parameters:
    ///   - application: The Vapor application to configure
    ///   - runMigrations: Whether to run Identity database migrations (default: true)
    /// - Throws: Any errors during configuration
    public static func configure(
        _ application: Vapor.Application,
        runMigrations: Bool = true
    ) async throws {
        @Dependency(\.logger) var logger
        @Dependency(\.defaultDatabase) var database
        
        logger.info("Configuring Identity Standalone", metadata: [
            "component": "Identity.Standalone",
            "operation": "configure"
        ])
        
        // Run Identity-specific migrations if requested
        if runMigrations {
            logger.debug("Running Identity database migrations", metadata: [
                "component": "Identity.Standalone",
                "operation": "database.migrate"
            ])
            
            let migrator = Identity.Backend.migrator()
            try await migrator.migrate(database)
            
            logger.debug("Identity database migrations complete", metadata: [
                "component": "Identity.Standalone",
                "operation": "database.migrate.success"
            ])
        }
        
        application.middleware.use(Identity.Standalone.Authenticator())
        
        logger.debug("Identity authenticator middleware registered", metadata: [
            "component": "Identity.Standalone",
            "operation": "middleware.registered"
        ])
        
        logger.info("Identity Standalone configuration complete", metadata: [
            "component": "Identity.Standalone",
            "operation": "configure.success"
        ])
    }
}
