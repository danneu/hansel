import Foundation

public struct Response {
  public var status: Status = .Ok
  public var headers: [String: String] = [String: String]()
  public var body: ResponseBody = .None

  // INITIALIZERS

  public init () {}

  public init (status: Status, body: ResponseBody, headers: [String: String]) {
    self.status = status
    self.body = body
    self.headers = headers
  }

  public init (
    base: Response,
    status: Status? = nil,
    body: ResponseBody? = nil,
    headers: [String: String]? = nil
  ) {
    self.status = status ?? base.status
    self.headers = headers ?? base.headers
    self.body = body ?? base.body
  }

  public init (_ status: Status) {
    self.status = status
  }

  public init (_ body: ResponseBody) {
    self.body = body
  }

  // UPDATE RESPONSE

  // If value is nil, then no header is set
  public func setHeader (key: String, value: String?) -> Response {
    if value == nil {
      return self
    }
    var headers = self.headers
    headers[key.lowercaseString] = value
    return Response(base: self, headers: headers)
  }

  public func setHeader (key: String, value: Int?) -> Response {
    if value == nil {
      return self.deleteHeader(key)
    } else {
      return self.setHeader(key, value: String(value!))
    }
  }

  public func deleteHeader (key: String) -> Response {
    var headers = self.headers
    headers.removeValueForKey(key)
    return Response(base: self, headers: headers)
  }

  // SET RESPONSE BODY (HELPERS)

  public func none () -> Response {
    return Response(base: self, body: .None)
  }

  public func text (str: String) -> Response {
    return Response(base: self, body: .Text(str))
  }

  public func html (str: String) -> Response {
    return Response(base: self, body: .Html(str))
  }

  public func json (str: String) -> Response {
    return Response(base: self, body: .Json(str))
  }

  public func bytes (arr: [UInt8], type: String?) -> Response {
    return Response(base: self, body: .Bytes(arr, type))
  }

  // FINALIZE

  // This should be called right before the response is ready to
  // be sent. It ties up loose ends.
  public func finalize () -> Response {
    var final = self

    // If status expects empty body, then clear the body
    if final.status.emptyBody() {
      final = final.none()
    }

    let type = final.body.contentType()

    return final
      .setHeader("content-type", value: type)
      .setHeader("content-length", value: final.body.length())
  }
}

// HELPERS

// FIXME: Is there a simpler way to do a regex check?
func mightBeHtml (str: String) -> Bool {
  let regex = try! NSRegularExpression(pattern: "^\\s*<", options: [])

  let match = regex.numberOfMatchesInString(
    str,
    options: [],
    range: NSRange(location: 0, length: str.characters.count)
  )

  return match > 0
}

