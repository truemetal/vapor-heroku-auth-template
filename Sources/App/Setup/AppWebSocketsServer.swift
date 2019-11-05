//
//  AppWebSocketsServer.swift
//  App
//
//  Created by Bogdan Pashchenko on 05.11.2019.
//

import Vapor

class AppWebSocketsServer: WebSocketServer, Service {
    
    private let wrapped = NIOWebSocketServer.default()
    
    init() {
        setRoutes()
    }
    
    // since HerokuHttpsMiddleware is not called for websockets, implements a simimilar check for original protocol here
    
    func webSocketShouldUpgrade(for request: Request) -> HTTPHeaders? {
        if let originalProtocol = request.http.headers.first(where: { $0.name.lowercased() == "x-forwarded-proto" })?.value, originalProtocol != "https" { return nil }
        return wrapped.webSocketShouldUpgrade(for: request)
    }
    
    func webSocketOnUpgrade(_ webSocket: WebSocket, for request: Request) {
        wrapped.webSocketOnUpgrade(webSocket, for: request)
    }
    
    func setRoutes() {
        wrapped.get("ws") { ws, req in
            ws.onText { ws, text in
                ws.send(text.reversed())
            }
        }
    }
}
