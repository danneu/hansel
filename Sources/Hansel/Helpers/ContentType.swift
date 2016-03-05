
import Foundation

//
// HTTP Content-Type header parser according to RFC 7231
//
// Usage:
//
//     try! ContentType.parse("image/svg+xml; charset=utf-8; foo=\"bar\"")
//     => ContentType(
//          type: "image/svg+xml", 
//          params: ["charset": "utf-8", "foo": "bar"]
//        )

//
// ERROR TYPES
//

enum ContentTypeError: ErrorType {
  case InvalidMediaType
  case InvalidParamFormat
  case InvalidParamKey
  case InvalidParamValue
}

//
// REGEXP PATTERNS
//

/**
* RegExp to match *( ";" parameter ) in RFC 7231 sec 3.1.1.1
*
* parameter     = token "=" ( token / quoted-string )
* token         = 1*tchar
* tchar         = "!" / "#" / "$" / "%" / "&" / "'" / "*"
*               / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
*               / DIGIT / ALPHA
*               ; any VCHAR, except delimiters
* quoted-string = DQUOTE *( qdtext / quoted-pair ) DQUOTE
* qdtext        = HTAB / SP / %x21 / %x23-5B / %x5D-7E / obs-text
* obs-text      = %x80-FF
* quoted-pair   = "\" ( HTAB / SP / VCHAR / obs-text )
*/

private let paramRe = try! RegExp("; *([!#$%&'\\*\\+\\-\\.\\^_`\\|~0-9A-Za-z]+) *= *(\"(?:[\\u000b\\u0020\\u0021\\u0023-\\u005b\\u005d-\\u007e\\u0080-\\u00ff]|\\\\[\\u000b\\u0020-\\u00ff])*\"|[!#$%&'\\*\\+\\-\\.\\^_`\\|~0-9A-Za-z]+) *")
private let textRe = try! RegExp("^[\\u000b\\u0020-\\u007e\\u0080-\\u00ff]+$")
private let tokenRe = try! RegExp("^[!#$%&'\\*\\+\\-\\.\\^_`\\|~0-9A-Za-z]+$")

/**
* RegExp to match quoted-pair in RFC 7230 sec 3.2.6
*
* quoted-pair = "\" ( HTAB / SP / VCHAR / obs-text )
* obs-text    = %x80-FF
*/

private let qescRe = try! RegExp("\\\\([\\u000b\\u0020-\\u00ff])")

/**
* RegExp to match chars that must be quoted-pair in RFC 7230 sec 3.2.6
*/

private let quoteRe = try! RegExp("([\\\\\"])")

/**
* RegExp to match type in RFC 6838
*
* media-type = type "/" subtype
* type       = token
* subtype    = token
*/

private let typeRe = try! RegExp("^[!#$%&'\\*\\+\\-\\.\\^_`\\|~0-9A-Za-z]+\\/[!#$%&'\\*\\+\\-\\.\\^_`\\|~0-9A-Za-z]+$")

public struct ContentType {
  // e.g. "image/svg+xml
  let type: String
  // e.g. ["charset": "utf-8"]
  let params: [String: String]

  // Note: type and params are not validated until calling
  // the format() method
  init (_ type: String, params: [String: String] = [:]) {
    self.type = type
    self.params = params
  }

  // Serialize struct into string for the Content-Type header
  func format () throws -> String {
    guard typeRe.test(self.type) else {
      throw ContentTypeError.InvalidMediaType
    }
    let sortedKeys = Array(self.params.keys).sort { $0 < $1 }
    var output: String = self.type
    for key in sortedKeys {
      guard tokenRe.test(key) else {
        throw ContentTypeError.InvalidParamKey
      }
      let quotedVal = try quoteValue(self.params[key]!)
      output += "; \(key)=\(quotedVal)"
    }

    return output
  }

  static func parse (input: String) throws -> ContentType {
    var type: String

    // the idx at which params start in the original string
    // if nil, then there are no params
    var paramsStart: Int? = nil

    if let idx = input.characters.indexOf(";") {
      let n = input.startIndex.distanceTo(idx)
      paramsStart = n
      type = Belt.trim((input as NSString).substringToIndex(n)).lowercaseString
    } else {
      type = Belt.trim(input).lowercaseString
    }

    if !typeRe.test(type) {
      throw ContentTypeError.InvalidMediaType
    }

    // type is valid, so now parse params

    if paramsStart == nil {
      return ContentType(type)
    }

    let matches = paramRe.findAll(input, start: paramsStart!)

    // Ensure there are no more characters after the final match
    if let finalMatch = matches.last {
      if input.characters.count != finalMatch.range.location + finalMatch.range.length {
        throw ContentTypeError.InvalidParamFormat
      }
    }

    let pairs = matches.map(getCapturedPair(input))

    var params: [String: String] = [:]
    for (key, val) in pairs {
      // only consider params with valid values
      if (tokenRe.test(val)) {
        params[key.lowercaseString] = val
      }
    }

    return ContentType(type, params: params)
  }
}

private func getCapturedPair (fullString: String) -> NSTextCheckingResult -> (String, String) {
  return { match in
    let key = (fullString as NSString).substringWithRange(match.rangeAtIndex(1))
    var val = (fullString as NSString).substringWithRange(match.rangeAtIndex(2))

    // if starts with quote, remove quotes and escapes
    if (val[val.startIndex] == "\"") {
      // e.g. "\"foo\"" -> "foo"
      val = val.substringWithRange(Range(start: val.startIndex.advancedBy(1), end: val.endIndex.advancedBy(-1)))
      val = qescRe.replace(val, template: "$1")
    }

    return (key, val)
  }
}

// Quote a param value if necessary
private func quoteValue (input: String) throws -> String {
  // no need
  if (tokenRe.test(input)) {
    return input
  }

  if (input.characters.count > 0 && !textRe.test(input)) {
    throw ContentTypeError.InvalidParamValue
  }

  let quoted = quoteRe.replace(input, template: "\\\\$1")
  return "\"\(quoted)\""
}

//
// Test-case reminders for when I have tests:
// - type string is downcased
// - param keys are downcased (case preserved in param vals)
//