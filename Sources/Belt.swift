
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

extension Belt {
  static func drop (n: Int, _ input: String) -> String {
    if input.isEmpty { return input }
    if n == 0 { return input }
    if n >= input.characters.count { return "" }
    return input.substringFromIndex(input.startIndex.advancedBy(n))
  }
}

// FUNCTIONAL HELPERS
//
// Generic things things don't get namespaced behind Belt

public func identity <T> (a: T) -> T { return a }

// Composition
//
// TODO: Setting correct associativity and precedence on
// <</>>/<|/|> operators seems to mess up inference

// f >> g == g(f(x))
infix operator >> { associativity left }
public func >> <A, B, C> (f: A -> B, g: B -> C) -> A -> C {
  return { x in g(f(x)) }
}

// f << g == f(g(x))
infix operator << { associativity right }
public func << <A, B, C> (f: B -> C, g: A -> B) -> A -> C {
  return { x in f(g(x)) }
}

// Application

// x |> f == f(x)
//
// Ex: 8 |> toString << add42  //=> "50"
infix operator |> { associativity left precedence 0 }
public func |> <A, B> (x: A, f: A -> B) -> B {
  return f(x)
}

// f <| x == f(x)
//
// Ex: toString << add42 <| 8  //=> "50"
infix operator <| { associativity right precedence 0 }
public func <| <A, B> (f: A -> B, x: A) -> B {
  return f(x)
}