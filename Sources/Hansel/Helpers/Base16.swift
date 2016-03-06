
import Foundation

public struct Base16 {
  public static func encode (input: Int) -> String {
    return String(input, radix: 16, uppercase: false)
  }
}