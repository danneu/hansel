
import Foundation

public struct Base64 {
  public static func encode (input: [UInt8], padding: Bool) -> String {
    let data = NSData(bytes: input, length: input.count)
    let string = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    return padding ? string : padless(string)
  }
}

// Strip Base64 string padding
private func padless (input: String) -> String {
  return try! RegExp("=+$").replace(input, template: "")
}