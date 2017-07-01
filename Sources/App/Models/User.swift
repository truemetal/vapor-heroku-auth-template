import Vapor
import FluentProvider

final class User: Model
{
    let storage = Storage()
    enum Fields: String { case id, username, password }
    let username: String
    var password: String?
    
    init(row: Row) throws {
        username = try row.get(Fields.username)
        password = try row.get(Fields.password)
    }
    
    init(username: String) {
        self.username = username
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.username, username)
        try row.set(Fields.password, password)
        return row
    }
}
extension User: Timestampable { }

// MARK: Preparation

extension User: Preparation
{
    static func prepare(_ database: Database) throws
    {
        try database.create(self) { table in
            table.id()
            table.string(Fields.username, optional: false, unique: true)
            table.string(Fields.password, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension User: JSONConvertible
{
    convenience init(json: JSON) throws
    {
        try self.init(username: json.get(Fields.username))
        id = try json.get(Fields.id)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.username, username)
        return json
    }
}
extension User: ResponseRepresentable { }

// MARK: Auth

import AuthProvider

extension User: TokenAuthenticatable {
    public typealias TokenType = AccessToken
}

extension User: PasswordAuthenticatable
{
    static var usernameKey: String { return Fields.username.rawValue }
    static var passwordVerifier: PasswordVerifier? { return drop.hash as? PasswordVerifier }
    var hashedPassword: String? { return password }
}

extension User
{
    class func register(username: String, password: String) throws -> User
    {
        let user = User(username: username)
        user.password = try drop.hash.make(password.makeBytes()).makeString()
        
        guard try User.makeQuery().filter(Fields.username, user.username).first() == nil else {
            throw Abort(.badRequest, reason: "A user with that username already exists.")
        }
        
        try user.save()
        return user
    }
}

// MARK: helpers

extension Request
{
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
