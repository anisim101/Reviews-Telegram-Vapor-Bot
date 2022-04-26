//
//  BotAdminKeysMigration.swift
//  
//
//  Created by Vladimir Anisimov on 22.04.2022.
//

import Fluent

class BotAdminKeysMigration: Migration {
    
    static var schemaName = "bot_admin_keys_table"
    static var privateKeyField: FieldKey = "bot_admin_key"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(BotAdminKeysMigration.schemaName)
            .id()
            .field(BotAdminKeysMigration.privateKeyField,
                   .string,
                   .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(BotAdminKeysMigration.schemaName)
            .delete()
    }
}
