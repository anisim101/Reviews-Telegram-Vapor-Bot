//
//  DefaultBotHandlers.swift
//  
//
//  Created by Vladimir Anisimov on 20.04.2022.
//

import Vapor
import telegram_vapor_bot
import Fluent
import Foundation

enum SupportedCommands: String, CaseIterable {
    case start = "/start"
    case on = "/on"
    case off = "/off"
    case create = "/create"
    case subscribe = "/subscribe"
    case unsubscribe = "/unsubscribe"
    case remove_app = "/remove_app"
    
    var description: String {
        switch self {
        case .create:
            return "Create new App(admin only)."
        case .on:
            return "On"
        case .off:
            return "Off"
        case .start:
            return "Start"
        case .subscribe:
            return "Subscribe to new app"
        case .unsubscribe:
            return "unsubscribe"
        case .remove_app:
            return "Remove app (app creators only)"
        }
    }
}

final class TelegramBotHandlers {
    
    static func addHandlers(app: Vapor.Application,
                            bot: TGBotPrtcl) {
        onCommandHandler(app: app, bot: bot) // on
        offCommandHandler(app: app, bot: bot) // off
        createCommandHandler(app: app, bot: bot) // create
        handleTextMassages(app: app, bot: bot) // messages
        handleAllMessages(app: app, bot: bot) // // all input
        subscribeCommandHandle(app: app, bot: bot)
        unsubscribeCommandHandler(app: app, bot: bot)
        removeAppCommandHandler(app: app, bot: bot)
    }
    
    private static func removeAppCommandHandler(app: Vapor.Application,
                                                bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.remove_app.rawValue]) { update,bot in
            guard let userId = update.message?.from?.id else { return }
            Task {
                
                let (user, _) = try await createUserIfNeeded(userId,
                                                             app: app,
                                                             includeSubscriptions: true,
                includeCreatingApps: true)
                
                if user.appCreating.isEmpty {
                    try bot.sendPlainTextMessage(TelegramBotResponse.yourAppListIsEmptyResponse(), chatId: .chat(userId))
                } else {
                    var buttons = user.appCreating.map {
                        [TGInlineKeyboardButton(text: $0.name,
                                                callbackData: UUID().uuidString)]
                        
                    }
                    let cancelId = UUID().uuidString
                    buttons.append([TGInlineKeyboardButton(text: TelegramBotResponse.cancelButtonTitle(),
                                                           callbackData: cancelId)])
                    let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
                    let params: TGSendMessageParams = .init(chatId: .chat(userId),
                                                            text: TelegramBotResponse.selectAppToDeleteResponse(),
                                                                       replyMarkup: .inlineKeyboardMarkup(keyboard))
                    let message = try await bot.sendMessage(params: params).get()
                    let undoSubscribingAction = TGCallbackQueryHandler(pattern: cancelId) { update, bot in
                        Task {
                            try bot.deleteMessage(params: TGDeleteMessageParams(chatId: .chat(userId),
                                                                                messageId: message.messageId))
                            try bot.sendPlainTextMessage(TelegramBotResponse.doneButtonTitle(), chatId: .chat(userId))
                        }
                    }
                    
                    
                    bot.connection.dispatcher.add(undoSubscribingAction)
                    for (index, application) in user.appCreating.enumerated() {
                        
                        let handler = TGCallbackQueryHandler(pattern: buttons[index][0].callbackData ?? "") { update, bot in
                            Task {
                                try await application.delete(on: app.db)
                                
                                try bot.deleteMessage(params: TGDeleteMessageParams(chatId: .chat(userId),
                                                                                    messageId: message.messageId))
                                try bot.sendPlainTextMessage(TelegramBotResponse.appWasRemovedResponse(application.name), chatId: .chat(userId))
                            }
                            
                        }
                        
                        
                        bot.connection.dispatcher.add(handler)
                    }
                }
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func unsubscribeCommandHandler(app: Vapor.Application,
                                                  bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.unsubscribe.rawValue]) { update,bot in
            guard let userId = update.message?.from?.id,
            let username = update.message?.from?.username else { return }
            Task {
                let (user, _) = try await createUserIfNeeded(userId,
                                                             app: app,
                                                             includeSubscriptions: true)
                if !user.subscription.isEmpty {
                    var buttons = user.subscription.map {
                        [TGInlineKeyboardButton(text: $0.name,
                                                callbackData: UUID().uuidString)]
                    }
                    
                    let cancelId = UUID().uuidString
                    buttons.append([TGInlineKeyboardButton(text: TelegramBotResponse.cancelButtonTitle(),
                                                           callbackData: cancelId)])
                    let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
                    let params: TGSendMessageParams = .init(chatId: .chat(userId),
                                                            text: TelegramBotResponse.appListResponse(user: username),
                                                                       replyMarkup: .inlineKeyboardMarkup(keyboard))
                    let message = try await bot.sendMessage(params: params).get()
                    let undoSubscribingAction = TGCallbackQueryHandler(pattern: cancelId) { update, bot in
                        Task {
                            try bot.deleteMessage(params: TGDeleteMessageParams(chatId: .chat(userId),
                                                                                messageId: message.messageId))
                            try bot.sendPlainTextMessage(TelegramBotResponse.doneButtonTitle(), chatId: .chat(userId))
                        }
                    }
                    
                    
                    bot.connection.dispatcher.add(undoSubscribingAction)
                    for (index, application) in user.subscription.enumerated() {
                        
                        let handler = TGCallbackQueryHandler(pattern: buttons[index][0].callbackData ?? "") { update, bot in
                            Task {
                                try await application.$subscribers.detach(user, on: app.db)
                                
                                try bot.deleteMessage(params: TGDeleteMessageParams(chatId: .chat(userId),
                                                                                    messageId: message.messageId))
                                try bot.sendPlainTextMessage(TelegramBotResponse.unsubscribedResponse(), chatId: .chat(userId))
                            }
                            
                        }
                        
                        
                        bot.connection.dispatcher.add(handler)
                    }
                    
                    
                } else {
                    try bot.sendPlainTextMessage(TelegramBotResponse.subscriptionsListIsEmptyResposne(), chatId: .chat(userId))
                }
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func subscribeCommandHandle(app: Vapor.Application,
                                               bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.subscribe.rawValue]) { update,bot in
            guard let userId = update.message?.from?.id else { return }
            Task {
                let (user, _) = try await createUserIfNeeded(userId, app: app)
                user.dialogState = .enter_application_id_to_subscribe
                try await user.save(on: app.db)
                try bot.sendPlainTextMessage(TelegramBotResponse.enterAnAppIdToSubscribeResponse(), chatId: .chat(userId))
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func configureBotCommands(app: Vapor.Application, bot: TGBotPrtcl) async throws {
        let commands = SupportedCommands.allCases
            .compactMap { TGBotCommand(command: $0.rawValue,
                                       description: $0.description) }
        try  bot.setMyCommands(params: TGSetMyCommandsParams(commands: commands))
    }
    
    private static func handleAllMessages(app: Vapor.Application,
                                          bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: .all) { update, bot in
            Task {
                try await configureBotCommands(app: app, bot: bot)
            }
        }
        
        bot.connection.dispatcher.add(handler)
    }
    
    private static func handleTextMassages(app: Vapor.Application,
                                       bot: TGBotPrtcl) {
        let supportedCommandNames = SupportedCommands.allCases.map { $0.rawValue }
        let filter: TGFilter = (.text && !.command.names(supportedCommandNames))
        let handler = TGMessageHandler(filters: filter) { update, bot in
            Task {
                guard let userId = update.message?.from?.id else { return }
                let message = update.message?.text ?? ""
                
                let (user, _) = try await createUserIfNeeded(userId, app: app)
                switch user.dialogState {
                case .default:
                    return
                case .enter_application_name:
                    
                    let application = ApplicationDatabaseModel(name: message,
                                                               creatorID: user.id ?? UUID())
                    try await application.save(on: app.db)
                    user.dialogState = .default
                    try await user.save(on: app.db)
                    try await application.$subscribers.attach(user, on: app.db)
                    try bot.sendPlainTextMessage(TelegramBotResponse.applicationCreatedResponse(name: application.name, id: application.id?.uuidString ?? ""),
                                                 chatId: .chat(userId))
                case .enter_admin_api_key:
                    if try await BotAdminKeyDatabaseModel.query(on: app.db)
                        .filter(\.$key == message)
                        .first() != nil {
                        user.role = .admin
                        user.dialogState = .enter_application_name
                        try await user.save(on: app.db)
                        try bot.sendPlainTextMessage(TelegramBotResponse.enterApplicationNameResponse(),
                                                     chatId: .chat(userId))
                    } else {
                        try bot.sendPlainTextMessage(TelegramBotResponse.invalidBotApiKeyResponse(),
                                                     chatId: .chat(userId))
                    }
                    
                case .enter_application_id_to_subscribe:
                    if let application = try await ApplicationDatabaseModel
                        .find(UUID(uuidString: message),
                              on: app.db) {
                        do  {
                            try await application.$subscribers.attach(user, on: app.db)
                            try bot.sendPlainTextMessage(TelegramBotResponse.subscriptionActivatedResponse(application.name), chatId: .chat(userId))
                            user.dialogState = .default
                        } catch {
                            try bot.sendPlainTextMessage(TelegramBotResponse.allreadySubscibedOnAppResponse(app: application.name), chatId: .chat(userId))
                            user.dialogState = .default
                        }
                    } else {
                        try bot.sendPlainTextMessage(TelegramBotResponse.canNotFindAppWithThisAppIdResponse(), chatId: .chat(userId))
                    }
                    try await user.save(on: app.db)
                
                }
                
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    static private func createUserIfNeeded(_ telegramUserID: Int64,
                                           app: Vapor.Application,
                                           includeSubscriptions: Bool = false,
                                           includeCreatingApps: Bool = false) async throws -> (TelegramUserDatabaseModel, Bool) {
        
        var userQuery =  TelegramUserDatabaseModel
            .query(on: app.db)
            .filter(\.$telegramUserId == telegramUserID)
        
        if includeSubscriptions {
            userQuery = userQuery
                .with(\.$subscription)
        }
        
        if includeCreatingApps {
            userQuery = userQuery
                .with(\.$appCreating)
        }
        
        if let user = try await userQuery
            .first() {
            return (user, false)
        }
        
        let user = TelegramUserDatabaseModel(telegramUserId: telegramUserID,
                                             state: .default)
        try await user
            .create(on: app.db)
        return (user, true)
    }
    
    private static func createCommandHandler(app: Vapor.Application,
                                             bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.create.rawValue]) { update, bot in
            Task {
                guard let userId = update.message?.from?.id else { return }
                let (user, _) = try await createUserIfNeeded(userId, app: app)
                switch user.role {
                case .default:
                    user.dialogState = .enter_admin_api_key
                    try bot.sendPlainTextMessage(TelegramBotResponse.enterBotApiKeyResponse(),
                                                 chatId: .chat(userId))
                case .admin:
                    user.dialogState = .enter_application_name
                    try bot.sendPlainTextMessage(TelegramBotResponse.enterApplicationNameResponse(),
                                                 chatId: .chat(userId))
                }
                try await user.save(on: app.db)
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func offCommandHandler(app: Vapor.Application,
                                          bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.off.rawValue]) { update, bot in
            guard let userId = update.message?.from?.id else { return }
            Task {
                
                
                if let user = try await TelegramUserDatabaseModel
                    .query(on: app.db)
                    .filter(\.$telegramUserId == userId)
                    .first() {
                    do {
                        try await user
                            .delete(on: app.db)
                        try bot.sendPlainTextMessage(TelegramBotResponse.subscriptionDeactivatedResponse(), chatId: .chat(userId))
                    } catch {
                        print(error.logMessage)
                    }
                }
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func onCommandHandler(app: Vapor.Application,
                                         bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: [SupportedCommands.on.rawValue,
                                                  SupportedCommands.start.rawValue])
        { update, bot in
            guard let userId = update.message?.from?.id else { return }
            Task {
                let (user, isNew) = try await createUserIfNeeded(userId, app: app)
                if !isNew {
                    user.dialogState = .default
                    try await user.save(on: app.db)
                }
                
                try bot.sendPlainTextMessage(TelegramBotResponse.subscriptionActivatedResponse(),
                                             chatId: .chat(userId))
            }
        }
        bot.connection.dispatcher.add(handler)
    }
}
