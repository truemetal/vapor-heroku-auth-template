//
//  AppConfig.swift
//  App
//
//  Created by Bogdan Pashchenko on 02.11.2019.
//

import Authentication
import FluentPostgreSQL
import Vapor

typealias AppModel = PostgreSQLModel & Content & Parameter
typealias AppDatabase = PostgreSQLDatabase
let databaseId = DatabaseIdentifier<AppDatabase>.psql

let db = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(url: Environment.get("DATABASE_URL")!)!)

public class AppConfig {
    
    public init() {}
    
    public func app(_ env: Environment? = nil) throws -> Application {
        return try Application(config: Config.default(), environment: env ?? .detect(), services: try configure())
    }
    
    func configure() throws -> Services {
        var services = Services.default()
        
        try services.register(FluentPostgreSQLProvider())
        try services.register(AuthenticationProvider())
        
        try services.register(AppRouterConfig().router, as: Router.self)
        services.register(middlewares)
        services.register(try databases())
        services.register(migrations)
        services.register(AppWebSocketsServer(), as: WebSocketServer.self)
        
        return services
    }
    
    var middlewares: MiddlewareConfig {
        var middlewares = MiddlewareConfig()
        middlewares.use(ErrorMiddleware.self)
        middlewares.use(HerokuHttpsMiddleware())
        return middlewares
    }
    
    func databases() throws -> DatabasesConfig {
        var databases = DatabasesConfig()
        databases.enableLogging(on: databaseId)
        databases.add(database: db, as: databaseId)
        return databases
    }
    
    var migrations: MigrationConfig {
        var migrations = MigrationConfig()
        migrations.add(model: User.self, database: databaseId)
        migrations.add(model: AccessToken.self, database: databaseId)
        migrations.add(migration: SeedUsers.self, database: databaseId)
        return migrations
    }
}
