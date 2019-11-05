//
//  SeedUsers.swift
//  App
//
//  Created by Bogdan Pashchenko on 05.11.2019.
//

import Fluent

class SeedUsers: Migration {
    
    typealias Database = AppDatabase
    
    static func prepare(on conn: Database.Connection) -> EventLoopFuture<Void> {
        let promise = conn.eventLoop.newPromise(of: Void.self)
        
        _ = User.query(on: conn).count().do { count in
            guard count == 0 else { promise.succeed(); return }
            
            let userFutures = [try? User.register(username: "u1", password: "123", on: conn),
                try? User.register(username: "u2", password: "123", on: conn),
                try? User.register(username: "u3", password: "123", on: conn),
                try? User.register(username: "u4", password: "123", on: conn)].compactMap { $0 }
            
            let g = DispatchGroup()
            
            userFutures.forEach { f in
                g.enter()
                _ = f.map { user in
                    try AccessToken(string: "\(user.username) token", userID: user.requireID()).save(on: conn).always { g.leave() }
                }
                return
            }
            
            g.notify(queue: .global()) { promise.succeed() }
        }
        
        return promise.futureResult
    }
    
    static func revert(on conn: Database.Connection) -> EventLoopFuture<Void> {
        let promise = conn.eventLoop.newPromise(Void.self)
        promise.succeed()
        return promise.futureResult
    }
}
