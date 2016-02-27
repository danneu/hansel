import Foundation

public struct Response: Storable, HasHeaders, Tappable {
  public var status: Status = .Ok
  var headers: Headers = Headers()
  // multiHeaders is a place to put headers that can have multiple
  // values like Set-Cookie instead of overloading .headers
  public var multiHeaders: [String: [String]] = [:]
  public var body: ResponseBody = .None
  var store: Store = [:]

  // TODO: Any good ways to DRY up common logic between req and res?

  // INITIALIZERS

  public init () {}

  public init (status: Status, body: ResponseBody, headers: [String: String]) {
    self.status = status
    self.body = body
    self.headers = headers
  }

  init (status: Status, body: ResponseBody, headers: Headers, multiHeaders: [String: [String]], store: Store) {
    self.status = status
    self.body = body
    self.headers = headers
    self.multiHeaders = multiHeaders
    self.store = store
  }

  public init (
    base: Response,
    status: Status? = nil,
    body: ResponseBody? = nil,
    headers: [String: String]? = nil,
    multiHeaders: [String: [String]]? = nil,
    store: [String: Any]? = nil
  ) {
    self.status = status ?? base.status
    self.headers = headers ?? base.headers
    self.multiHeaders = multiHeaders ?? base.multiHeaders
    self.body = body ?? base.body
    self.store = store ?? base.store
  }

  public init (_ status: Status) {
    self.status = status
  }

  public init (_ body: ResponseBody) {
    self.body = body
  }

  // UPDATE RESPONSE

  // If value is nil, delete header
  public func setHeader (key: String, value: String?) -> Response {
    if value == nil {
      return self.deleteHeader(key)
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

  public func setStatus (status: Status) -> Response {
    return Response(base: self, status: status)
  }

  // MULTI-HEADERS

  public func getMultiHeader (key: String) -> [String] {
    return self.multiHeaders[key.lowercaseString] ?? [String]()
  }

  public func setMultiHeader (key: String, value: [String]) -> Response {
    var multiHeaders = self.multiHeaders
    multiHeaders[key.lowercaseString] = value
    return Response(base: self, multiHeaders: multiHeaders)
  }

  public func updateMultiHeader (key: String, fn: [String] -> [String]) -> Response {
    return self.setMultiHeader(key, value: fn(self.getMultiHeader(key)))
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
      .setHeader("content-length", value: String(final.body.length()))
  }

  // REDIRECT

  // TODO: Ensure status is one of the redirect statuses
  public func redirect (url: String, status: Status = .TempRedirect) -> Response {
    return self
      .setHeader("location", value: url)
      .setStatus(status)
  }

  // redirectBack(request)
  // redirectBack(request, "/login")
  public func redirectBack (request: Request, altUrl: String = "/") -> Response {
    let url = request.getHeader("referrer") ?? altUrl
    return self.redirect(url)
  }

  // STORE

  public func setStore (key: String, value: Any) -> Response {
    var store = self.store
    store[key] = value
    return Response(base: self, store: store)
  }

  public func updateStore (key: String, fn: Any -> Any) -> Response {
    var store = self.store
    store[key] = fn(store[key])
    return Response(base: self, store: store)
  }
}
