//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Foundation
import Fluent

public enum Database {}

extension Database {
    public struct Migration: AsyncMigration {
        
        public var name: String
        
        public init(
            name: String = "Coenttb_Identity_Provider.Database.Migration.Create"
        ) {
            self.name = name
        }
        
        private static let migrations: [any Fluent.Migration] = {
            var migrations: [any Fluent.Migration] = [
                {
                    var migration = Coenttb_Identity_Provider.Database.Identity.Migration.Create()
                    migration.name = "Coenttb_Identity.Database.Identity.Migration.Create"
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
                let _ = migration.prepare(on: database)
            }
        }
        
        public func revert(on database: Fluent.Database) async throws {
            for migration in Self.migrations {
                let _ = migration.revert(on: database)
            }
        }
    }
}
