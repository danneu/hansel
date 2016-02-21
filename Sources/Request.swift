
import Foundation

// TODO: I'm planning on address being the socket address and
// a request.ip function returning the address or
// the final proxy in X-Forwarded-For if some sort of trust=true
// setting is configured

// TODO: Clean up init spam

public struct Request {
  public let url: String
  public let method: Method
  public let headers: [String: String]
  public let body: String
  public let store: [String : Any]
  public let address: String
  public var path: String {
    get {
      // TODO: Handle bad paths. 
      // For example: NSURL(string: "//").path == nil
      return NSURL(string: self.url)!.path ?? "/"
    }
  }

  public init (
    method: Method = .Get,
    url: String = "/",
    body: String = "",
    headers: [String: String] = [String: String](),
    store: [String: Any] = [String: Any](),
    address: String = ""
    ) {
      self.method = method
      self.url = url
      self.body = body
      self.headers = headers
      self.store = store
      self.address = address
  }

  // merge into an existing base request
  public init (
    base: Request,
    method: Method? = nil,
    body: String? = nil,
    headers: [String: String]? = nil,
    store: [String: Any]? = nil
    ) {
      self.url = base.url
      self.method = method ?? base.method
      self.address = base.address
      self.headers = headers ?? base.headers
      self.body = body ?? base.body
      self.store = store ?? base.store
  }

  // QUERYING

  public func getHeader (key: String) -> String? {
    return self.headers[key.lowercaseString]
  }

  // UPDATING

  public func setHeader (key: String, value: String) -> Request {
    var headers = self.headers
    headers[key.lowercaseString] = value
    return Request(base: self, headers: headers)
  }

  public func setStore (key: String, value: Any) -> Request {
    var store = self.store
    store[key] = value
    return Request(base: self, store: store)
  }

  public func updateStore (key: String, fn: Any -> Any) -> Request {
    var store = self.store
    store[key] = fn(store[key])
    return Request(base: self, store: store)
  }

  public func getStore (key: String) -> Any? {
    return self.store[key]
  }
}