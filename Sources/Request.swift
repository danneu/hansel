
import Foundation

// TODO: I'm planning on address being the socket address and
// a request.ip function returning the address or
// the final proxy in X-Forwarded-For if some sort of trust=true
// setting is configured

// TODO: Support byte array

enum RequestError: ErrorType {
  case InvalidUrl
}

public struct Request: Storable, HeaderList {
  public var url: String
  public var method: Method
  var headers: [Header]
  public var body: RequestBody
  var store: Store
  private var address: String
  private var nsurl: NSURL
  // Opts
  var trustProxy: Bool

  public init (
    method: Method = .Get,
    url: String = "/",
    body: [UInt8] = [],
    headers: [Header] = [],
    store: [String: Any] = [:],
    address: String = "",
    // Opts
    trustProxy: Bool = false
  ) throws {
      guard let nsurl = NSURL(string: url) else {
        throw RequestError.InvalidUrl
      }
      self.method = method
      self.url = url
      self.body = RequestBody(body)
      self.headers = headers
      self.store = store
      self.address = address
      self.nsurl = nsurl
      // Opts
      self.trustProxy = trustProxy
  }

  public var ip: String {
    if self.trustProxy {
      return self.getHeader("x-forwarded-for") ?? self.address
    } else {
      return self.address
    }
  }

  // TODO: Handle "example.com//////" and malicious paths,
  // possible fail in initializer
  public var path: String {
    return nsurl.path ?? "/"
  }

  public var query: [String: String] {
    if nsurl.query == nil { return [:] }
    return nsurl.query!
      |> Query.parse
  }

  // UPDATING REQUEST

  public func setMethod (method: Method) -> Request {
    var copy = self; copy.method = method; return copy
  }
}