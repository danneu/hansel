import Foundation

public struct Response: Storable, HeaderList {
  public var status: Status = .Ok
  var headers: [Header] = []
  public var body: ResponseBody = .None
  var store: Store = [:]

  // INITIALIZERS

  public init () {}

  public init (status: Status, body: ResponseBody, headers: [Header]) {
    self.status = status
    self.body = body
    self.headers = headers
  }

  public init (_ status: Status) {
    self.status = status
  }

  public init (_ body: ResponseBody) {
    self.body = body
  }

  // UPDATE RESPONSE

  public func setStatus (status: Status) -> Response {
    var copy = self; copy.status = status; return copy
  }

  public func setBody (body: ResponseBody) -> Response {
    var copy = self; copy.body = body; return copy
  }

  // SET RESPONSE BODY (HELPERS)

  public func none () -> Response {
    return self.setBody(.None)
  }

  public func text (str: String) -> Response {
    return self.setBody(.Text(str))
  }

  public func html (str: String) -> Response {
    return self.setBody(.Html(str))
  }

  public func json (str: String) -> Response {
    return self.setBody(.Json(str))
  }

  public func bytes (arr: [UInt8], type: String?) -> Response {
    return self.setBody(.Bytes(arr, type))
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

    let type = final.body.contentType()

    return final
      .setHeader("content-type", type)
      .setHeader("content-length", String(final.body.length()))
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
    let url = request.getHeader("referrer") ?? altUrl
    return self.redirect(url)
  }
}
