
import Foundation

// PUBLIC

// TODO: Is there a way to only apply these extensions if the middleware
// is actually used?

extension Batteries {
  // TODO: Cookies should be Opts -> Middleware (configurable)
  static let cookies: Middleware = { handler in
    return { request in
      let response = handler(cookieRequest(request))
      return cookieResponse(response)
    }
  }
}

extension Request {
  var cookies: [String: String] {
    return self.getStore("cookies") as! [String: String]
  }

  func setCookie (key: String, value: String) -> Request {
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

typealias Seconds = Int

struct ResponseCookie {
  var key: String
  var value: String
  var path: String? = nil
  var expires: NSDate? = nil
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
  var cookies: [String: ResponseCookie] {
    if let value = self.store["cookies"] as? [String: ResponseCookie] {
      return value
    } else {
      return [:]
    }
  }

  func setCookie (key: String, value: String) -> Response {
    return self.setCookie(key, opts: ResponseCookie(key, value: value))
  }

  func setCookie (key: String, opts: ResponseCookie) -> Response {
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

let cookieRequest: Request -> Request = { request in
  var cookies: [String: String] = [:]
  if let val = request.getHeader("cookie") {
    cookies = parse(val)
  }
  return request.setStore("cookies", cookies)
}

let cookieResponse: Response -> Response = { response in
  var res = response
  for (k, v) in response.cookies {
    res = res.appendHeader("set-cookie", serialize(v))
  }
  return res
}

// PARSING

func parse (str: String) -> [String: String] {
  let pairs = str.characters.split(";")
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
func parsePair (s: String) -> (k: String, v: String)? {
  let pair: [String] = s.characters.split("=").map(String.init).map(Belt.trim)
  if pair.count != 2 {
    return nil
  }
  let (k, v) = (pair.first!, Belt.urlDecode(unwrapQuotes(pair.last!)))
  return (k, v)
}

func unwrapQuotes (s: String) -> String {
  let regex = try! NSRegularExpression(pattern: "(^\"|\"$)", options: [])
  return regex.stringByReplacingMatchesInString(s, options: .WithoutAnchoringBounds, range: NSMakeRange(0, s.characters.count), withTemplate: "")
}

// SERIALIZE

func serialize (opts: ResponseCookie) -> String {
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

  if let httpOnly = opts.httpOnly where httpOnly == true {
    pairs.append("HttpOnly")
  }

  if let secure = opts.secure where secure == true {
    pairs.append("Secure")
  }

  if let firstPartyOnly = opts.firstPartyOnly where firstPartyOnly == true {
    pairs.append("First-Party-Only")
  }

  return pairs.joinWithSeparator("; ")
}