import Vapor
import Fluent
import Crypto

final class UserController {
    
    func index(_ req: Request) throws -> Future<[PublicUser]> {
        let user = try req.requireAuthenticated(User.self)
        return try User.query(on: req).filter(\.id != user.requireID()).all().map { try $0.map { try $0.public() } }
    }
    
    func me(_ req: Request) throws -> String {
        let user = try req.requireAuthenticated(User.self)
        return user.username
    }
    
    func login(_ req: Request) throws -> Future<AccessToken> {
        let user = try req.requireAuthenticated(User.self)
        let token = try AccessToken.create(userID: user.requireID())
        return token.save(on: req)
    }
    
    func register(_ req: Request) throws -> Future<SignupResult> {
        return try req.content.decode(CreateUserRequest.self).flatMap { user in
            try User.register(username: user.username, password: user.password, on: req).flatMap { user in
                try AccessToken.create(userID: user.requireID()).save(on: req).map { token in
                    try SignupResult(token: token.token, user: user.public())
                }
            }
        }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try user.tokens.query(on: req).delete().map { .ok }
    }
}

// MARK: Content

fileprivate struct CreateUserRequest: Content {
    var username: String
    var password: String
}

struct SignupResult: Content {
    var token: String
    var user: PublicUser
}
