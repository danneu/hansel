
import Foundation

// PUBLIC

// TODO: Is there a way to only apply these extensions if the middleware
// is actually used?

extension Request {
  var cookies: [String: String] {
    return self.store["cookies"] as! [String: String]
  }

  func setCookie (key: String, value: String) -> Request {
   // return self.setStore("cookies", value: encode(value))
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

// TODO: Response cookies aren't just k/v anymore despite this code.
// They are configurable records, options objects.

extension Response {
  var cookies: [String: String] {
    if let value = self.store["cookies"] as? [String: String] {
      return value
    } else {
      return [:]
    }
  }

  func setCookie (key: String, value: String) -> Response {
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

internal struct Cookie {
  internal static let wrapCookies: Middleware = { handler in
    return { request in
      let response = handler(cookieRequest(request))
      // TODO: cookieResponse, map cookies to headers
      return response
    }
  }
}

// TRANSFORMERS

let cookieRequest: Request -> Request = { request in
  var cookies: [String: String] = [:]
  if let val = request.headers["cookie"] {
    cookies = parse(val)
  }
  return request.setStore("cookies", value: cookies)
}

// PARSING

func parse (str: String) -> [String: String] {
  let pairs = str.characters.split(";")
    .map(String.init)
    .map(trim)
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
  let pair: [String] = s.characters.split("=").map(String.init).map(trim)
  if pair.count != 2 {
    return nil
  }
  let (k, v) = (pair.first!, Belt.urlDecode(unwrapQuotes(pair.last!)))
  return (k, v)
}

func trim (s: String) -> String {
  return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}

func unwrapQuotes (s: String) -> String {
  let regex = try! NSRegularExpression(pattern: "(^\"|\"$)", options: [])
  return regex.stringByReplacingMatchesInString(s, options: .WithoutAnchoringBounds, range: NSMakeRange(0, s.characters.count), withTemplate: "")
}
