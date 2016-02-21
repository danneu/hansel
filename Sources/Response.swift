import Foundation

public struct Response {
  public let status: Status
  public let headers: [String: String]
  public let body: ResponseBody

  // INITIALIZERS

  // TODO: Clean up the init repetition. Look up 
  // convenience initializers or something.

  public init (
    _ status: Status = Status.Ok,
    body: ResponseBody = .None,
    headers: [String: String] = [String: String]()
    ) {
      self.status = status
      self.body = body
      self.headers = headers
  }

  public init (
    base: Response,
    body: ResponseBody? = nil,
    headers: [String: String]? = nil
    ) {
      self.status = base.status
      self.headers = headers ?? base.headers
      self.body = body ?? base.body
  }

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
    return self.setHeader(key, value: value == nil ? nil : String(value!))
  }

  public func deleteHeader (key: String) -> Response {
    var headers = self.headers
    headers.removeValueForKey(key)
    return Response(base: self, headers: headers)
  }

  // Response body helper inits

  public func none () -> Response {
    return Response(base: self, body: .None)
      .deleteHeader("content-type")
      .setHeader("content-length", value: "0")
  }

  public func text (str: String) -> Response {
    return Response(base: self, body: .Text(str))
      .setHeader("content-type", value: "text/plain")
  }

  public func html (str: String) -> Response {
    return Response(base: self, body: .Html(str))
      .setHeader("content-type", value: "text/html")
  }

  public func json (str: String) -> Response {
    return Response(base: self, body: .Json(str))
      .setHeader("content-type", value: "application/json")
  }

  public func bytes (arr: [UInt8], type: String? = "application/octet-stream") -> Response {
    return Response(base: self, body: .Bytes(arr))
      .setHeader("content-type", value: type!)
  }

  // This should be called right before the response is ready to
  // be sent. It ties up loose ends.
  public func finalize () -> Response {
    var final = self

    // If status expects empty body, then clear the body
    if final.status.emptyBody() {
      final = final.none()
    }

    return final
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

