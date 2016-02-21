
import Foundation

//
// A namespace for built-in middleware and tools.

public struct Batteries {
  public static let logger: Middleware = wrapLogger
  public static let head: Middleware = wrapHead
}