import Foundation
import Jay

public struct Response: Storable, HeaderList {
  public var status: Status = .Ok
  var headers: [Header] = []
  public var body: [UInt8] = []
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

  private func setBody (bytes: [UInt8]) -> Response {
    var copy = self; copy.body = bytes; return copy
  }
  private func setBody (str: String) -> Response {
    var copy = self; copy.body = [UInt8](str.utf8); return copy
  }

  // SET RESPONSE BODY (HELPERS)

  public func none () -> Response {
    return self.setBody([]).deleteHeader("content-type")
  }

  public func text (str: String) -> Response {
    return self.setBody(str).setHeader("content-type", "text/plain")
  }

  public func html (x: HtmlConvertible) -> Response {
    return self.setBody(x.html()).setHeader("content-type", "text/html")
  }

  // TODO: Somehow type this so it can't fail. I don't
  // want user to have to `try`.
  public func json (obj: Any) -> Response {
    let bytes = try! Jay().dataFromJson(obj)
    return self.setBody(bytes).setHeader("content-type", "application/json")
  }

  public func bytes (bytes: [UInt8], type: String?) -> Response {
    return self.setBody(bytes).setHeader("content-type", type)
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
      .setHeader("content-length", String(final.body.count))
  }

  // REDIRECT

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
