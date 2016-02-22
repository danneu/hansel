
import Foundation

//
// REQUEST & RESPONSE COMMON
//

// STORABLE

typealias Store = [String: Any]

protocol Storable {
  var store: Store { get }
  func getStore (key: String) -> Any?
  func setStore (key: String, value: Any) -> Self
  func updateStore (key: String, fn: Any -> Any) -> Self
}

extension Storable {
  func getStore (key: String) -> Any? {
    return self.store[key.lowercaseString]
  }
}

// HEADERS

typealias Headers = [String: String]

protocol HasHeaders {
  var headers: Headers { get }
  func getHeader (key: String) -> String?
  func setHeader (key: String, value: String?) -> Self
  func updateHeader (key: String, fn: String? -> String?) -> Self
  func deleteHeader (key: String) -> Self
}

extension HasHeaders {
  func getHeader (key: String) -> String? {
    return self.headers[key.lowercaseString]
  }
  func updateHeader(key: String, fn: String? -> String?) -> Self {
    return self.setHeader(key, value: fn(self.getHeader(key)))
  }
}

// TAPPABLE

protocol Tappable {
  func tap (f: Self -> Self) -> Self
}

extension Tappable {
  func tap (f: Self -> Self) -> Self {
    return f(self)
  }
}