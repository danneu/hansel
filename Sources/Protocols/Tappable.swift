
import Foundation

// Common to Request and Response

// Tappable endows things with a function that makes it
// easy to chain transformations together.
//
// Ex:
//
//     response
//       .setHeader(...)
//       .tap { condition ? $0.doSomething() : $0 }
//       .tap { transform($0) }
//

public protocol Tappable {
  func tap (f: Self -> Self) -> Self
}

extension Tappable {
  public func tap (f: Self -> Self) -> Self {
    return f(self)
  }
}