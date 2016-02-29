
import Foundation

// Common to Request and Response

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
