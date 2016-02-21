
import Foundation

public class Server {
  let socketServer: SocketServer

  public init (_ handler: Handler) {
    self.socketServer = SocketServer(handler: handler)
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