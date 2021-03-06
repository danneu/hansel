
import Foundation

// PUBLIC

// TODO: Is there a way to only apply these extensions if the middleware
// is actually used?

extension Batteries {
  // TODO: Cookies should be Opts -> Middleware (configurable)
  public static let cookies: Middleware = { handler in
    return { request in
      let response = try handler(cookieRequest(request))
      return cookieResponse(response)
    }
  }
}

extension Request {
  public var cookies: [String: String] {
    return self.getStore("cookies") as! [String: String]
  }

  public func setCookie (_ key: String, value: String) -> Request {
    return self.updateStore("cookies") { cookies in
      if var dict = cookies as? [String: String] {
        dict[key] = Belt.urlEncode(value)
        return dict
      } else {
        return [key: Belt.urlEncode(value)]
      }
    }
  }
}

public struct ResponseCookie {
  var key: String
  var value: String
  var path: String? = nil
  var expires: Date? = nil
  var maxAge: Seconds? = nil
  var domain: String? = nil
  var secure: Bool? = nil
  var httpOnly: Bool? = nil
  var firstPartyOnly: Bool? = nil

  init (_ key: String, value: String) {
    self.key = key
    self.value = value
  }
}

extension Response {
  public var cookies: [String: ResponseCookie] {
    if let value = self.store["cookies"] as? [String: ResponseCookie] {
      return value
    } else {
      return [:]
    }
  }

  public func setCookie (_ key: String, value: String) -> Response {
    return self.setCookie(key, opts: ResponseCookie(key, value: value))
  }

  public func setCookie (_ key: String, opts: ResponseCookie) -> Response {
    return self.updateStore("cookies") { cookies in
      if var dict = cookies as? [String: ResponseCookie] {
        dict[key] = opts
        return dict
      } else {
        return [key: opts]
      }
    }
  }
}



// TRANSFORMERS

let cookieRequest: (Request) -> Request = { request in
  var cookies: [String: String] = [:]
  if let val = request.getHeader("cookie") {
    cookies = parse(val)
  }
  return request.setStore("cookies", cookies)
}

let cookieResponse: (Response) -> Response = { response in
  var res = response
  for (k, v) in response.cookies {
    res = res.appendHeader("set-cookie", serialize(v))
  }
  return res
}

// PARSING

func parse (_ str: String) -> [String: String] {
  let pairs = str.characters.split(separator: ";")
    .map(String.init)
    .map(Belt.trim)
    .map(parsePair)

  var out: [String: String] = [:]
  for pair in pairs {
    if pair != nil {
      out[pair!.k] = pair!.v
    }
  }
  return out
}

// HELPERS

// foo=bar -> ("foo", "bar")
// foo="bar" -> ("foo", "bar")
//
// Returns nil on bad pair
func parsePair (_ s: String) -> (k: String, v: String)? {
  let pair: [String] = s.characters.split(separator: "=").map(String.init).map(Belt.trim)
  if pair.count != 2 {
    return nil
  }
  let (k, v) = (pair.first!, Belt.urlDecode(unwrapQuotes(pair.last!)))
  return (k, v)
}

func unwrapQuotes (_ s: String) -> String {
  #if os(Linux)
    let regex = try! RegularExpression(pattern: "(^\"|\"$)", options: [])
  #else
    let regex = try! NSRegularExpression(pattern: "(^\"|\"$)", options: [])
  #endif
  return regex.stringByReplacingMatches(in: s, options: .withoutAnchoringBounds, range: NSMakeRange(0, s.characters.count), withTemplate: "")
}

// SERIALIZE

func serialize (_ opts: ResponseCookie) -> String {
  var pairs = [opts.key + "=" + Belt.urlEncode(opts.value)]

  if let maxAge = opts.maxAge {
    pairs.append("max-age=\(maxAge)")
  }

  if let domain = opts.domain {
    pairs.append("domain=\(domain)")
  }

  if let path = opts.path {
    pairs.append("path=\(path)")
  }

  if let expires = opts.expires {
    pairs.append("expires=\(HttpDate.toString(expires))")
  }

  if let httpOnly = opts.httpOnly, httpOnly == true {
    pairs.append("HttpOnly")
  }

  if let secure = opts.secure, secure == true {
    pairs.append("Secure")
  }

  if let firstPartyOnly = opts.firstPartyOnly, firstPartyOnly == true {
    pairs.append("First-Party-Only")
  }

  return pairs.joined(separator: "; ")
}
