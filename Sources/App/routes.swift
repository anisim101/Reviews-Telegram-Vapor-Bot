import Vapor
import telegram_vapor_bot

func routes(_ app: Application) throws {
    let apiGroup = app.grouped("api")
    
    let botAdminController = BotAdminController()
    let reviewsController = ReviewsController()
    try apiGroup.register(collection: reviewsController)
    try apiGroup.register(collection: botAdminController)
}
