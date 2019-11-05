import Authentication
import Vapor

final class User: AppModel {
    
    var id: Int?
    var username: String
    var passwordHash: String
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(id: Int? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }
    
    var tokens: Children<User, AccessToken> { children(\.userID) }
    
    class func register(username: String, password: String, on conn: DatabaseConnectable) throws -> EventLoopFuture<User> {
        return try User(username: username, passwordHash: BCrypt.hash(password)).save(on: conn)
    }
    
    func `public`() throws -> PublicUser { return try PublicUser(id: requireID(), username: username) }
}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> { \.username }
    static var passwordKey: WritableKeyPath<User, String> { \.passwordHash }
}

extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

extension User: Migration {
    static func prepare(on conn: AppDatabase.Connection) -> Future<Void> {
        return AppDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.username)
            builder.field(for: \.passwordHash)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
        }
    }
}

// MARK: -

struct PublicUser: Content {
    var id: Int
    var username: String
}
