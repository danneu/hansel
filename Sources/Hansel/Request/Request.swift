
import Foundation
import Jay

// TODO: Consolidate errors and actually come up with a game
// plan.
public enum RequestError: ErrorType {
  case InvalidUrl
  // body doesn't convert to the expected format
  case BadBody
}

public struct Request: Storable, HeaderList, Tappable {
  public var url: String
  public var method: Method
  public var headers: [Header]
  // basically a byte array with some convenience methods
  public var body: RequestBody
  public var store: Store
  // remote connection ip address. use the #ip method.
  private var address: String
  public var nsurl: NSURL

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
      self.headers = headers
      self.store = store
      self.address = address
      self.nsurl = nsurl
      // Opts
      self.trustProxy = trustProxy
  }

  // returns client ip address. uses x-forwarded-for if proxy is trusted.
  public var ip: String {
    if trustProxy {
      return getHeader("X-Forwarded-For") ?? address
    } else {
      return address
    }
  }

  // returns host header. uses x-forwarded-host if proxy is trusted.
  public var host: String? {
    if self.trustProxy {
      return getHeader("X-Forwarded-Host") ?? getHeader("Host")
    } else {
      return getHeader("Host")
    }
  }

// ContentType disabled til Linux gets a good regex impl
#if os(OSX)
  // returns content-type without any of its parameters
  // Ex: "application/json; charset=utf-8" => Optional("application/json")
  public var type: String? {
    guard let val = getHeader("Content-Type") else {
      return nil
    }
    do {
      return try ContentType.parse(val).type
    } catch {
      return nil
    }
  }
#endif

// ContentType disabled til Linux gets a good regex impl
#if os(OSX)
  // Ex: "application/json; charset=utf-8" => Optional("utf-8")
  public var charset: String? {
    guard let val = getHeader("Content-Type") else {
      return nil
    }
    do {
      return try ContentType.parse(val).params["charset"]
    } catch {
      return nil
    }
  }
#endif

  // URL PARTS

  // TODO: Handle "example.com//////" and malicious paths,
  // possible fail in initializer
  //
  // Using CFURL over NSURL because CFURL's path:
  // - Includes trailing slash
  // - Does not decode percent-encoding
  public var path: String {
    // Doesn't work on Linux:
    // return CFURLCopyPath(nsurl as CFURL) as String

    return url.split(1, separator: "?").first ?? "/"
  }

  public var querystring: String {
    return nsurl.query ?? ""
  }

  public var query: [String: String] {
    if nsurl.query == nil { return [:] }
    return nsurl.query!
      |> Query.parse
  }

  // BODY CONVERSION (proxied to RequestBody for convenience)

  public func utf8 () throws -> String {
    return try body.utf8()
  }

  public func json () throws -> JsonValue {
    return try body.json()
  }

  public func json <T> (decoder: Decoder<T>) throws -> T {
    return try body.json(decoder)
  }

  // UPDATING REQUEST

  public func setMethod (method: Method) -> Request {
    var copy = self; copy.method = method; return copy
  }
}