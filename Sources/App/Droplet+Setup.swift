@_exported import Vapor

weak var drop: Droplet!

extension Droplet {
    public func setup() throws {
        drop = self
        try setupRoutes()
        seedData()
    }
    
    func seedData() {
        guard (try? User.count()) == 0 else { return }
        
        let u1 = try? User.register(username: "u1", password: "123")
        let u2 = try? User.register(username: "u2", password: "123")
        let u3 = try? User.register(username: "u3", password: "123")
        let u4 = try? User.register(username: "u4", password: "123")
        
        if let u1Id = u1?.id { let t1 = AccessToken(token: "u1 token", userId: u1Id); try? t1.save() }
        if let u2Id = u2?.id { let t2 = AccessToken(token: "u2 token", userId: u2Id); try? t2.save() }
        if let u3Id = u3?.id { let t3 = AccessToken(token: "u3 token", userId: u3Id); try? t3.save() }
        if let u4Id = u4?.id { let t4 = AccessToken(token: "u4 token", userId: u4Id); try? t4.save() }
    }
}
