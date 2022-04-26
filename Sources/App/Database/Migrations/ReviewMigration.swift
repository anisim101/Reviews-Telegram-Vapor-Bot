//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent
import Vapor

class ReviewMigration: Migration {
    
    static var schemaName = "reviews_table"
    static var appRatingFiled: FieldKey = "rating"
    static var appReviewFiled: FieldKey = "review"
    static var idField: FieldKey = "id"
    static var applicationFiled: FieldKey = "application_id"
    static var dateFiled: FieldKey = "date"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema(ReviewMigration.schemaName)
            .id()
            .field(ReviewMigration.appRatingFiled,
                   .int)
            .field(ReviewMigration.appReviewFiled,
                   .string,
                   .required)
            .field(ReviewMigration.dateFiled,
                   .date,
                   .required)
            .field(ReviewMigration.applicationFiled,
                   .uuid,
                   .references(ApplicationMigration.schemaName,
                               .id,
                               onDelete: .cascade),
                   .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(ReviewMigration.schemaName)
            .delete()
    }
    
}
