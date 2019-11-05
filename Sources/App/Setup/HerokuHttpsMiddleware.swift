//
//  HerokuHttpsMiddleware.swift
//  App
//
//  Created by Bogdan Pashchenko on 05.11.2019.
//

import Vapor

class HerokuHttpsMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        if let originalProtocol = request.http.headers.first(where: { $0.name.lowercased() == "x-forwarded-proto" })?.value, originalProtocol != "https" {
            return request.future(Response(http: HTTPResponse(status: .forbidden, body: "HTTPS Required"), using: request))
        }
        
        return try next.respond(to: request)
    }
}
