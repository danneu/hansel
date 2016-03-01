
import Foundation

// This struct exists since it's apparently impossible to
// just extend Arrays of type [UInt8] in a way that Swift
// will understand the conformance.
// e.g. extension Array: Streamable where Element: UInt8 (compiler error)

// Wrapper around [UInt8], extends it to be streamable.
//
public struct ByteArray: Payload {
  var bytes: [UInt8] = []

  init () {}

  init (_ bytes: [UInt8]) {
    self.bytes = bytes
  }

  // ex: ByteArray("foo")
  init (_ str: String) {
    self.bytes = [UInt8](str.utf8)
  }
}

extension ByteArray: Streamable {
  mutating public func next () -> [UInt8]? {
    if self.bytes.isEmpty { return nil }
    let bytes = self.bytes
    self.bytes = []
    return bytes
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