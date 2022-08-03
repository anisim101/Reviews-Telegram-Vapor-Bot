import Vapor
import telegram_vapor_bot
import Fluent
import FluentPostgresDriver

let tgApi: String = "5391260542:AAHwjlWVGF-1ySYe19T_rlMIlu0vc8f-x4c"
// configures your application
public func configure(_ app: Application) throws {
    
//    let databaseConfig: PostgreSQLDatabaseConfig
//    if let url = Environment.get("DATABASE_URL") {
//        // configuring database
//        databaseConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS)!
//    } else {
//
//    }
    
    let databaseConfiguration = PostgresConfiguration(hostname: "localhost",
                                                      port: 5432,
                                                      username: "postgres",
                                                      database: "review_app_database")
    app.databases.use(.postgres(configuration: databaseConfiguration), as: .psql)
    
    app.migrations.add(BotAdminKeysMigration())
    app.migrations.add(TelegramUserMigration())
    app.migrations.add(ApplicationMigration())
    app.migrations.add(ReviewMigration())
    app.migrations.add(AppReviewsSubscriberMigration())
    
    try routes(app)
    
    let connection: TGConnectionPrtcl = TGLongPollingConnection()
    TGBot.configure(connection: connection, botId: tgApi, vaporClient: app.client)
    TelegramBotHandlers.addHandlers(app: app, bot: TGBot.shared)
    TGBot.log.logLevel = .debug
    try TGBot.shared.start()
}
