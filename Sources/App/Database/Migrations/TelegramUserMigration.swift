//
//  TelegramUserMigration.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Fluent


class TelegramUserMigration: Migration {

    static var schemaName = "telegram_users_table"
    static var telegramUserIdField: FieldKey = "telegram_user_id"
    static var dialogStateField: FieldKey = "telegram_dialog_state"
    static var userRoleField: FieldKey = "telegram_user_role"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema(TelegramUserMigration.schemaName)
            .id()
            .field(TelegramUserMigration.telegramUserIdField,
                   .int64,
                   .required)
            .field(TelegramUserMigration.dialogStateField,
                   .string,
                   .required)
            .field(TelegramUserMigration.userRoleField,
                   .string,
                   .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(TelegramUserMigration.schemaName)
            .delete()
    }
}
