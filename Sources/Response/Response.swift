import Foundation
import Jay

public protocol Payload: Streamable, ETaggable {}
extension String: Payload {}

public struct Response: Storable, HeaderList, Tappable {
  public var status: Status = .Ok
  var headers: [Header] = []
  public var body: Payload = ByteArray()
  var store: Store = [:]

  // INITIALIZERS

  public init () {}

  public init (_ status: Status, headers: [Header] = []) {
    self.status = status
    self.headers = headers
  }

  // UPDATE RESPONSE

  public func setStatus (status: Status) -> Response {
    var copy = self; copy.status = status; return copy
  }

  private func setBody (newBody: Payload = ByteArray()) -> Response {
    var copy = self
    copy.body = newBody
    return copy
  }

  // SET RESPONSE BODY (HELPERS)

  public func none () -> Response {
    return self.setBody().deleteHeader("content-type")
  }

  public func text (str: String) -> Response {
    return self.setBody(str).setHeader("content-type", "text/plain")
  }

  public func html (x: HtmlConvertible) -> Response {
    return self.setBody(x.html()).setHeader("content-type", "text/html")
  }

  public func json (obj: Any) throws -> Response {
    let bytes = try Jay().dataFromJson(obj)
    return self.setBody(ByteArray(bytes)).setHeader("content-type", "application/json")
  }

  public func bytes (bytes: ByteArray, type: String?) -> Response {
    return self.setBody(bytes).setHeader("content-type", type)
  }

  public func stream (fileStream: FileStream, type: String?) -> Response {
    return self.setBody(fileStream).setHeader("content-type", type)
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
    let type = final.getHeader("content-type")

    return final
      .setHeader("content-type", type)
      .tap { r in
        if let len = final.body.length {
          return r.setHeader("content-length", String(len))
        } else {
          return r.setHeader("transfer-encoding", "chunked")
        }
      }
  }

  // REDIRECT

  // 301: .MovedPermanently
  // 302: .Found
  public func redirect (url: String, status: Status = .Found) -> Response {
    return self
      .setHeader("location", url)
      .setStatus(status.redirect() ? status : .Found)
  }

  // redirectBack(request)
  // redirectBack(request, "/login")
  public func redirectBack (request: Request, altUrl: String = "/") -> Response {
    let url = request.getHeader("referer") ?? altUrl
    return self.redirect(url)
  }
}
