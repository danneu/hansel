import Foundation
import Jay

public protocol JsonEncodable {
  func json () -> JSON
}

public protocol Payload: Streamable, ETaggable {}
extension String: Payload {}

public struct Response: Storable, HeaderList, Tappable {
  public var status: Status = .ok
  public var headers: [Header] = []
  public var body: Payload = ByteArray()
  public var store: Store = [:]

  // INITIALIZERS

  public init () {}

  public init (_ status: Status, headers: [Header] = []) {
    self.status = status
    self.headers = headers
  }

  // UPDATE RESPONSE

  public func setStatus (_ status: Status) -> Response {
    var copy = self; copy.status = status; return copy
  }

  fileprivate func setBody (_ newBody: Payload = ByteArray()) -> Response {
    var copy = self
    copy.body = newBody
    return copy
  }

  // SET RESPONSE BODY (HELPERS)

  public func none () -> Response {
    return self.setBody().deleteHeader("Content-Type")
  }

  public func text (_ str: String) -> Response {
    return self.setBody(str).setHeader("Content-Type", "text/plain")
  }

  public func html (_ x: HtmlConvertible) -> Response {
    return self.setBody(x.html()).setHeader("Content-Type", "text/html")
  }

  public func json (_ body: JsonEncodable) throws -> Response {
    let bytes = try Jay().dataFromJson(any: body.json())
    return self.setBody(ByteArray(bytes)).setHeader("Content-Type", "application/json")
  }

  public func json (_ obj: Any) throws -> Response {
    let bytes = try Jay().dataFromJson(any: obj)
    return self.setBody(ByteArray(bytes)).setHeader("Content-Type", "application/json")
  }

  public func bytes (_ bytes: [UInt8], type: String?) -> Response {
    return self.setBody(ByteArray(bytes)).setHeader("Content-Type", type)
  }

  public func stream (_ fileStream: FileStream, type: String?) -> Response {
    return self.setBody(fileStream).setHeader("Content-Type", type)
  }

  // FINALIZE

  // This should be called right before the response is ready to
  // be sent. It ties up loose ends.
  public func finalize () -> Response {
    var final = self

    // If status expects empty body, then clear the body
    if final.status.empty() {
      final = final.none()
    }

    // Note: Think about ways to ensure no body vs content-type
    // desyncs
    let type = final.getHeader("Content-Type")

    return final
      .setHeader("Content-Type", type)
      .tap { r in
        if let len = final.body.length {
          return r.setHeader("Content-Length", String(len))
        } else {
          return r.setHeader("Transfer-Encoding", "chunked")
        }
      }
  }

  // REDIRECT

  // 301: .MovedPermanently
  // 302: .Found
  public func redirect (_ url: String, status: Status = .found) -> Response {
    return self
      .setHeader("Location", url)
      .setStatus(status.redirect() ? status : .found)
  }

  // redirectBack(request)
  // redirectBack(request, "/login")
  public func redirectBack (_ request: Request, altUrl: String = "/") -> Response {
    let url = request.getHeader("Referer") ?? altUrl
    return self.redirect(url)
  }
}
