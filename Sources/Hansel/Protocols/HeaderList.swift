
// Common to Request and Response

public typealias Header = (String, String)

public protocol HeaderList {
  var headers: [Header] { get set }
  func getHeader (key: String) -> String?
  func setHeader (key: String, _: String?) -> Self
  func deleteHeader (key: String) -> Self
  func appendHeader (key: String, _: String) -> Self
  func updateHeader (key: String, _: String? -> String?) -> Self
}

extension HeaderList {
  public var headers: [Header] {
    get { return self.headers }
    set (newHeaders) { self.headers = newHeaders }
  }

  public func getHeader (key: String) -> String? {
    var key = key.lowercaseString
    if key == "referrer" {
      key = "referer"
    }
    return self.headers.filter { $0.0.lowercaseString == key }.first?.1
  }

  public func appendHeader (key: String, _ val: String) -> Self {
    var new = self
    new.headers.append((key, val))
    return new
  }

  public func deleteHeader (key: String) -> Self {
    var new = self
    new.headers = new.headers.filter { $0.0.lowercaseString != key.lowercaseString }
    return new
  }

  // No-ops if val is nil.
  // Must use deleteHeader to actually delete one.
  public func setHeader (key: String, _ val: String?) -> Self {
    if val == nil {
      return self
    }
    return self.deleteHeader(key).appendHeader(key, val!)
  }

  // No-ops if fn(val) is nil.
  public func updateHeader (key: String, _ fn: String? -> String?) -> Self {
    return self.setHeader(key, fn(self.getHeader(key)))
  }
}