
import Foundation
import CryptoSwift

//
// Generate ETags
//
// Currently only generates them from byte arrays.
//
// TODO: Support weak ETags from FS stat data (mtime and size)
//

struct ETag {
  static func generate (bytes: [UInt8]) -> String {
    if bytes.isEmpty {
      return "\"0-1B2M2Y8AsgTpgAmY7PhCfg\""
    }

    let hash64 = padless << base64 <| Hash.md5(bytes).calculate()
    let len = bytes.count

    return "\"\(base16(len))-\(hash64)\""
  }

  static func generate (input: String) -> String {
    return generate([UInt8](input.utf8))
  }
}

// HELPERS

private func base16 (n: Int) -> String {
  return String(n, radix: 16, uppercase: false)
}

private func base64 (input: [UInt8]) -> String {
  let data = NSData(bytes: input, length: input.count)
  return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
}

// Strip Base64 string padding
private func padless (input: String) -> String {
  return try! RegExp("=+$").replace(input, template: "")
}