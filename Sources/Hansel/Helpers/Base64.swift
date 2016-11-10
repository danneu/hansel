
import Foundation

public struct Base64 {
  public static func encode (_ input: [UInt8], padding: Bool) -> String {
    let data = Data(bytes: UnsafePointer<UInt8>(input), count: input.count)
    let string = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
    return padding ? string : padless(string)
  }
}

// Strip Base64 string padding
private func padless (_ input: String) -> String {
  return try! RegExp("=+$").replace(input, template: "")
}
