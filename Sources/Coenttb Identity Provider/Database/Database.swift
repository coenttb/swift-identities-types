//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Coenttb_Fluent
import Foundation
import Logging
import PostgresNIO

public enum Database {}

extension Database {
    public struct Migration: AsyncMigration {
        public var name: String
        private let logger = Logger(label: "Database.Migration")

        public init(
            name: String = "Coenttb_Identity_Provider.Database.Migration"
        ) {
            self.name = name
        }

        private static let migrations: [any Fluent.AsyncMigration] = {
            var migrations: [any Fluent.AsyncMigration] = [
                {
                    var migration = Coenttb_Identity_Provider.Database.Identity.Migration.Create()
                    migration.name = "Coenttb_Identity.Database.Identity.Migration.Create"
                    return migration
                }(),
                {
                    var migration = Coenttb_Identity_Provider.Database.Identity.Deletion.Migration()
                    migration.name = "Coenttb_Identity.Database.Identity.Deletion.Migration"
                    return migration
                }(),
                {
                    var migration = Coenttb_Identity_Provider.Database.Identity.Token.Migration()
                    migration.name = "Coenttb_Identity_Provider.Database.Identity.Token.Migration.Create"
                    return migration
                }(),
                {
                    var migration = Coenttb_Identity_Provider.Database.EmailChangeRequest.Migration()
                    migration.name = "Coenttb_Identity.Database.EmailChangeRequest.Migration.Create"
                    return migration
                }(),
                {
                    var migration = Coenttb_Identity_Provider.Database.ApiKey.Migration.Create()
                    migration.name = "Coenttb_Identity.Database.ApiKey.Migration.Create"
                    return migration
                }()
            ]

            return migrations
        }()
        
        public func prepare(on database: Fluent.Database) async throws {
            for migration in Self.migrations {
                do {
                    try await migration.prepare(on: database)
                } catch {
                    logger.error("Failed to prepare migration \(migration.name): \(error)")
                    throw error
                }
            }
        }
        
        public func revert(on database: Fluent.Database) async throws {
            var errors: [Error] = []
            
            for migration in Self.migrations.reversed() {
                do {
                    try await migration.revert(on: database)
                } catch let error as PSQLError where error.isTableNotFoundError {
                    // Table doesn't exist error - log and continue
                    logger.warning("Table doesn't exist during reversion of \(migration.name): \(error)")
                    continue
                } catch {
                    logger.error("Failed to revert migration \(migration.name): \(error)")
                    errors.append(error)
                }
            }
            
            if !errors.isEmpty {
                throw MigrationError.multipleMigrationsFailed(errors)
            }
        }
    }
}

// Define custom error type for multiple migration failures
extension Database {
    enum MigrationError: Error {
        case multipleMigrationsFailed([Error])
    }
}

