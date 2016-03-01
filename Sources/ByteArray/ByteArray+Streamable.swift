
import Foundation

extension ByteArray: Streamable {
  mutating public func next () -> [UInt8]? {
    if self.bytes.isEmpty { return nil }
    let bytes = self.bytes
    self.bytes = []
    return bytes
    // return self.bytes.removeAtIndex(self.bytes.startIndex)
  }

  public func open () -> Void {}
  public func close () -> Void {}

  public var length: Int? {
    return bytes.count
  }
}

// GRAVEYARD

//extension Array: Streamable where Element: UInt8 {
//  func next () -> UInt8? {
//    if self.isEmpty { return nil }
//    return self.removeAtIndex(self.startIndex)
//  }
//}

//extension _ArrayType where Generator.Element == UInt8 {
//  mutating func next () -> UInt8? {
//    if self.isEmpty { return nil }
//    return self.removeAtIndex(self.startIndex)
//  }
//}