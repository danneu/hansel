
import Foundation

//
// REQUEST & RESPONSE COMMON
//

// HEADERS

public typealias Header = (String, String)

protocol HeaderList {
  var headers: [Header] { get set }
  func getHeader (key: String) -> String?
  func setHeader (key: String, val: String?) -> Self
  func deleteHeader (key: String) -> Self
  func appendHeader (key: String, val: String) -> Self
  func updateHeader (key: String, fn: String? -> String?) -> Self
}

extension HeaderList {
  var headers: [Header] {
    get { return self.headers }
    set (newHeaders) { self.headers = newHeaders }
  }

  func getHeader (key: String) -> String? {
    return self.headers.filter { $0.0.lowercaseString == key.lowercaseString }.first?.1
  }

  func appendHeader (key: String, val: String) -> Self {
    var new = self
    new.headers.append((key, val))
    return new
  }

  func deleteHeader (key: String) -> Self {
    var new = self
    new.headers = new.headers.filter { $0.0.lowercaseString != key.lowercaseString }
    return new
  }

  func setHeader (key: String, val: String?) -> Self {
    if val == nil {
      return self
    }
    return self.deleteHeader(key).appendHeader(key, val: val!)
  }

  func updateHeader (key: String, fn: String? -> String?) -> Self {
    return self.setHeader(key, val: fn(self.getHeader(key)))
  }
}

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

// TAPPABLE

protocol Tappable {
  func tap (f: Self -> Self) -> Self
}

extension Tappable {
  func tap (f: Self -> Self) -> Self {
    return f(self)
  }
}