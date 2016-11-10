
import Foundation

#if os(Linux)
import POSIX
#endif

//
// Convenience wrapper around common regex functions
//

// API
//
// let re = try RegExp(pattern)
// re.replace("input string", template: "$1")
// re.test("input string") // true

// Linux:
//
// - NSRegularExpression is not implemented for Linux
// - The POSIXRegex wrapper library I'm using is too basic to
//   support any moderately complex expression I've tried, so
//   some functionality like ContentType.swift are just going
//   to be disabled until Linux gets support

open class RegExp {
#if os(Linux)
  let internalExpression: Regex
#else
  let internalExpression: NSRegularExpression
#endif

  let pattern: String

  // Initializer throws if pattern is invalid. You should
  // use `try!` unless the regex is dynamically generated by, say,
  // user-input.
  public init (_ pattern: String) throws {
    self.pattern = pattern
#if os(Linux)
    self.internalExpression = try Regex(pattern: pattern, options: .CaseInsensitive)
#else
    self.internalExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
#endif
  }

  // STRINGS

#if os(Linux)
  public func replace (input: String, template: String) -> String {
    return self.internalExpression.replace(input, withTemplate: template)
  }
#else
  open func replace (_ input: String, template: String) -> String {
    return self.internalExpression.stringByReplacingMatches(in: input, options: [], range: NSMakeRange(0, input.characters.count), withTemplate: template)
  }
#endif

  // MATCHES

#if os(Linux)
  public func test (input: String) -> Bool {
    return self.internalExpression.matches(input)
  }
#endif

#if os(OSX)
  // Simply check if regex matches a string at all
  open func test (_ input: String) -> Bool {
    return self.findFirst(input) != nil
  }

  // Note: The following are not public since there are too
  // many issues implementing them in Linux. So far the plan
  // is to just wait til Linux gets NSRegularExpression support.

  // Returns first match (not implemented in Linux)
  internal func findFirst (_ input: String, start: Int = 0) -> NSTextCheckingResult? {
    let range = NSMakeRange(start, input.characters.count - start)
    return self.internalExpression.firstMatch(in: input, options: [], range: range)
  }

  // Returns all matches
  internal func findAll (_ input: String, start: Int = 0) -> [NSTextCheckingResult] {
    let range = NSMakeRange(start, input.characters.count - start)
    return self.internalExpression.matches(in: input, options: [], range: range)
  }
#endif

  // GET MATCH RANGE

#if os(OSX)
  // to keep this compatible with linux's findFirstRange, we'll just return
  // a tuple of (start, end) positions
  /*open func findFirstRange (_ input: String) -> Range<String.Index>? {
    guard let match = findFirst(input) else {
      return nil
    }
    let matchStart = input.characters.index(input.startIndex, offsetBy: match.range.location)
    let matchEnd = .index(matchStart, offsetBy: match.range.length)
    return (matchStart ..< matchEnd)
  }*/
#endif

#if os(Linux)
  public func findFirstRange (input: String) -> (Int, Int)? {
    var string = input
    let maxMatches = 1

    var regexMatches = [regmatch_t](count: maxMatches, repeatedValue: regmatch_t())
    let result = regexec(&preg, string, regexMatches.count, &regexMatches, options.rawValue)

    if result == 1 { // returns 0 when match
      return nil
    }

    let start = Int(regexMatches[1].rm_so)
    let end = Int(regexMatches[1].rm_eo)

    return (start, end)
  }
#endif

  // UTILITY

  // Escapes special regex chars in string so that they become a literal search.
  //
  // escape("(a)") => "\(a\)"
  open static func escape (_ pattern: String) -> String {
    let list = "[-\\(\\)^$*+?.\\/\\\\|\\[\\]\\{\\}]"
    let escaped = try! RegExp("(\(list))").replace(pattern, template: "\\\\$1")
    return escaped
  }
}