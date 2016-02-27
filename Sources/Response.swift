import Foundation

public struct Response: Storable, HeaderList, Tappable {
  public var status: Status = .Ok
  var headers: [Header] = []
  public var body: ResponseBody = .None
  var store: Store = [:]

  // TODO: Any good ways to DRY up common logic between req and res?

  // INITIALIZERS

  public init () {}

  public init (status: Status, body: ResponseBody, headers: [Header]) {
    self.status = status
    self.body = body
    self.headers = headers
  }

  init (status: Status, body: ResponseBody, headers: [Header], store: Store) {
    self.status = status
    self.body = body
    self.headers = headers
    self.store = store
  }

  public init (
    base: Response,
    status: Status? = nil,
    body: ResponseBody? = nil,
    headers: [Header]? = nil,
    store: [String: Any]? = nil
  ) {
    self.status = status ?? base.status
    self.headers = headers ?? base.headers
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

  public func setStatus (status: Status) -> Response {
    return Response(base: self, status: status)
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
      .setHeader("content-type", val: type)
      .setHeader("content-length", val: String(final.body.length()))
  }

  // REDIRECT

  // TODO: Ensure status is one of the redirect statuses
  public func redirect (url: String, status: Status = .TempRedirect) -> Response {
    return self
      .setHeader("location", val: url)
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
