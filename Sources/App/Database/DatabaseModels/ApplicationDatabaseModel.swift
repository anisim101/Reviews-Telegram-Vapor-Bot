//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent
import FluentPostgresDriver
import Foundation

final class ApplicationDatabaseModel: Model {
    static var schema: String = ApplicationMigration.schemaName
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ApplicationMigration.appNameField)
    var name: String
    
    @Children(for: \.$application)
    var reviews: [ReviewDatabaseModel]
    
    @Siblings(through: AppReviewsSubscriberDatabaseModel.self,
              from: \.$app,
              to: \.$user)
    var subscribers: [TelegramUserDatabaseModel]
    
    @Parent(key: ApplicationMigration.creatorIdField)
    var creator: TelegramUserDatabaseModel
    
    init(name: String, creatorID: UUID) {
        self.name = name
        self.$creator.id = creatorID
    }
    
    init() {
        
    }
}
