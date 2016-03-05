
import Foundation

public class SocketServer {
  // socket open to the port the server is listening on. Usually 80.
  private var listenSocket: Socket = Socket(socketFileDescriptor: -1)

  // set of connected client sockets
  private var clientSockets: Set<Socket> = []

  // shared lock for notifying new connections
  private let clientSocketsLock = NSLock()

  private let handler: Handler

  init (_ handler: Handler) {
    self.handler = handler
  }

  public func boot(port: Int) throws {
    // stop server if it's already running
    self.halt()

    // open a socket, might fail
    self.listenSocket = try Socket.tcpSocketForListen(UInt16(port))
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      // creates the infinite loop that will wait for client connections
      while let socket = try? self.listenSocket.acceptClientSocket() {
        // wait for lock to notify a new connection
        self.lock(self.clientSocketsLock) {
          // keep track of open sockets
          self.clientSockets.insert(socket)
        }
        // handle connection in background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
          self.handleConnection(socket)
          // set lock to wait for another connection
          self.lock(self.clientSocketsLock) {
            self.clientSockets.remove(socket)
          }
        }
      }
      // stop server in case something didn't work
      self.halt()
    }
  }

  public func halt () {
    // free the port
    self.listenSocket.release()

    // shutdown all client sockets
    self.lock(self.clientSocketsLock) {
      for socket in self.clientSockets {
        socket.shutdwn()
      }
      self.clientSockets.removeAll(keepCapacity: true)
    }
  }

  func handleConnection(socket: Socket) {
    defer {
      socket.release()
    }

    let parser = SocketParser()

    while let request = try? parser.readHttpRequest(socket) {
      // we can try! since hansel has its own top-level try/catch
      let response = try! handler(request).finalize()
      do {
        try self.respond(socket, response: response)
      } catch {
        print("Failed to send response: \(error)")
        break
      }
    }
  }

  private func lock (handle: NSLock, closure: () -> ()) {
    handle.lock()
    closure()
    handle.unlock()
  }

  // TODO: KeepAlive
  private func respond (socket: Socket, response: Response) throws -> Bool {
    // need it mutable so we can call mutable functions on response.body
    var response = response

    try socket.writeUTF8("HTTP/1.1 \(response.status.rawValue) \(response.status.phrase)\r\n")

    // write k=v headers
    for (key, value) in response.headers {
      try socket.writeUTF8("\(key): \(value)\r\n")
    }

    // write boundary
    try socket.writeUTF8("\r\n")

    // prepare body stream
    response.body.open()
    defer { response.body.close() }

    // write body
    while let bytes = response.body.next() {
      try socket.writeUInt8(bytes)
    }

    return true
  }
}