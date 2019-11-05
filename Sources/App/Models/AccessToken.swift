import Authentication
import Crypto
import Vapor

final class AccessToken: AppModel {

    var id: Int?
    var token: String
    var userID: User.ID
    var expiresAt: Date?
    
    static var deletedAtKey: TimestampKey? { \.expiresAt }
    static let expirationTimeInterval: TimeInterval = 60 * 60 * 5
    
    init(id: Int? = nil, string: String, userID: User.ID) {
        self.id = id
        self.token = string
        self.expiresAt = Date(timeInterval: Self.expirationTimeInterval, since: .init())
        self.userID = userID
    }
    
    static func create(userID: User.ID) throws -> AccessToken {
        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
        return .init(string: string, userID: userID)
    }
}

extension AccessToken {
    var user: Parent<AccessToken, User> { parent(\.userID) }
}

extension AccessToken: Token {
    typealias UserType = User
    static var tokenKey: WritableKeyPath<AccessToken, String> { \.token }
    static var userIDKey: WritableKeyPath<AccessToken, User.ID> { \.userID }
}

extension AccessToken: Migration {
    static func prepare(on conn: AppDatabase.Connection) -> Future<Void> {
        return AppDatabase.create(AccessToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.token)
            builder.field(for: \.userID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
