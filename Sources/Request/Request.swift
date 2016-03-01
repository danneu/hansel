
import Foundation

enum RequestError: ErrorType {
  case InvalidUrl
}

public struct Request: Storable, HeaderList, Tappable {
  public var url: String
  public var method: Method
  public var headers: [Header]
  // basically a byte array with some convenience methods
  public var body: RequestBody
  var store: Store
  // remote connection ip address. use the #ip method.
  private var address: String
  private var nsurl: NSURL

  // options, not part of the request model
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
      // Ensure headers are trimmed
      self.headers = headers.map { (k, v) in (Belt.trim(k), Belt.trim(v))  }
      self.store = store
      self.address = address
      self.nsurl = nsurl
      // Opts
      self.trustProxy = trustProxy
  }

  // returns client ip address. uses x-forwarded-for if proxy is trusted.
  public var ip: String {
    if trustProxy {
      return getHeader("x-forwarded-for") ?? address
    } else {
      return address
    }
  }

  // returns host header. uses x-forwarded-host if proxy is trusted.
  public var host: String? {
    if self.trustProxy {
      return getHeader("x-forwarded-host") ?? getHeader("host")
    } else {
      return getHeader("host")
    }
  }

  // returns content-type without any of its parameters
  // Ex: "application/json; charset=utf-8" => "application/json"
  // returns nil on invalid content-type
  public var type: String? {
    let val = getHeader("content-type")
    if val == nil { return nil }
    do {
      return try ContentType.parse(val!).type
    } catch {
      return nil
    }
  }

  // URL PARTS

  // TODO: Handle "example.com//////" and malicious paths,
  // possible fail in initializer
  public var path: String {
    return nsurl.path ?? "/"
  }

  public var querystring: String {
    return nsurl.query ?? ""
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