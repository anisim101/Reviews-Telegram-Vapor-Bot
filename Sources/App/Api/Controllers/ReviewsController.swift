//
//  ReviewsController.swift
//  
//
//  Created by Vladimir Anisimov on 21.04.2022.
//

import Vapor
import telegram_vapor_bot

fileprivate struct ReviewResponse: Content {
    var success = true
}

class ReviewsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("review", use: reviewRequestHandler)
    }
    
    private func reviewRequestHandler(req: Request) async throws -> ReviewResponse {
        struct ReviewRequest: Content {
            let appId: UUID
            let review: String
            let rating: Int?
        }
        
        let body = try req.content.decode(ReviewRequest.self)
        let review = ReviewDatabaseModel(review: body.review,
                                         rating: body.rating,
                                         applicationId: body.appId)
        
        if let app = try? await ApplicationDatabaseModel
            .query(on: req.db)
            .with(\.$subscribers)
            .filter(\.$id, .equal, body.appId)
            .first() {
            
            for subscriber in app.subscribers {
                let telegramId = subscriber.telegramUserId
                try TGBot.shared.sendPlainTextMessage("new review \n\n\(review.review)", chatId: .chat(telegramId))
            }
            
            try await review.save(on: req.db)
        } else {
            throw Abort(.badRequest)
        }
        return ReviewResponse(success: true)
    }
}
