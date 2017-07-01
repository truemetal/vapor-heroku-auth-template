import Vapor
import FluentProvider

final class AccessToken: Model
{
    let storage = Storage()
    enum Fields: String { case token, user_id }
    let token: String
    let userId: Identifier
    
    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
    }
    
    init(row: Row) throws {
        token = try row.get(Fields.token)
        userId = try row.get(Fields.user_id)
    }
    
    func makeRow() throws -> Row
    {
        var row = Row()
        try row.set(Fields.token, token)
        try row.set(Fields.user_id, userId)
        return row
    }
    
    var user: Parent<AccessToken, User> {
        return parent(id: userId)
    }
}
extension AccessToken: Timestampable {}

extension AccessToken: Preparation
{
    static func prepare(_ database: Database) throws
    {
        try database.create(self) { table in
            table.id()
            table.string(Fields.token, optional: false, unique: true)
            table.foreignId(for: User.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension AccessToken: JSONRepresentable
{
    func makeJSON() throws -> JSON
    {
        var json = JSON()
        try json.set(Fields.token, token)
        return json
    }
}

extension AccessToken: ResponseRepresentable { }

import Crypto
extension AccessToken
{
    static func generate(for user: User) throws -> AccessToken
    {
        guard let userId = user.id else { throw Abort.badRequest }
        let random = try Crypto.Random.bytes(count: 16)
        return AccessToken(token: random.base64Encoded.makeString(), userId: userId)
    }
}
