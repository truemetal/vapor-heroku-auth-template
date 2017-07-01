//
//  HerokuHttpsMiddleware.swift
//  vapor-mysql
//
//  Created by Dan Pashchenko on 6/17/17.
//
//

import HTTP

class HerokuHttpsMiddleware: Middleware
{
    init(config: Config) throws {}
        
    func respond(to request: Request, chainingTo next: Responder) throws -> Response
    {
        if config.environment == .production,
            let originalProtocol = request.headers["x-forwarded-proto"],
            originalProtocol != "https"
        {
            return Response(status: .forbidden, body: "HTTPS Required")
        }
        
        return try next.respond(to: request)
    }
}
