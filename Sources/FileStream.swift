
import Foundation

public struct FileStream: Payload {
  var modifiedAt: NSDate
  var byteSize: Int
  var stream: NSInputStream

  // seconds since epoch
  var mtime: Int {
    return Int(modifiedAt.timeIntervalSince1970)
  }

  // TODO: Throw on fail
  init (_ path: String, byteSize: Int, modifiedAt: NSDate) {
    let stream: NSInputStream = NSInputStream(fileAtPath: path)!
    self.stream = stream
    self.byteSize = byteSize
    self.modifiedAt = modifiedAt
  }
}

extension FileStream: Streamable {
  public func next () -> [UInt8]? {
    let bytes = stream.next()
    return bytes
  }

  public func open () -> Void {
    self.stream.open()
  }

  public func close () -> Void {
    self.stream.close()
  }

  public var length: Int? {
    return byteSize
  }
}