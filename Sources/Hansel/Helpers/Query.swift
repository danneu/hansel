
import Foundation

public struct Query {
  // input: foo=bar&cat=42
  //func parse (input: String) -> [String: String] {
  public static func parse (input: String) -> [String: String] {
    let parts = splitAll("&", input)
    var output: [String: String] = [:]
    for (key, val) in parts.map(splitPair) {
      output[decode(key)] = decode(val)
    }
    return output
  }
}

private func splitPair (input: String) -> (String, String) {
  let result = input
    .characters
    .split("=", maxSplit: 1, allowEmptySlices: false)
    .map(String.init)
  let key = result.first ?? ""
  let val = result.count == 1 ? "" : (result.last ?? "") // handle missing "="
  return (key, val)
}

private func splitAll (separator: Character, _ input: String) -> [String] {
  return input
    .characters
    .split(separator, maxSplit: 50, allowEmptySlices: false)
    .map(String.init)
}

private func decode (input: String) -> String {
  return input
    |> Belt.urlDecode
    |> { try! RegExp("\\+").replace($0, template: " ") }
}