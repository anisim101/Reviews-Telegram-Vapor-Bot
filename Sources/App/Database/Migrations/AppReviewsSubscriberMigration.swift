//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 22.04.2022.
//

import Fluent

class AppReviewsSubscriberMigration: Migration {
    
    static var schemaName = "app_reviews_subscriber"
    static var userIdField: FieldKey = "user_id"
    static var appIdField: FieldKey = "app_id"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(AppReviewsSubscriberMigration.schemaName)
            .id()
            .field(AppReviewsSubscriberMigration.userIdField,
                   .uuid,
                   .required,
                   .references(TelegramUserDatabaseModel.schema,
                               .id,
                               onDelete: .cascade))
            .field(AppReviewsSubscriberMigration.appIdField,
                   .uuid,
                   .required,
                   .references(ApplicationMigration.schemaName,
                               .id,
                               onDelete: .cascade))
            .unique(on: AppReviewsSubscriberMigration.appIdField)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(AppReviewsSubscriberMigration.schemaName)
            .delete()
    }
}
