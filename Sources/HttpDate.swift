
import Foundation

// HttpDate
//
// Convenience functions for parsing / serializing
// between header strings (like Last-Modified) and
// NSDate

// Example date: "Wed, 15 Nov 1995 04:58:08 GMT"
// Formatter template codes: http://userguide.icu-project.org/formatparse/datetime#TOC-SimpleDateFormat
// HTTP date spec: https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1

public struct HttpDate {
  // The docs say NSDateFormatter is thread safe
  fileprivate static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    return formatter
  }()

  public static func fromString (_ input: String) -> Date? {
    return formatter.date(from: input)
  }

  public static func toString (_ date: Date) -> String {
    return formatter.string(from: date)
  }
}
