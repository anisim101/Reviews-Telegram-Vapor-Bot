//
//  BotAdminController.swift
//  
//
//  Created by Vladimir Anisimov on 22.04.2022.
//

import Vapor


class BotAdminController: RouteCollection {
    
    struct BotAdminResponse: Content {
        var success = true
        var bot_admin_key: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("bod_admin_key", use: handleBotAdminKey)
    }
    
    private func handleBotAdminKey(req: Request) async throws -> BotAdminResponse {
        struct BotAdminRequest: Content {
            let telegramBotPrivateKey: String
        }
        let body = try req.content.decode(BotAdminRequest.self)
        
        if body.telegramBotPrivateKey == tgApi {
            let adminBotKey = UUID().uuidString
            try await BotAdminKeyDatabaseModel(key: adminBotKey)
                .create(on: req.db)
            return BotAdminResponse(bot_admin_key: adminBotKey)
        }
        
        throw Abort(.badRequest)
    }
}
