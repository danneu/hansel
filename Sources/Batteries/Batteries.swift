
import Foundation

//
// A namespace for built-in middleware and tools.
//

public struct Batteries {
  public static let logger: Middleware = wrapLogger
  public static let head: Middleware = wrapHead
  public static let serveStatic: String -> Middleware = wrapServeStatic
  public static let notModified: (etag: Bool) -> Middleware = wrapNotModified
  // TODO: Cookies should be Opts -> Middleware (configurable)
  public static let cookies: Middleware = Cookie.wrapCookies
}