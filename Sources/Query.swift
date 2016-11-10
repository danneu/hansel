
import Foundation

public struct Query {
  // input: foo=bar&cat=42
  public static func parse (input: String) -> [String: String] {
    let parts = splitAll("&", input)
    var output: [String: String] = [:]
    for (key, val) in parts.map(splitPair) {
      output[decode(key)] = decode(val)
    }
    return output
  }

  fileprivate static func decode (_ input: String) -> String {
    return input
      |> Belt.urlDecode
      |> { try! RegExp("\\+").replace($0, template: " ") }
  }
}


fileprivate func splitPair (input: String) -> (String, String) {
  let result = input
    .characters
    .split(separator: "=", maxSplits: 1)
    .map(String.init)
  let key = result.first ?? ""
  let val = result.count == 1 ? "" : (result.last ?? "") // handle missing "="
  return (key, val)
}

fileprivate func splitAll (_ separator: Character, _ input: String) -> [String] {
  return input
    .characters
    .split(separator: separator, maxSplits: 50)
    .map(String.init)
}
