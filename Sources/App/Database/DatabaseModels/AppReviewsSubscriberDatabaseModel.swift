//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 22.04.2022.
//

import Vapor
import Fluent

final class AppReviewsSubscriberDatabaseModel: Model {
    
    static var schema = AppReviewsSubscriberMigration.schemaName
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: AppReviewsSubscriberMigration.userIdField)
    var user: TelegramUserDatabaseModel
    
    @Parent(key: AppReviewsSubscriberMigration.appIdField)
    var app: ApplicationDatabaseModel
    
    init() { }
    
    init(userID: UUID, appID: UUID) {
        self.$app.id = appID
        self.$user.id = userID
    }
}
