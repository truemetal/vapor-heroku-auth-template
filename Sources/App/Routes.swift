import Vapor
import AuthProvider
import Foundation

extension Droplet {
    var tokenAuthed: RouteBuilder { return grouped(TokenAuthenticationMiddleware(User.self)) }
    var passwordAuthed: RouteBuilder { return grouped(PasswordAuthenticationMiddleware(User.self)) }
    
    func setupRoutes() throws {
        setupPublicRoutes()
        setupAuthRoutes()
        setupProtectedRoutes()
    }
    
    func setupPublicRoutes() {
        get() { _ in
            "This is a simple vapor-2 API template with login/signup routes, prepared to be deployed on heroku\n"
        }
        
        get("hello") { _ in return JSON(["Hello" : "World!"]) }
        
        get("hello", String.parameter) { req in
            let name = try req.parameters.next(String.self)
            return "Hello, \(name)!"
        }
        
        socket("ws") { req, ws in
            ws.onText = { ws, text in
                try ws.send(String(text.characters.reversed()))
            }
        }
    }
    
    func setupProtectedRoutes() {
        tokenAuthed.get("me") { req in
            return try req.user().username
        }
        
        tokenAuthed.get("users") { req in
            guard let userId = try req.user().id else { throw Abort.badRequest }
            return try User.makeQuery().all().filter({ $0.id != userId }).makeJSON()
        }
    }
    
    func setupAuthRoutes() {
        tokenAuthed.post("logout") { req in
            guard let tokenStr = req.auth.header?.bearer?.string,
                let token = try AccessToken.makeQuery().filter(AccessToken.Fields.token, tokenStr).first()
                else { throw Abort.badRequest }
            try token.delete()
            return Response(status: .ok)
        }
        
        post("register") { req in
            guard let username = req.data["username"]?.string,
                let password = req.data["password"]?.string
                else { throw Abort(.badRequest) }
            
            let user = try User.register(username: username, password: password)
            
            let token = try AccessToken.generate(for: user)
            try token.save()
            return try JSON(node: ["token" : token.token, "user" : try user.makeJSON()])
        }
        
        passwordAuthed.post("login") { req in
            let user = try req.user()
            let token = try AccessToken.generate(for: user)
            try token.save()
            return try JSON(node: ["token" : token.token, "user" : try user.makeJSON()])
        }
    }
}
