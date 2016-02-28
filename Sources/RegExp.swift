
import Foundation

//
// Convenience wrapper around common regex functions
//

public class RegExp {
  let internalExpression: NSRegularExpression
  let pattern: String

  init (_ pattern: String) {
    self.pattern = pattern
    // TODO handle throws / bad patterns
    self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
  }

  // STRINGS

  func replace (input: String, template: String) -> String {
    return self.internalExpression.stringByReplacingMatchesInString(input, options: [], range: NSMakeRange(0, input.characters.count), withTemplate: template)
  }

  // MATCHES

  // Simply check if regex matches a string at all
  func test (input: String) -> Bool {
    return self.findFirst(input) != nil
  }

  // Returns first match
  func findFirst (input: String, start: Int = 0) -> NSTextCheckingResult? {
    let range = NSMakeRange(start, input.characters.count - start)
    return self.internalExpression.firstMatchInString(input, options: [], range: range)
  }

  // Returns all matches
  func findAll (input: String, start: Int = 0) -> [NSTextCheckingResult] {
    let range = NSMakeRange(start, input.characters.count - start)
    return self.internalExpression.matchesInString(input, options: [], range: range)
  }
}