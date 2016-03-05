
import Foundation

public protocol Streamable {
  mutating func next () -> [UInt8]?
  // let the callsite clean you up
  func open () -> Void
  func close () -> Void
  // nil length means it cant be known ahead of time
  // without consuming the stream. hmm, is this actually
  // a real case? need to look up how http byte ranges and
  // stuff works to see if this needs to remain optional
  var length: Int? { get }
}

extension String: Streamable {
  public mutating func next () -> [UInt8]? {
    if self.characters.count == 0 { return nil }
    let bytes = [UInt8](self.utf8)
    self = ""
    return bytes
  }

  public func open () -> Void {}
  public func close () -> Void {}

  public var length: Int? {
    return self.utf8.count
  }
}

extension NSInputStream: Streamable {
  public func next () -> [UInt8]? {
    // TODO: I suppose it's possible for the stream to be
    // opening yet have no bytes available yet. Need to make
    // this more robust
    guard self.hasBytesAvailable else {
      return nil
    }

    var buf = [UInt8](count: 16384, repeatedValue: 0)

    switch self.read(&buf, maxLength: buf.count) {
    case 0: // end of stream
      return nil
    case let (n) where n > 0: // success, n is the number of bytes read to buf
      // Trim off null bytes if the read did not fill the buffer
      if (n < buf.count) {
        buf = [UInt8](buf[0..<n])
      }
      return buf
    default: // failure, n < 0 -- TODO: Actually handle/throw this case
      return nil
    }
  }

  public var length: Int? {
    return nil
  }
}


