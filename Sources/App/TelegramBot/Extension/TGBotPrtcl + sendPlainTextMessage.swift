//
//  File.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import telegram_vapor_bot

public extension  TGBotPrtcl {
    func sendPlainTextMessage(_ message: String,
                              chatId: TGChatId) throws {
        let param = TGSendMessageParams(chatId: chatId,
                                        text: message)
        try sendMessage(params: param)
    }
}
