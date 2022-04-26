//
//  TelegramUserDatabaseModel.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent
import Foundation

enum DialogState: String, Codable, CaseIterable {
    case `default` = "default"
    case enter_application_name = "enter_application_name"
    case enter_admin_api_key = "enter_admin_api_key"
    case enter_application_id_to_subscribe = "enter_application_id_to_subscribe"
}

enum UserRole: String, Codable, CaseIterable {
    case `default` = "default"
    case admin = "admin"
}

final class TelegramUserDatabaseModel: Model {
   
    static var schema = TelegramUserMigration.schemaName
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: TelegramUserMigration.telegramUserIdField)
    var telegramUserId: Int64
    
    @Field(key: TelegramUserMigration.dialogStateField)
    var dialogState: DialogState
    
    @Field(key: TelegramUserMigration.userRoleField)
    var role: UserRole
    
    @Siblings(through: AppReviewsSubscriberDatabaseModel.self,
              from: \.$user, to: \.$app)
    var subscription: [ApplicationDatabaseModel]
    
    @Children(for: \.$creator)
    var appCreating: [ApplicationDatabaseModel]
    
    init() {}
    
    init(telegramUserId: Int64,
         state: DialogState,
         role: UserRole = .default) {
        self.telegramUserId = telegramUserId
        self.$dialogState.value = state
        self.$role.value = role
    }
}
