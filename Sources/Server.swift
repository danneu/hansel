
import Foundation

public class Server {
  let socketServer: SocketServer

  public init (_ handler: Handler, trustProxy: Bool = false) {
    // This is where hansel wraps the user's handler with its
    // own final outer middleware
    let middleware = compose(
      wrapRequestOptions(trustProxy: trustProxy),
      Batteries.head
    )
    self.socketServer = SocketServer(middleware(handler))
  }

  public func listen (port: Int = 3000) {
    do {
      try self.socketServer.boot(port)
      print("Listening on \(port)")
      self.loop()
    } catch {
      print("Server failed to boot: \(error)")
    }
  }

  func loop() {
    #if os(Linux)
      while true {
        sleep(1)
      }
    #else
      NSRunLoop.mainRunLoop().run()
    #endif
  }
}

func wrapRequestOptions (trustProxy trustProxy: Bool) -> Middleware {
  return { handler in
    return { request in
      var copy = request
      copy.trustProxy = trustProxy
      return handler(copy)
    }
  }
}