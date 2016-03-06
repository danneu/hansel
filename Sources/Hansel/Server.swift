
import Foundation
import Commander

#if os(Linux)
  import Glibc
#endif

public class Server {
  private let socketServer: SocketServer

  public init (_ handler: Handler, trustProxy: Bool = false) {
    // This is where hansel wraps the user's handler with its
    // own final outer middleware
    let middleware = compose(
      Builtin.wrapOptions(trustProxy: trustProxy),
      Builtin.wrapErrorHandler,
      Builtin.wrapHead
    )
    self.socketServer = SocketServer(middleware(handler))
  }

  @noreturn public func listen (port: Int = 3000) {
    command(
      Option("port", port, description: "The server will bind to this port (Default: \(port))")
    ) { port in
      do {
        try self.socketServer.boot(port)
        print("Listening on \(port)")
        self.loop()
      } catch {
        print("Server failed to boot: \(error)")
      }
    }.run()
  }

  private func loop() {
    #if os(Linux)
      while true {
        sleep(1)
      }
    #else
      NSRunLoop.mainRunLoop().run()
    #endif
  }
}

//
// BUILT-IN MIDDLEWARE
//

private struct Builtin {}

// Feeds any option dependencies into the
// request so taht the request can access them.
extension Builtin {
  static func wrapOptions (trustProxy trustProxy: Bool) -> Middleware {
    return { handler in
      return { request in
        var copy = request
        copy.trustProxy = trustProxy
        return try handler(copy)
      }
    }
  }
}

// Middleware that handles HEAD requests

extension Builtin {
  static let wrapHead: Middleware = { handler in
    return { request in
      let response = try handler(headRequest(request))
      return headResponse(request, response: response)
    }
  }
}

private func headRequest (request: Request) -> Request {
  // Turn HEAD request into GET request
  if request.method == .Head {
    return request.setMethod(.Get)
  }
  return request
}

private func headResponse (request: Request, response: Response) -> Response {
  if request.method == .Head {
    return response.none()
  } else {
    return response
  }
}

// Top-level generic error handler

extension Builtin {
  static let wrapErrorHandler: Middleware = { handler in
    return { request in
      do {
        return try handler(request)
      } catch RequestError.BadBody {
        return Response(.BadRequest)
      } catch let err {
        print("Unhandled Error:", err)
        return Response(.Error)
      }
    }
  }
}