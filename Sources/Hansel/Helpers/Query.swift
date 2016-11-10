
import Foundation

public struct Query {
  // input: foo=bar&cat=42
  public static func parse (_ input: String) -> [String: String] {
    return queryParser.run(input, withDefault: [:])
  }

  fileprivate static let queryParser: Parser<[String: String]> = {
    let key = P.`while` { $0 != "=" }
    let val = P.`while` { $0 != "&" }.map(Query.decode)
    let pair = P.tuple2(key, P.Char.char("=") *> val)
    let parser = P.sepBy(pair, sep: P.regex("&+"))
      .map(filter { !$0.0.isEmpty })
      .map(into([String: String]()))
    return parser
  }()

  fileprivate static func decode (_ input: String) -> String {
    return input
      |> Belt.urlDecode
      |> { try! RegExp("\\+").replace($0, template: " ") }
  }
}

