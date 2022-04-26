//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent
import FluentPostgresDriver
import Foundation

final class ReviewDatabaseModel: Model {
    static var schema = ReviewMigration.schemaName
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ReviewMigration.appReviewFiled)
    var review: String
    
    @OptionalField(key: ReviewMigration.appRatingFiled)
    var rating: Int?

    @Parent(key: ReviewMigration.applicationFiled)
    var application: ApplicationDatabaseModel
    
    @Field(key: ReviewMigration.dateFiled)
    var date: Date
    
    init() { }
    
    init(review: String,
         rating: Int? = nil,
         applicationId: UUID,
         date: Date = Date()) {
        self.review = review
        self.rating = rating
        self.date = date
        self.$application.id = applicationId
    }
}
