
import Foundation
import Commander

#if os(Linux)
  import Glibc
#endif

open class Server {
  fileprivate let socketServer: SocketServer

  public init (_ handler: @escaping Handler, trustProxy: Bool = false, headerSecurity: HeaderSecurity = .site) {
    // This is where hansel wraps the user's handler with its
    // own final outer middleware
    let middleware = compose(
      Builtin.wrapOptions(trustProxy: trustProxy),
      Builtin.wrapHeaderSecurity(headerSecurity),
      Builtin.wrapErrorHandler,
      Builtin.wrapHead
    )
    self.socketServer = SocketServer(middleware(handler))
  }

  // same as .listen() except doesn't listen for process arguments.
  // running server in xcode fails on a commander
  // error "unknown argument" since xcode seems to pass an argument
  // in that i can't figure out how to catch.
  open func embed (_ port: Int = 3000) {
    do {
      try self.socketServer.boot(port)
      print("Listening on \(port)")
      self.loop()
    } catch {
      print("Server failed to boot: \(error)")
    }
  }
  
  open func listen (_ port: Int = 3000) -> Never  {
    command(
      Option("port", port, description: "The server will bind to this port (Default: \(port))")
    ) { port in
      self.embed(port)
    }.run()
  }

  fileprivate func loop() {
    #if os(Linux)
      while true {
        sleep(1)
      }
    #else
      RunLoop.main.run()
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
  static func wrapOptions (trustProxy: Bool) -> Middleware {
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

private func headRequest (_ request: Request) -> Request {
  // Turn HEAD request into GET request
  if request.method == .Head {
    return request.setMethod(.Get)
  }
  return request
}

private func headResponse (_ request: Request, response: Response) -> Response {
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
      } catch RequestError.badBody {
        return Response(.badRequest)
      } catch let err {
        print("Unhandled Error:", err)
        return Response(.error)
      }
    }
  }
}

// Secure header defaults
//
// TODO: Incomplete. Flesh this out.

public enum HeaderSecurity {
  // Turn off feature
  case none
  // Secure headers for APIs
  case api
  // Secure headers for end-user browser websites
  case site
}

extension Builtin {
  static func wrapHeaderSecurity (_ opt: HeaderSecurity) -> Middleware {
    return { handler in
      return { request in
        switch opt {
        case .none: return try handler(request)
        // No api defaults implemented
        case .api: return try handler(request)
        case .site:
          let response = try handler(request)
          return response
            .setHeader("X-Content-Type-Options", "nosniff")
            .setHeader("X-Frame", "SAMEORIGIN")
            .setHeader("X-XSS-Protection", determineXssProtection(request.getHeader("user-agent")))
        }
      }
    }
  }
}

func determineXssProtection (_ userAgent: String?) -> String {
  if userAgent == nil {
    return "1; mode=block"
  }
  let re = try! RegExp("msie\\s*(\\d+)")
  if !re.test(userAgent!) {
    return "1; mode=block"
  }
  if let ieVersion = Double(re.replace(userAgent!, template: "$1")) {
    if ieVersion >= 9 {
      return "1; mode=block"
    }
  }
  return "0"
}
