//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent

class ApplicationMigration: Migration {
    
    static var schemaName = "applications_table"
    static var appNameField: FieldKey = "name"
    static var creatorIdField: FieldKey = "creator_id"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
       return database
            .schema(ApplicationMigration.schemaName)
            .id()
            .field(ApplicationMigration.appNameField,
                   .string,
                   .required)
            .field(ApplicationMigration.creatorIdField,
                   .uuid,
                   .required,
                   .references(TelegramUserDatabaseModel.schema,
                               .id,
                               onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(ApplicationMigration.schemaName)
            .delete()
    }
}

