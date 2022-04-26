//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Foundation

class TelegramBotResponse {
    
    static func subscriptionActivatedResponse(_ app: String) -> String{
        return "✅ Subscription activated."
    }
    
    static func canNotFindAppWithThisAppIdResponse() -> String {
        return "Can not find app with this AppID, try another."
    }
    
    static func allreadySubscibedOnAppResponse(app: String) -> String {
        return "You already subscribed on \(app)"
    }
    
    static func enterAnAppIdToSubscribeResponse() -> String {
        return "Enter an AppID to subscribe."
    }
    
    static func subscriptionsListIsEmptyResposne() -> String {
        return "❗️ Your subscriptions list is empty."
    }
    static func unsubscribedResponse() -> String {
        return "✅ Done"
    }
    static func appListResponse(user: String) -> String {
        return "⬇️ Choose an app to unsubscribed from the list below:"
    }
    static func appWasRemovedResponse(_ app: String) ->String  {
        return "✅ You have deleted \(app)"
    }
    
    static func selectAppToDeleteResponse() -> String {
        return "⬇️ Choose an app to delete from the list below:"
    }
    
    static func doneButtonTitle() -> String {
        return "✅ Done"
    }
    static func cancelButtonTitle() -> String {
        return "🛑 Cancel 🛑"
    }
    
    static func yourAppListIsEmptyResponse() -> String {
        return "❗️ Your app list is empty."
    }
    
    static func enterApplicationNameResponse() -> String {
        return "✅ Alright, a new app. How are we going to call it? Please choose a name for your app."
    }
    
    static func enterBotApiKeyResponse() -> String {
        return "🔑 Please enter a BotApiKey."
    }
    
    static func subscriptionDeactivatedResponse() -> String {
        return "😒 Subscription deactivated."
    }
    
    static func subscriptionActivatedResponse() -> String {
        return "✅ Subscription activated."
    }
    
    static func invalidBotApiKeyResponse() -> String {
        return "😔 Sorry, this BotApiKey is invalid."
    }
    
    static func applicationCreatedResponse(name: String,
                                           id: String) -> String {
        return "✅ Done! Congratulations on your new app.\n\n\n\nApp: \(name)\n\nAppID: \(id)"
    }
}
