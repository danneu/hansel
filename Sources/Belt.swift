
import Foundation

//
// Utility belt
//

public struct Belt {}

extension Belt {
  public static func escapeHtml (_ html: String) -> String {
    return html.replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "\"", with: "&quot;")
      .replacingOccurrences(of: "'", with: "&#39;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
  }

  public static func trim (_ s: String) -> String {
    return s.trimmingCharacters(in: CharacterSet.whitespaces)
  }
}

// PERCENT ENCODING

extension Belt {
  public static func urlEncode (_ s: String) -> String {
    return s.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? s
  }

  public static func urlDecode (_ s: String) -> String {
    return s.removingPercentEncoding ?? s
  }
}

extension Belt {
  public static func drop (_ n: Int, _ input: String) -> String {
    if input.isEmpty { return input }
    if n == 0 { return input }
    if n >= input.characters.count { return "" }
    return input.substring(from: input.characters.index(input.startIndex, offsetBy: n))
  }
}

// NSRANGE & RANGE

extension Belt {
  public static func rangeFromNSRange(_ s: String, _ nsRange: NSRange) -> Range<String.Index>? {
    let utf16 = s.utf16
    //let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
    guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex) else {
      return nil
    }

    //let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
    guard let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex) else {
      return nil
    }
    //let to16 = from16.

    if let from = String.Index(from16, within: s),
      let to = String.Index(to16, within: s) {
      return from ..< to
    }
    return nil
  }

}

// TIME INTERVAL HELPER
//
// Goal: various http concepts are expressed in seconds or
// milliseconds. it's easy to get wrong, and it's hard to notice
// when you do get it wrong. maybe i can use the type system to
// avoid these common errors.

// allow Int(ms), Int(secs)
extension Int {
  init(_ ms: Milliseconds) { self = ms.val }
  init(_ secs: Seconds) { self = secs.val }
}

protocol TimeConvertible {
  init (ms: Int)
  init (secs: Int)
  init (mins: Int)
  init (hrs: Int)
  init (days: Int)
  init (weeks: Int)
  init (months: Int)
}

public struct Milliseconds: CustomStringConvertible, TimeConvertible {
  let val: Int
  public var description: String { return String(val) }
  public init (_ val: Int) { self.val = val }
  // TIME CONVERTIBLE
  public init (ms: Int) { self.val = ms }
  public init (secs: Int) { self.val = secs * 1000 }
  public init (mins: Int) { self.val = mins * 60000 }
  public init (hrs: Int) { self.val = hrs * 3600000 }
  public init (days: Int) { self.val = days * 86400000 }
  public init (weeks: Int) { self.init(days: weeks * 7) }
  public init (months: Int) { self.init(days: months * 30) }
}

public struct Seconds: CustomStringConvertible, TimeConvertible {
  let val: Int
  public var description: String { return String(val) }
  public init (_ val: Int) { self.val = val }
  // TIME CONVERTIBLE
  public init (ms: Int) { self.val = ms / 1000 }
  public init (secs: Int) { self.val = secs }
  public init (mins: Int) { self.val = mins * 60 }
  public init (hrs: Int) { self.val = hrs * 3600 }
  public init (days: Int) { self.val = days * 86400 }
  public init (weeks: Int) { self.init(days: weeks * 7) }
  public init (months: Int) { self.init(days: months * 30) }
}

// FUNCTIONAL HELPERS
//
// Generic things things don't get namespaced behind Belt

public func identity <T> (_ a: T) -> T { return a }

// Composition
//
// TODO: Setting correct associativity and precedence on
// <</>>/<|/|> operators seems to mess up inference

precedencegroup ComposeRight { associativity: left }
precedencegroup ComposeLeft { associativity: right }

// f >> g == g(f(x))
infix operator >> : ComposeRight
public func >> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { x in g(f(x)) }
}

// f << g == f(g(x))
infix operator << : ComposeLeft
public func << <A, B, C> (f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
  return { x in f(g(x)) }
}

// Application

// precendence 0
precedencegroup ApplyRight { associativity: left }
precedencegroup ApplyLeft { associativity: right }

// x |> f == f(x)
//
// Ex: 8 |> toString << add42  //=> "50"
infix operator |> : ApplyRight
public func |> <A, B> (x: A, f: (A) -> B) -> B {
  return f(x)
}

// f <| x == f(x)
//
// Ex: toString << add42 <| 8  //=> "50"
infix operator <| : ApplyLeft
public func <| <A, B> (f: (A) -> B, x: A) -> B {
  return f(x)
}
