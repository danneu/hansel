
import Foundation

// TODO: I'm planning on address being the socket address and
// a request.ip function returning the address or
// the final proxy in X-Forwarded-For if some sort of trust=true
// setting is configured

// TODO: Clean up init spam

// TODO: Support byte array

public struct Request: Storable, HeaderList {
  public let url: String
  public let method: Method
  var headers: [Header]
  public let body: RequestBody
  var store: Store
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
    body: RequestBody = .None,
    headers: [Header] = [],
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
    body: RequestBody? = nil,
    headers: [Header]? = nil,
    store: [String: Any]? = nil
    ) {
      self.url = base.url
      self.method = method ?? base.method
      self.address = base.address
      self.headers = headers ?? base.headers
      self.body = body ?? base.body
      self.store = store ?? base.store
  }
}