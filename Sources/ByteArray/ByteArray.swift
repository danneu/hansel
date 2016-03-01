
import Foundation

// This struct exists since it's apparently impossible to
// just extend Arrays of type [UInt8] in a way that Swift
// will understand the conformance.
// e.g. extension Array: Streamable where Element: UInt8 (compiler error)

// Wrapper around [UInt8], extends it to be streamable.
//
public struct ByteArray {
  var bytes: [UInt8] = []

  init () {}

  init (_ bytes: [UInt8]) {
    self.bytes = bytes
  }

  // ex: ByteArray("foo".utf8)
  init (_ view: String.UTF8View) {
    self.bytes = [UInt8](view)
  }

  // ex: ByteArray("foo")
  init (_ str: String) {
    self.bytes = [UInt8](str.utf8)
  }
}
