//
//  AppRouter.swift
//  App
//
//  Created by Bogdan Pashchenko on 02.11.2019.
//

import Crypto
import Vapor

class AppRouterConfig {
    
    let router: EngineRouter
    
    init(router: EngineRouter = EngineRouter.default()) throws {
        self.router = router
        try setRoutes()
    }
    
    // MARK: -
    
    let userController = UserController()
    private lazy var passwordAuthed = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    private lazy var tokenAuthed = router.grouped(User.tokenAuthMiddleware())
    
    private func setRoutes() throws {
        setPublic()
        setTokenProtected()
        setAuth()
    }
    
    private func setPublic() {
        router.get() { _ in "This is a simple vapor-3 API template with login/signup routes, prepared to be deployed on heroku\n" }
        
        router.get("hello") { _ in ["Hello": "World!"] }
        
        router.get("hello", String.parameter) { req -> String in
            let name = try req.parameters.next(String.self)
            return "Hello, \(name)!"
        }
    }
    
    private func setTokenProtected() {
        tokenAuthed.get("me", use: userController.me)
        tokenAuthed.get("users", use: userController.index)
    }
    
    func setAuth() {
        router.post("register", use: userController.register)
        passwordAuthed.post("login", use: userController.login)
        tokenAuthed.post("logout", use: userController.logout)
    }
}
