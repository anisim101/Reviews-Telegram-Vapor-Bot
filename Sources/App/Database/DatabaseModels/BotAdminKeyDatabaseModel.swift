//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 22.04.2022.
//

import Fluent
import Foundation

final class BotAdminKeyDatabaseModel: Model {
    static var schema = BotAdminKeysMigration.schemaName
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: BotAdminKeysMigration.privateKeyField)
    var key: String
    
    init() { }
    
    init(key: String) {
        self.key = key
    }
}
