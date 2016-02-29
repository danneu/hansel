
import Foundation

//
// REQUEST & RESPONSE COMMON
//

// HEADERS

public typealias Header = (String, String)

protocol HeaderList {
  var headers: [Header] { get set }
  func getHeader (key: String) -> String?
  func setHeader (key: String, _: String?) -> Self
  func deleteHeader (key: String) -> Self
  func appendHeader (key: String, _: String) -> Self
  func updateHeader (key: String, _: String? -> String?) -> Self
}

extension HeaderList {
  var headers: [Header] {
    get { return self.headers }
    set (newHeaders) { self.headers = newHeaders }
  }

  func getHeader (key: String) -> String? {
    var key = key.lowercaseString
    if key == "referrer" {
      key = "referer"
    }
    return self.headers.filter { $0.0.lowercaseString == key }.first?.1
  }

  func appendHeader (key: String, _ val: String) -> Self {
    var new = self
    new.headers.append((key, val))
    return new
  }

  func deleteHeader (key: String) -> Self {
    var new = self
    new.headers = new.headers.filter { $0.0.lowercaseString != key.lowercaseString }
    return new
  }

  // No-ops if val is nil. 
  // Must use deleteHeader to actually delete one.
  func setHeader (key: String, _ val: String?) -> Self {
    if val == nil {
      return self
    }
    return self.deleteHeader(key).appendHeader(key, val!)
  }

  // No-ops if fn(val) is nil. 
  func updateHeader (key: String, _ fn: String? -> String?) -> Self {
    return self.setHeader(key, fn(self.getHeader(key)))
  }
}

// STORABLE

typealias Store = [String: Any]

protocol Storable {
  var store: Store { get set }
  func getStore (key: String) -> Any?
  func setStore (key: String, _: Any) -> Self
  func updateStore (key: String, _: Any -> Any) -> Self
}

extension Storable {
  var store: Store {
    get { return self.store }
    set (newStore) { self.store = store }
  }

  func getStore (key: String) -> Any? {
    return self.store[key]
  }

  func setStore (key: String, _ val: Any) -> Self {
    var new = self
    new.store[key] = val
    return new
  }

  func updateStore (key: String, _ fn: Any -> Any) -> Self {
    return self.setStore(key, fn(self.getStore(key)))
  }
}