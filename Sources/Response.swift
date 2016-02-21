import Foundation

public struct Response {
  public let status: Status
  public let headers: [String: String]
  public let body: String

  // INITIALIZERS

  // TODO: Clean up the init repetition. Look up 
  // convenience initializers or something.

  public init (_ status: Status) {
    self.body = ""
    self.status = status
    self.headers = [String: String]()
  }

  public init (_ body: String) {
    self.body = body
    self.status = .Ok
    self.headers = [String: String]()
  }

  public init (
    status: Status = Status.Ok,
    body: String = "",
    headers: [String: String] = [String: String]()
    ) {
      self.status = status
      self.body = body
      self.headers = headers
  }

  public init (
    base: Response,
    body: String? = nil,
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

  public func deleteHeader (key: String) -> Response {
    var headers = self.headers
    headers.removeValueForKey(key)
    return Response(base: self, headers: headers)
  }

  public func setBody (newBody: String) -> Response {
    return Response(base: self, body: newBody)
  }

  // This should be called right before the response is ready to
  // be sent. It ties up loose ends.
  public func finalize () -> Response {
    var body = self.body

    // If status expects empty body, then clear the body
    if self.status.emptyBody() {
      body = ""
    } else if body.isEmpty {
      // Or set body to a default if it is empty on a status
      // that should have one
      body = self.status.phrase
    }

    let length = body.utf8.count

    // Guess content-type if it's not already set
    let type = self.headers["content-type"]
      ?? (mightBeHtml(body) ? "text/html" : "text/plain")

    return self
      .setBody(body)
      .setHeader("content-length", value: String(length))
      .setHeader("content-type", value: type)
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

