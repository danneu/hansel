
import Foundation

// TODO: I'm planning on address being the socket address and
// a request.ip function returning the address or
// the final proxy in X-Forwarded-For if some sort of trust=true
// setting is configured

// TODO: Support byte array

public struct Request: Storable, HeaderList {
  public var url: String
  public var method: Method
  var headers: [Header]
  public var body: RequestBody
  var store: Store
  public var address: String
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
    store: [String: Any] = [:],
    address: String = ""
    ) {
      self.method = method
      self.url = url
      self.body = body
      self.headers = headers
      self.store = store
      self.address = address
  }

  // UPDATING REQUEST

  public func setMethod (method: Method) -> Request {
    var copy = self; copy.method = method; return copy
  }
}