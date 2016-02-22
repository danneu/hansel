
import Foundation

//
// Utility belt
//

public struct Belt {}

extension Belt {
  public static func escapeHtml (html: String) -> String {
    return html.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
      .stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
      .stringByReplacingOccurrencesOfString("'", withString: "&#39;")
      .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
      .stringByReplacingOccurrencesOfString(">", withString: "&gt;")
  }

  public static func trim (s: String) -> String {
    return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}

// PERCENT ENCODING

extension Belt {
  public static func urlEncode (s: String) -> String {
    return s.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? s
  }

  public static func urlDecode (s: String) -> String {
    return s.stringByRemovingPercentEncoding ?? s
  }
}

// FUNCTIONAL HELPERS
//
// Generic things things don't get namespaced behind Belt

// f >> g :: f(g(x))
infix operator >> { associativity left }
public func >> <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
  return { x in f(g(x)) }
}

// f << g :: g(f(x))
infix operator << { associativity left }
public func << <A, B, C>(f: A -> B, g: B -> C) -> A -> C {
  return { x in g(f(x)) }
}

public func identity<T> (a: T) -> T { return a }